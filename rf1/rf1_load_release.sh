#!/bin/sh
set -e;

releasePath=$1
dbName=$2

if [ -z ${dbName} ]
then
	echo "Usage <rf1 release location> <db schema name>"
	exit -1
fi

#Unzip the files here, junking the structure
localExtract="tmp_rf1_extracted"
rm -rf $localExtract
generatedScript="tmp_rf1_loader.sql"
unzip -j ${releasePath} -d ${localExtract}

#Determine the release date from the filenames
releaseDate=`ls -1 ${localExtract}/*.txt | head -1 | egrep -o '[0-9]{8}'`

function addLoadScript() {
	fileName=${1/DATE/${releaseDate}}
	tableName=${2}

	#Check file exists - try beta version if not
	if [ ! -f ${localExtract}/${fileName} ]; then
		origFilename=${fileName}
		fileName="x${fileName}"
		if [ ! -f ${localExtract}/${fileName} ]; then
			echo "Unable to find ${origFilename} or beta version - skipping load"
			return
		fi
	fi
	
	echo "load data local" >> ${generatedScript}
	echo "\tinfile '"${localExtract}/${fileName}"'" >> ${generatedScript}
	echo "\tinto table ${tableName}" >> ${generatedScript}
	echo "\tcolumns terminated by '\\\t'" >> ${generatedScript}
	echo "\tlines terminated by '\\\r\\\n'" >> ${generatedScript}
	echo "\tignore 1 lines;" >> ${generatedScript}
	echo ""  >> ${generatedScript}
	echo "select 'Loaded ${fileName} into ${tableName}' as '  ';" >> ${generatedScript}
	echo ""  >> ${generatedScript}
}

echo "Generating RF1 loading script for $releaseDate"
echo "/* Generated Loader Script */" >  ${generatedScript}
addLoadScript sct1_Concepts_Core_INT_DATE.txt rf1_concept
addLoadScript sct1_Descriptions_en_INT_DATE.txt rf1_description
addLoadScript sct1_References_Core_INT_DATE.txt rf1_reference
addLoadScript sct1_Relationships_Core_INT_DATE.txt rf1_relationship
addLoadScript sct1_TextDefinitions_en-US_INT_DATE.txt rf1_textdefinition

#ICD-O Cross Maps
addLoadScript der1_CrossMapSets_ICDO_INT_DATE.txt rf1_xmapset
addLoadScript der1_CrossMapTargets_ICDO_INT_DATE.txt rf1_xmaptarget
addLoadScript der1_CrossMaps_ICDO_INT_DATE.txt rf1_xmap

#ICD-9 Cross Maps
addLoadScript der1_CrossMapSets_ICD9_INT_DATE.txt rf1_xmapset
addLoadScript der1_CrossMapTargets_ICD9_INT_DATE.txt rf1_xmaptarget
addLoadScript der1_CrossMaps_ICD9_INT_DATE.txt rf1_xmap

addLoadScript der1_Subsets_en-GB_INT_DATE.txt rf1_subset
addLoadScript der1_Subsets_en-US_INT_DATE.txt rf1_subset
addLoadScript der1_SubsetMembers_en-GB_INT_DATE.txt rf1_subsetmember
addLoadScript der1_SubsetMembers_en-US_INT_DATE.txt rf1_subsetmember

addLoadScript res1_StatedRelationships_Core_INT_DATE.txt rf1_stated_relationship
addLoadScript sct1_ComponentHistory_Core_INT_DATE.txt rf1_componenthistory


echo "Passing $generatedScript to MYSQL"

#Unlike the RF2 script, we will not wipe the database by default
mysql -u root  << EOF
	create database IF NOT EXISTS ${dbName};
	use ${dbName}
	source rf1_environment_mysql.sql
	source ${generatedScript};
EOF