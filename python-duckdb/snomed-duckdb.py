import duckdb
import argparse
import re
import os
import sys
import time
from enum import Enum


# Parse command-line arguments
parser = argparse.ArgumentParser(
    description="""SNOMED-CT DuckDB Loader.
    This script imports SNOMED-CT RF2 files from an Edition package into DuckDB and
    launches a web-based UI for interactive queries.
"""
)
parser.add_argument(
    "--package",
    type=str,
    default="",
    help="Path to the folder containing the SNOMED-CT release package",
)
parser.add_argument(
    "--db",
    type=str,
    default="",
    help="Path to the DuckDB database file (leave empty for in-memory mode)",
)
args = parser.parse_args()

# Path to the folder containing the SNOMED-CT release package
PACKAGE_FOLDER = args.package

# Path to the DuckDB database file
DB_FILE = args.db


class ReleaseType(Enum):
    """
    Enum representing the types of SNOMED CT releases.

    Attributes:
        FULL: Full release type with short code 'f'.
        SNAPSHOT: Snapshot release type with short code 's'.
        DELTA: Delta release type with short code 'd'.
    """

    FULL = "Full"
    SNAPSHOT = "Snapshot"
    DELTA = "Delta"

    def __init__(self, full_name):
        self.full_name = full_name
        self.short_code = full_name[0].lower()


def get_table_names(release_dir, release_type: ReleaseType):
    """
    Extracts filenames from the release directory and normalizes them using regex transformations.

    Args:
        release_dir (str): Path to the release folder.
        release_type (ReleaseType): The type of release (Full, Snapshot, or Delta).

    Returns:
        list: A list of tuples containing the normalized table name and the full file path.
    """
    normalized_table_names = []

    # define the regex filter to match release file naming convention per RF2 specification:
    # https://confluence.ihtsdotools.org/display/DOCRELFMT/3.3.2+Release+File+Naming+Convention
    #
    # [FileType]_[ContentType]_[ContentSubType]_[CountryNamespace]_[VersionDate].[FileExtension]

    file_type = r"x?(sct|der)2"  # match group 1
    content_type = r"(\w+)"  # match group 2

    refset_id = r"(?:\d{6,18})?"
    summary = r"(\w+)?"  # match group 3
    rt = rf"{release_type.full_name}"
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

    regex_transformations = [
        extract_content_or_summary,
        drop_suffix_from_refsetdescriptor,
        drop_suffix_from_simplerefset,
        drop_suffix_from_associationreference,
        shorten_language_prefix,
        add_underscore_to_relationship_concrete_values,
        add_underscore_to_stated_relationship,
    ]

    # Walk through the release directory and process matching files
    dir_tree = os.walk(os.path.join(release_dir, release_type.full_name))

    for root, _, files in dir_tree:
        for file in files:
            if re.match(filter_regex, file):
                normalized_filename = file
                for pattern, replacement in regex_transformations:
                    normalized_filename = re.sub(
                        pattern, replacement, normalized_filename
                    )

                full_file_path = os.path.join(root, file)
                normalized_table_names.append(
                    (normalized_filename.lower(), full_file_path)
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


class DuckDBClient:
    """
    A client for interacting with a DuckDB database.

    Features:
    - Executes SQL commands from files
    - Imports RF2 files into tables
    - Starts a DuckDB UI for interactive queries

    Args:
        db_path (str): Path to the DuckDB database file, else defaults to in-memory mode
    """

    DUCKDB_MEMORY_KEYWORD = ":memory:"

    def __init__(self, db_path=DUCKDB_MEMORY_KEYWORD):
        self.conn = duckdb.connect(db_path)
        self.conn.execute("INSTALL ui;")
        self.conn.execute("LOAD ui;")
        print("DuckDB UI extension installed and loaded.")

    def execute_sql_file(self, sql_file):
        """
        Reads and executes SQL commands from a file.

        :param sql_file_path: Path to the SQL file.
        """
        try:
            with open(sql_file, "r") as file:
                sql_commands = file.read()
                self.conn.execute(sql_commands)
                print(f"Executed SQL commands from {sql_file}")
        except Exception as e:
            print(f"Error executing SQL file '{sql_file}': {e}")

    def create_table(self, release_type: ReleaseType):
        """
        Creates a table for a given release_type

        Args:
            sql_file (str): Path to the SQL DDL file.
        """
        current_dir = os.path.abspath(os.path.dirname(__file__))
        ddl_file = f"create_{release_type.full_name.lower()}_tables.sql"
        ddl_path = os.path.join(current_dir, "resources", "sql", ddl_file)

        self.execute_sql_file(ddl_path)

    def start_ui(self):
        self.conn.execute("CALL start_ui();")

    def import_text_file(self, rf2_file, table_name):
        """
        Imports an RF2 file into a DuckDB database.

        :param file_path: Path to the RF2 file.
        :param table_name: Name of the table to import data into.
        """
        self.conn.execute(
            f"""
        COPY {table_name} from '{rf2_file}' (HEADER, DELIMITER '\t', DATEFORMAT '%Y%m%d', NULL '\n');
        """
        )
        print(
            f"Data from '{rf2_file}' has been successfully imported into the '{table_name}' table."
        )

    def close(self):
        """Closes the DuckDB connection."""
        self.conn.close()
        print("DuckDB connection closed.")


if __name__ == "__main__":
    # define the Release folder path
    release_dir = PACKAGE_FOLDER

    if not release_dir:
        # Display help message if called without any arguments
        parser.print_help(sys.stderr)
        quit()
    elif not os.path.isdir(release_dir):
        # Display error message if the path to the package is not a directory
        print("ERROR: Please ensure that PACKAGE_FOLDER is a valid directory")
        quit()

    duckdb_client = DuckDBClient(DB_FILE)

    # Create tables and ingest Full and Snapshot files
    # note that Delta files are no longer published by default
    for release_type in [ReleaseType.FULL, ReleaseType.SNAPSHOT]:
        duckdb_client.create_table(release_type)

        table_names = get_table_names(release_dir, release_type)

        if not table_names:
            print("WARNING: No matching files found")

        for table_name, file_path in table_names:
            print(f"Importing {file_path} into {table_name}")
            duckdb_client.import_text_file(file_path, table_name)

    print("Launching local UI at http://localhost:4213")
    duckdb_client.start_ui()

    closing_text = "Press <ENTER> to close the DuckDB connection."
    persistence_warning_text = "\nWARNING: DuckDB is running in in-memory mode, remember to save your work before closing"

    input(closing_text + persistence_warning_text if not DB_FILE else closing_text)
    duckdb_client.close()
