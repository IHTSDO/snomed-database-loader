# Neo4j Graph Database

This upload script has been kindly donated by Scott Campbell and his team from the University of Nebraska Medical Center, Omaha, NE.

**NOTE:** This script is not directly supported by SNOMED International and has not been tested by the SNOMED International team.

## For attribution:

**Pedersen JG, Campbell WS**. Graph database build of SNOMED CT files. University of Nebraska Medical Center, Omaha, NE. 2017

**Full manuscript:** Campbell WS, Pedersen J, McClay JC, Rao P, Bastola D, Campbell JR. [An alternative database approach for management of SNOMED CT and improved patient data queries](https://www.ncbi.nlm.nih.gov/pubmed/26305513). J Biomed Inform. 2015 Oct;57:350-7\. doi: 10.1016/j.jbi.2015.08.016\. Epub 2015 Aug 21\. PubMed PMID: 26305513.

## Create a Neo4j Graph from a FULL RF2 Release

This is a Linux or Windows command-line operation requiring a Python 2.7 or Python 3.5 (or above) interpreter and the SNOMED_G software.

Requirements:

1. Python requirements
   - Requires python 2.7 or python 3.5 or above
   - NOTE: Has been tested with python 2.7 and python 3.6 and 3.7
   - Requires the py2neo python library
     - For python 3, the latest version of py2neo is supported (4.X)
     - For python 2.7, py2neo 3.1.2 is currently required
       - One way to install py2neo 3.1.2 is to use the python pip utility:
         - pip install py2neo==3.1.2
       - This is a temporary requirement, awaiting a py2neo bugfix
2. Requires the directory specified by `--output_dir` parameter to the snomed_g_graphdb_build_tools.py to be an empty directory.
   - Log files and temporary CSV files are created there and we do not want to accidentally remove the files from a previous build.
   - After the NEO4J database is successfully built, the --output_dir folder containing these temporary files can be deleted to free up disk space.
3. Requires a FULL format RF2 release of SNOMED CT, which includes historical SNOMED CT codes and full change history.
4. Requires Java version 8 or above, as needed by NEO4J version 3 installations
5. Requires NEO4J version 3.2 or above to be installed and running (preferable with an empty NEO4J database)
   - Requires the LOAD CSV command not be limited to the import directory of the NEO4J installation
     - Controlled by the NEO4J configuration option dbms.directories.import=import
       - That option should be commented out, at least for the duration of the database load
       - `#dbms.directories.import=import`
   - Requires 4GB of Java heap memory be configured in the NEO4J configuration
     - A system with 16GB of memory or above will probably not have to explicitly configure this.
     - See NEO4J operations documentation for configuring memory parameters.
       - Currently exists at: https://neo4j.com/docs/operations-manual/current/performance/memory-configuration/

NOTE: the database load will fail if these requirements are not met.

#####ADDENDUM:
In order to support python version 3.9 and neo4j version 5.x, it is necessary to install the latest version of p2neo (2021.2.3) and make sure to have a symbolic link from python to python3

##### Syntax to create the NEO4J database from an RF2 release using the python scripts from this project:

```
python snomed_g_graphdb_build_tools.py db_build --action create --rf2 <rf2-release-directory> --release_type full --neopw <password> --output_dir <output-directory-path>
```

NOTE:

`<rf2-release-directory>` is the RF2 folder containing the "Terminology" folder

`<output-directory-path>` needs to be an empty folder which the python scripts will create CSV files needed to load the NEO4J database. This folder may be deleted after the database has been successfully loaded.

`<password>` is the password which is used to log into NEO4J

##### NEO4J configuration requirements:

There are NEO4J configuration requirements needed to successfully use this software. NEO must be configured to allow import from any directory (specifically, it needs to import from the directory specified by --output_dir). It also needs significant heap memory to be able to process and load the over one million definitions that exist in any SNOMED CT release.

The configuration changes are made to the neo4j.conf file in the conf subfolder where NEO4J was installed.

If the NEO4J desktop is being used, then the neo4j.conf file associated with any database can be found by clicking on the "Settings" tab associated with the NEO4J database you are loading.

The changes to neo4j.conf are as follows:

##### Comment out import directory setting. This allows importing from the --output_dir folder.

`#dbms.directories.import=import`

##### Configure at least 4 gigabytes of heap memory

`dbms.memory.heap.max_size=4G`

##### Building the NEO4J database from the RF2 release:

```
cd <path-to-snomed_g-bin>`

python snomed_g_graphdb_build_tools.py db_build --release_type full --mode build --action create --rf2 /Users/<user>/Documents/SnomedCT/SnomedCT_UKClinicalRF2_Production_20171001T000001Z/Full/ --release_type full --neopw <password> --language_code 'en-GB' --output_dir /var/tmp/SnomedCT_UKClinicalRF2_Production_20171001T000001Z
```

##### Output that you should see in a successful execution

```
sequence did not exist, primed
JOB_START
FIND_ROLENAMES
FIND_ROLEGROUPS
MAKE_CONCEPT_CSVS
MAKE_DESCRIPTION_CSVS
MAKE_ISA_REL_CSVS
MAKE_DEFINING_REL_CSVS
TEMPLATE_PROCESSING
CYPHER_EXECUTION
CHECK_RESULT
JOB_END
RESULT: SUCCESS
```

##### build.log contents in a successful execution

The following is an example of the beginning portion of a build.log file for a successful build. This file contains thousands of lines in a successful build, so only a portion is shown here. The idea is that this build.log can be compared to what is seen in a failure case.

```
count of RF2 ids: 471023
count of FSNs in RF2: 471023
Total RF2 elements: 471023, NEW: 471023, CHANGE: 0, NO CHANGE: 0
0000_make_concept_csvs              : 0:00:10.447769
0001_read_RF2_description           : 0:00:04.188471
0002_read_RF2_concept               : 0:00:01.940341
0003_generate_csvs                  : 0:00:03.804368
count of RF2 ids: 1466829
[[[ NOTE: Did not find Refset/Language records for 82 concepts, e.g. sctid: [2941370016] ]]]
Total RF2 elements: 1466829, NEW: 1466829, CHANGE: 0, NO CHANGE: 0
0000_make_description_csvs          : 0:00:46.674162
0001_read_RF2_description           : 0:00:10.710453
0002_read_RF2_language              : 0:00:08.540495
0003_generate_csvs                  : 0:00:27.422727
count of ids in RF2: 973094
Total RF2 elements: 973094, NEW: 973094, CHANGE: 0, NO CHANGE: 0
0000_make_isa_rels_csvs             : 0:00:21.850559
0001_read_RF2_relationship          : 0:00:11.283664
0002_csv_generation                 : 0:00:10.566659
count of ids in RF2: 1969615
Total RF2 elements: 1969615, NEW: 1969615, CHANGE: 0, NO CHANGE: 0
0000_make_defining_rels_csvs        : 0:00:56.948343
0001_read_all_roles                 : 0:00:00.000422
0002_read_RF2_relationship          : 0:00:19.372930
0003_csv_generation                 : 0:00:37.574696
1. // -----------------------------------------------------------------------------------------
2. // Module:  snomed_g_graphdb_create.cypher
3. // Author: Jay Pedersen, University of Nebraska, August 2015

<snip-resuming-at-the-end-of-build-dot-log>

DETAILS:

Backup sequence number: 1
step:[JOB_START],result:[SUCCESS],command:[None],status/expected:0/0,duration:0:00:00.000016,output:[JOB-START(action:[create], mode:[build], release_type:[full], rf2:[/Users/jay/sno/snomedct_rf2/20190731/Full/], date:[20200130])],error:[],cmd_start:[2020-01-30 12:49:15.039594],cmd_end:[2020-01-30 12:49:15.039610]
step:[FIND_ROLENAMES],result:[SUCCESS],command:[python /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_rf2_tools.py find_rolenames --release_type full --rf2 /Users/jay/sno/snomedct_rf2/20190731/Full/ --language_code en --language_name Language],status/expected:0/0,duration:0:00:11.298340,output:[],error:[],cmd_start:[2020-01-30 12:49:15.039617],cmd_end:[2020-01-30 12:49:26.337957]
step:[FIND_ROLEGROUPS],result:[SUCCESS],command:[python /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_rf2_tools.py find_rolegroups --release_type full --rf2 /Users/jay/sno/snomedct_rf2/20190731/Full/ --language_code en --language_name Language],status/expected:0/0,duration:0:00:09.425625,output:[],error:[],cmd_start:[2020-01-30 12:49:26.337996],cmd_end:[2020-01-30 12:49:35.763621]
step:[MAKE_CONCEPT_CSVS],result:[SUCCESS],command:[python /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_rf2_tools.py make_csv --element concept --release_type full --rf2 /Users/jay/sno/snomedct_rf2/20190731/Full/ --neopw test1234 --action create --relationship_file Relationship --language_code en --language_name Language],status/expected:0/0,duration:0:00:10.653972,output:[],error:[],cmd_start:[2020-01-30 12:49:35.763657],cmd_end:[2020-01-30 12:49:46.417629]
<snip>
step:[TEMPLATE_PROCESSING],result:[SUCCESS],command:[python /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_template_tools.py instantiate /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_graphdb_cypher_create.template build.cypher --rf2 /Users/jay/sno/snomedct_rf2/20190731/Full/ --release_type full],status/expected:0/0,duration:0:00:00.080631,output:[],error:[],cmd_start:[2020-01-30 12:51:54.667031],cmd_end:[2020-01-30 12:51:54.747662]
step:[CYPHER_EXECUTION],result:[SUCCESS],command:[python /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_neo4j_tools.py run_cypher build.cypher --verbose --neopw test1234],status/expected:0/0,duration:0:05:41.053754,output:[],error:[],cmd_start:[2020-01-30 12:51:54.747706],cmd_end:[2020-01-30 12:57:35.801460]
step:[CHECK_RESULT],result:[SUCCESS],command:[python /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_neo4j_tools.py run_cypher /Users/jay/src/snomed-database-loader/NEO4J//snomed_g_graphdb_update_failure_check.cypher --verbose --neopw test1234],status/expected:0/0,duration:0:00:00.278629,output:[],error:[],cmd_start:[2020-01-30 12:57:35.801498],cmd_end:[2020-01-30 12:57:36.080127]
step:[JOB_END],result:[SUCCESS],command:[None],status/expected:0/0,duration:0:08:21.041281,output:[JOB-END],error:[],cmd_start:[2020-01-30 12:49:15.038936],cmd_end:[2020-01-30 12:57:36.080217]
```

## Language support

##### Specific Steps

1. Change to the NEO4J directory with snomed_g python scripts:

```
cd <NEO4J-python-scripts-folder>
```

This folder contains the `snomed_g_graphdb_build_tools.py` file, among others.

2. Execute the build script. Following the general syntax from above here is an example with optional flags set

```
python snomed_g_graphdb_build_tools.py db_build --release_type full --mode build --action create --rf2 /Users/<user>/Documents/SnomedCT/SnomedCT_UKClinicalRF2_Production_20171001T000001Z/Full/ --release_type full --neopw <password> --language_code 'en-GB' --output_dir /var/tmp/SnomedCT_UKClinicalRF2_Production_20171001T000001Z
```

3. By default, the language designation is "en" and the language is simply "Language", which is used in the filename of the Description file and the Language files.

```
--language_code 'en-us' --language_name 'USEnglish'
```

**NOTE**: the `--output_dir` specifies a directory for creating temporary CSV files for use in database creation, it is not the location of the database itself.

##### Example (Jan 31, 2015 International Edition, on a windows machine)

```
python c:/apps/snomed_g_v1_01/bin/snomed_g_graphdb_build_tools.py db_build --action create --rf2 c:/sno/snomedct/nelex/SnomedCT_RF2Release_INT_20150131/ --release_type full --neopw <password> --output_dir c:/build/20150131 --language_code 'en-us' --language_name 'USEnglish'
```

================================================================

## Update a Neo4j Graph from a FULL RF2

This is a Linux or Windows command-line operation requiring Python 2.7 and the SNOMED_G software.

Requirements:

1. Requires python 2.7 or python 3.5 (or above)
   - NOTE: has been tested with python 2.7 and python 3.6
   - Requires the py2neo python library to be installed
2. Requires the directory specified by `--output_dir` parameter to the snomed_g_graphdb_build_tools.py to be an empty directory.
   - The purpose of this directory is to for writing log files and temporary CSV files.
   - It is not a directory that NEO4J needs for its normal operation.
   - The contents of these CSV files are loaded into NEO4J.
   - After the database load completes, the CSV files are no longer needed and can then be removed.
3. Requires a FULL format RF2 release of SNOMED CT, which includes historical SNOMED CT codes and full change history.
4. Requires Java version 8 or above, as needed by NEO4J version 3 installations
5. Requires NEO4J version 3.2 or above to be installed and running (holding the NEO4J database to be updated)
   - Requires the LOAD CSV command not be limited to the import directory of the NEO4J installation
     - Controlled by the NEO4J configuration option dbms.directories.import=import
       - That option should be commented out, at least for the duration of the database load
         - \#dbms.directories.import=import
   - Requires 4GB of Java heap memory be configured in the NEO4J configuration
     - A system with 16GB of memory or above will probably not have to explicitly configure this.
     - See NEO4J operations documentation for configuring memory parameters.
       - Currently exists at: https://neo4j.com/docs/operations-manual/current/performance/memory-configuration/

NOTE: the database load will fail if these requirements are not met.

General syntax:

```
python <path-to-snomed_g-bin>/snomed_g_graphdb_tools.py db_build --action update --rf2 <path-to-snomedct-release> --release_type full --neopw <password> --output_dir <path-to-output-folder-for-csv-files> --logfile <path-to-filename-to-hold-log-file>
```

**NOTE:** the `--output_dir` specifies a directory for creating temporary CSV files for use in database creation, it is not the location of the database itself.

Example: (_UPDATE to US 2016 0301 (from INT 20150131)_)

```
python c:/apps/snomed_g_v1_01/bin/snomed_g_graphdb_tools.py db_build --action update --rf2 /sno/snomedct/SnomedCT_RF2Release_US1000124_20160301 --release_type full --neopw <password> --output_dir /sno/build/upd_to_us20160301 --logfile /sno/build/int_20150131/sct_build_20160301.log
```

==============================================================

## Create Transitive Closure of ISA relationships contained in a SNOMED CT graph stored in Neo4j

Syntax:

```
python <path-to-snomed_g-bin>/snomed_g_TC_tools.py TC_from_graph <output-transitive-closure-file> --neopw <password>
```

Example: `base64-neo4j-password` must be replaced by the Base64 representation of the Neo4j password):

```
python /sno/bin/snomed_g/snomed_g_TC_tools.py TC_from_graph TC_20150131_graph.txt --neopw <password>
```

This creates the file TC_20150131_graph.txt.

## Versions

1. Version 1.3. 2018-10-18,
   - Support for py2neo version 4.x for python 3, version 4.1 tested (current version)
   - Support for py2neo version 4.x for python 2.7 is awaiting py2neo bugfix
2. Version 1.2, 2018-04-18,
   - Support python 3 in addition to python 2.7. (Tested with python 3.6 and python 2.7).
   - Support --neopw <password> in addition to --neopw64 <base64-password> (deprecated, but still supported).
   - Bug fix -- bug existed in update processing, related to defining relationship differences determination.
3. Version 1.1, 2018-04-13
   - Fix FSN issue in some ObjectConcept nodes -- require that the description have the active='1' attribute value.
