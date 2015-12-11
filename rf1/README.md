#RF1 data loader

Usage:<code> &lt;rf1 release location&gt; &lt;db schema name&gt; </code>

eg  <code>
./rf1_load_release.sh ~/Backup/SnomedCT_RF1Release_INT_20150731.zip rf1_20150731
</code>

### Notes

* The script will add the tables to an existing schema, replacing any RF1 tables already present.

### Example output
<code>
	...
	
	...
	
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
	
	Loaded sct1_ComponentHistory_Core_INT_20150731.txt into rf1_componenthistory
</code>