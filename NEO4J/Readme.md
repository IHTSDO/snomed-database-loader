# NEO4J Graph Database

This upload script has been kindly donated by Scott Campbell from the University of Nebraska Medical Center, Omaha, NE. This script is not directly supported by SNOMED international and is provided for reference.

## For attribution:

**Pedersen JP, Campbell WS**. Graph database build of SNOMED CT files. University of Nebraska Medical Center, Omaha, NE. 2017

**Full manuscript:** Campbell WS, Pedersen J, McClay JC, Rao P, Bastola D, Campbell JR. [An alternative database approach for management of SNOMED CT and improved patient data queries](https://www.ncbi.nlm.nih.gov/pubmed/26305513). J Biomed Inform. 2015 Oct;57:350-7\. doi: 10.1016/j.jbi.2015.08.016\. Epub 2015 Aug 21\. PubMed PMID: 26305513.

## Create a NEO4J Graph from a FULL RF2

This is a Linux or Windows command-line operation requiring python 2.7 and the SNOMED_G software.

Requirements:

- This requires a FULL format RF2 release, which includes historical SNOMED CT codes and full change history.
- This requires NEO4J to be running, with an empty database on the machine where this code is being executed
- This requires the directory specified by `--output_dir` to be empty.

General syntax:

`python <path-to-snomed_g-bin>/snomed_g_graphdb_build_tools.py db_build --action create --rf2 <rf2-release-directory> --release_type full --neopw64 <base64-password> --output_dir <output-directory-path>`

By default, the language designation is "en" and the language is simply "Language", which is used in the filename of the Description file and the Language files.

If that is not what was used, the following parameters need to be specified (assume "en-us" and "USEnglish" values should be used):

`--language_code 'en-us' --language_name 'USEnglish'`

**NOTE**: the `--output_dir` specifies a directory for creating temporary CSV files for use in database creation, it is not the location of the database itself.

Example: (using the Jan 31, 2015 international edition, on a windows machine)

`python c:/apps/snomed_g_v1_01/bin/snomed_g_graphdb_build_tools.py db_build --action create --rf2 c:/sno/snomedct/nelex/SnomedCT_RF2Release_INT_20150131/ --release_type full --neopw64 <base64> --output_dir c:/build/20150131 --language_code 'en-us' --language_name 'USEnglish'`

================================================================================================

## Update a NEO4J Graph from a FULL RF2

This is a Linux or Windows command-line operation requiring python 2.7 and the SNOMED_G software.

Requirements:

- This requires NEO4J to be running, and holding the database that is to be updated.
- This requires a FULL format RF2 release, which includes historical SNOMED CT codes and full change history.
- This requires the directory specified by `--output_dir` to be empty.

General syntax:

`python <path-to-snomed_g-bin>/snomed_g_graphdb_tools.py db_build --action update --rf2 <path-to-snomedct-release> --release_type full --neopw64 <base64> --output_dir <path-to-output-folder-for-csv-files> --logfile <path-to-filename-to-hold-log-file>`

**NOTE:** the `--output_dir` specifies a directory for creating temporary CSV files for use in database creation, it is not the location of the database itself.

Example: (_UPDATE to US 2016 0301 (from INT 20150131)_)

`python c:/apps/snomed_g_v1_01/bin/snomed_g_graphdb_tools.py db_build --action update --rf2 /sno/snomedct/SnomedCT_RF2Release_US1000124_20160301 --release_type full --neopw64 <base64> --output_dir /sno/build/upd_to_us20160301 --logfile /sno/build/int_20150131/sct_build_20160301.log`

=================================================================================================

## Create Transitive Closure of ISA relationships contained in a SNOMED CT graph stored in NEO4J

Syntax:

`python <path-to-snomed_g-bin>/snomed_g_TC_tools.py TC_from_graph <output-transitive-closure-file> --neopw64 <base64-neo4j-password>`

Example: `base64-neo4j-password` must be replaced by the bas64 represenation of the neo4j password):

`python /sno/bin/snomed_g/snomed_g_TC_tools.py TC_from_graph TC_20150131_graph.txt --neopw64 <base64-neo4j-password>`

Output example:

```
1 commands succeeded
1\. [u'typeId', u'effectiveTime', u'active', u'moduleId', u'sourceId', u'characteristicTypeId', u'history', u'id', u'relationshipGroup', u'destinationId']
1 commands succeeded
Result class: <type 'dict'>
Returned 897831 objects
NEO4J Graph DB open: 0.0179009
ISA extraction from NEO4J: 307.962
TC computation: 7.12733
Output (csv): 8.38032
Total time: 323.487
```
