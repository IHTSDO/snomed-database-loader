# RF1 data loader

RF1 has not been supported by SNOMED International since January 2017 as a format for the distribution of SNOMED CT, but these scripts are provided for those still working with older RF1 distributed files.

## Use

Usage: `<rf1 release location> <db schema name>`

eg `./rf1_load_release.sh ~/Backup/SnomedCT_RF1Release_INT_20150731.zip rf1_20150731`

## Issues

If you see the following error: ERROR 1148 (42000) at line 2 in file: 'tmp_rf1_loader.sql': The used command is not allowed with this MySQL version

This is a security feature of MYSQL to prevent local files being loaded. The script includes an argument of "--local-infile" when starting the client application, but this must also be permitted in the server configuration (eg /usr/local/etc/my.cnf which you may need to create. Type mysql --help for a list of expected config locations). Add the following block to your mysql config file: `[mysql] local-infile=1`

See <http://stackoverflow.com/questions/10762239/mysql-enable-load-data-local-infile>

## Notes

- The script will add the tables to an existing schema, replacing any RF1 tables already present.

## Example output

`...`

` ``` ...

inflating: tmp_rf1_extracted/res1_WordKeyIndex_Concepts-en-US_INT_20150731.txt

inflating: tmp_rf1_extracted/res1_WordKeyIndex_Descriptions-en-US_INT_20150731.txt

Generating RF1 loading script for 20150731

Passing tmp_rf1_loader.sql to MYSQL

Loaded sct1_Concepts_Core_INT_20150731.txt into rf1_concept

Loaded sct1_Descriptions_en_INT_20150731.txt into rf1_description

Loaded sct1_References_Core_INT_20150731.txt into rf1_reference

Loaded sct1_Relationships_Core_INT_20150731.txt into rf1_relationship

Loaded sct1_TextDefinitions_en-US_INT_20150731.txt into rf1_textdefinition

Loaded der1_CrossMapSets_ICDO_INT_20150731.txt into rf1_xmapset

Loaded der1_CrossMapTargets_ICDO_INT_20150731.txt into rf1_xmaptarget

Loaded der1_CrossMaps_ICDO_INT_20150731.txt into rf1_xmap

Loaded der1_CrossMapSets_ICD9_INT_20150731.txt into rf1_xmapset

Loaded der1_CrossMapTargets_ICD9_INT_20150731.txt into rf1_xmaptarget

Loaded der1_CrossMaps_ICD9_INT_20150731.txt into rf1_xmap

Loaded der1_Subsets_en-GB_INT_20150731.txt into rf1_subset

Loaded der1_Subsets_en-US_INT_20150731.txt into rf1_subset

Loaded der1_SubsetMembers_en-GB_INT_20150731.txt into rf1_subsetmember

Loaded der1_SubsetMembers_en-US_INT_20150731.txt into rf1_subsetmember

Loaded res1_StatedRelationships_Core_INT_20150731.txt into rf1_stated_relationship

Loaded sct1_ComponentHistory_Core_INT_20150731.txt into rf1_componenthistory ` `` `

``
