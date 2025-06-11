import duckdb
import argparse
import re
import os
import sys
import tempfile
import zipfile
import logging
from enum import Enum
from typing import List, Tuple, Callable

# Constants for DuckDB
IN_MEMORY_KEYWORD = ":memory:"
UI_PORT = 4213
UI_INSTALL_COMMAND = "INSTALL ui;"
UI_LOAD_COMMAND = "LOAD ui;"
UI_START_COMMAND = "CALL start_ui();"
COPY_OPTIONS = "HEADER, DELIMITER '\t', DATEFORMAT '%Y%m%d', NULL '\n'"

# Constants for logging messages
DEBUG_CONNECTION_CLOSED = "Connection closed"
DEBUG_FAILED_SQL = "SQL failed: COPY {} FROM '{}' ({})"
DEBUG_UI_EXT_LOADED = "UI extension loaded"
ERROR_IMPORT_FAILURE = "Failed to import '{}': {}"
ERROR_INVALID_PACKAGE = "Invalid package directory"
ERROR_SQL_EXEC_FAILED = "SQL execution failed: {}, {}"
ERROR_UI_INIT_FAILED = "UI initialization failed: {}"
ERROR_UI_START_FAILED = "UI start failed: {}"
ERROR_ZIP_NOT_FOUND = "Zip file not found"
INFO_EXTRACTING_PACKAGE = "Extracting package '{}'"
INFO_IMPORT_SUCCESS = "Imported '{}'"
INFO_SQL_EXEC_SUCCESS = "Executed SQL: '{}'"
INFO_UI_RUNNING = "UI running at http://localhost:{}"
WARNING_NO_MATCHING_FILES = "No matching files for release type {}"
PROMPT_CLOSE = "Press <ENTER> to close"


# Configure logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# Parse command-line arguments
parser = argparse.ArgumentParser(
    description="""SNOMED-CT DuckDB Loader.
    This script imports SNOMED-CT RF2 files from an Edition package into DuckDB and
    launches a web-based UI for interactive queries.
    """
)
parser.add_argument(
    "--package", type=str, default="", help="Path to SNOMED-CT package location"
)
parser.add_argument(
    "--db",
    type=str,
    default="",
    help="Path to DuckDB database file (omit for in-memory mode)",
)
args = parser.parse_args()

PACKAGE_LOCATION = args.package
DB_FILE = args.db
SQL_RESOURCES_PATH = os.path.join(
    os.path.dirname(__file__),
    "resources",
    "sql",
)


class ReleaseType(Enum):
    FULL = "Full"
    SNAPSHOT = "Snapshot"
    DELTA = "Delta"

    def __init__(self, full_name):
        self.short_code = full_name[0].lower()


def get_table_details(release_dir, release_type: ReleaseType):
    # define the regex filter to match release file naming convention per RF2 specification:
    # https://confluence.ihtsdotools.org/display/DOCRELFMT/3.3.2+Release+File+Naming+Convention
    #
    # [FileType]_[ContentType]_[ContentSubType]_[CountryNamespace]_[VersionDate].[FileExtension]

    file_type = r"x?(sct|der)2"  # match group 1
    content_type = r"(\w+)"  # match group 2

    refset_id = r"(?:\d{6,18})?"
    summary = r"(\w+)?"  # match group 3
    rt = rf"{release_type.value}"
    language_code = r"(-[a-z-]{2,8})?"
    content_sub_type = rf"{refset_id}{summary}{rt}{language_code}"

    country_namespace = r"(?:INT|[A-Z]{2}\d{7})"
    version_date = r"\d{8}"
    file_ext = r"txt"

    filter_regex = rf"^{file_type}_{content_type}_{content_sub_type}_{country_namespace}_{version_date}\.{file_ext}$"

    # align with table names used in the RVF:
    # https://github.com/IHTSDO/release-validation-framework/blob/master/src/main/resources/sql/create-tables-mysql.sql

    extract_content_or_summary = (
        filter_regex,  # only import files that match the naming convention above (e.g. exclude *.json)
        lambda match: (
            match.group(2)
            + "_"
            + release_type.short_code  # i.e. Concept_f for terminology data files
            if (match.group(1) == "sct" and match.group(3) != "OWLExpression")
            else match.group(3)
            + "refset_"
            + release_type.short_code  # Languagerefset_f for derivative work data files
        ),
    )

    drop_suffix_from_refsetdescriptor = (
        rf"RefsetDescriptorrefset_{release_type.short_code}",
        rf"RefsetDescriptor_{release_type.short_code}",
    )

    drop_suffix_from_simplerefset = (r"(Simple)(Refset)", r"\1")
    drop_suffix_from_associationreference = (r"(Association)(Reference)", r"\1")
    shorten_language_prefix = (r"(Language)", "Lang")
    add_underscore_to_relationship_concrete_values = (
        r"(Relationship)(Concrete)(Values)",
        r"\1_\2_\3",
    )
    add_underscore_to_stated_relationship = (r"(Stated)(Relationship)", r"\1_\2")

    regex_transformations: List[Tuple[str, str | Callable]] = [
        extract_content_or_summary,
        drop_suffix_from_refsetdescriptor,
        drop_suffix_from_simplerefset,
        drop_suffix_from_associationreference,
        shorten_language_prefix,
        add_underscore_to_relationship_concrete_values,
        add_underscore_to_stated_relationship,
    ]

    normalized_table_names = []
    for dirname, _, files in os.walk(os.path.join(release_dir, release_type.value)):
        for filename in files:
            if re.match(filter_regex, filename):
                normalized_filename = filename
                for pattern, replacement in regex_transformations:
                    normalized_filename = re.sub(
                        pattern, replacement, normalized_filename
                    )
                normalized_table_names.append(
                    (normalized_filename.lower(), dirname, filename)
                )

    # sort filenames to ensure that terminology data and concept files are loaded first
    normalized_table_names.sort(
        key=lambda x: (
            "sct2" not in x[1],  # Prioritize terminology data files
            "concept" not in x[0],  # Prioritize concept files
            x[0],  # Finally, sort alphabetically by normalized name
        )
    )
    return normalized_table_names


def validate_package_path(package_path):
    if not (
        package_path or os.path.isdir(package_path) or os.path.isfile(package_path)
    ):
        raise ValueError(ERROR_INVALID_PACKAGE)


class DuckDBClient:
    def __init__(self, db_path=IN_MEMORY_KEYWORD):
        self.conn = duckdb.connect(db_path)
        try:
            self.conn.execute(UI_INSTALL_COMMAND)
            self.conn.execute(UI_LOAD_COMMAND)
            logging.debug(DEBUG_UI_EXT_LOADED)
        except Exception as e:
            logging.error(ERROR_UI_INIT_FAILED.format(e))

    def execute_sql_file(self, dirname, sql_filename):
        sql_filepath = os.path.join(dirname, sql_filename)
        try:
            with open(sql_filepath, "r") as file:
                output = self.conn.execute(file.read())
                logging.info(INFO_SQL_EXEC_SUCCESS.format(sql_filename))
                return output.fetchall()
        except Exception as e:
            logging.error(ERROR_SQL_EXEC_FAILED.format(sql_filepath, e))

    def execute_ddl(self, release_type: ReleaseType):
        ddl_filename = f"create_{release_type.value.lower()}_tables.sql"
        self.execute_sql_file(SQL_RESOURCES_PATH, ddl_filename)

    def start_ui(self):
        try:
            self.conn.execute(UI_START_COMMAND)
        except Exception as e:
            logging.error(ERROR_UI_START_FAILED.format(e))

    def import_text_file(self, table_name, dirname, rf2_filename):
        rf2_filepath = os.path.join(dirname, rf2_filename)
        try:
            self.conn.execute(
                f"COPY {table_name} FROM '{rf2_filepath}' ({COPY_OPTIONS});"
            )
            logging.info(INFO_IMPORT_SUCCESS.format(rf2_filename))
        except Exception as e:
            logging.error(ERROR_IMPORT_FAILURE.format(rf2_filename, e))
            logging.debug(
                DEBUG_FAILED_SQL.format(table_name, rf2_filepath, COPY_OPTIONS)
            )

    def close(self):
        self.conn.close()
        logging.debug(DEBUG_CONNECTION_CLOSED)


def validate_targetcomponentid(client: DuckDBClient, release_type: ReleaseType):
    sql_filename = f"validate_{release_type.value.lower()}_targetcomponentid.sql"

    result = client.execute_sql_file(SQL_RESOURCES_PATH, sql_filename)

    if len(result):
        raise Exception(
            f"Found {len(result)} invalid targetComponentIds in the Association Refset {release_type} file"
        )


if __name__ == "__main__":
    try:
        validate_package_path(PACKAGE_LOCATION)
    except ValueError as e:
        logging.error(e)
        parser.print_help(sys.stderr)
        quit()

    with tempfile.TemporaryDirectory() as temp_dir:
        if PACKAGE_LOCATION.endswith(".zip"):
            if not os.path.isfile(PACKAGE_LOCATION):
                logging.error(ERROR_ZIP_NOT_FOUND)
                quit()
            logging.info(INFO_EXTRACTING_PACKAGE.format(PACKAGE_LOCATION))
            with zipfile.ZipFile(PACKAGE_LOCATION, "r") as zip_ref:
                zip_ref.extractall(temp_dir)
            PACKAGE_LOCATION = os.path.join(temp_dir, os.listdir(temp_dir)[0])

        duckdb_client = DuckDBClient(DB_FILE)
        file_imported = False
        try:
            for release_type in [ReleaseType.FULL, ReleaseType.SNAPSHOT]:
                table_details = get_table_details(PACKAGE_LOCATION, release_type)
                if not table_details:
                    logging.warning(WARNING_NO_MATCHING_FILES.format(release_type.name))
                else:
                    duckdb_client.execute_ddl(release_type)
                    for table_name, dirname, filename in table_details:
                        duckdb_client.import_text_file(table_name, dirname, filename)
                    file_imported = True
                    validate_targetcomponentid(duckdb_client, release_type)

            if file_imported:
                duckdb_client.start_ui()
                logging.info(INFO_UI_RUNNING.format(UI_PORT))
                input(PROMPT_CLOSE)
        finally:
            duckdb_client.close()
