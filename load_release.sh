#!/bin/sh
set -e;

releasePath=$1
dbName=$2

if [ -z ${dbName} ]
then
	echo "Usage <release location> <db schema name>"
	exit -1
fi

#Unzip the files here, junking the structure
localExtract="tmp_extracted"
rm -rf $localExtract
generatedScript="tmp_loader.sql"
unzip -j ${releasePath} -d ${localExtract}

#Determine the release date from the filenames
releaseDate=`ls -1 ${localExtract}/*.txt | head -1 | egrep -o '[0-9]{8}'`

fileTypes=(Delta Full Snapshot)
function addLoadScript() {
	for fileType in ${fileTypes[@]}; do
		echo "load data local" >> ${generatedScript}
		fileName=${1/TYPE/${fileType}}
		fileName=${fileName/DATE/${releaseDate}}

		#Check file exists - try beta version if not
		if [ ! -f ${localExtract}/${fileName} ]; then
			origFilename=${fileName}
			fileName="x${fileName}"
			if [ ! -f ${localExtract}/${fileName} ]; then
				echo "Unable to find ${origFilename} or beta version"
				exit -1
			fi
		fi

		tableName=${2}_`echo $fileType | head -c 1 | tr '[:upper:]' '[:lower:]'`

		echo "\tinfile '"${localExtract}/${fileName}"'" >> ${generatedScript}
		echo "\tinto table ${tableName}" >> ${generatedScript}
		echo "\tcolumns terminated by '\\\t'" >> ${generatedScript}
		echo "\tlines terminated by '\\\r\\\n'" >> ${generatedScript}
		echo "\tignore 1 lines;" >> ${generatedScript}
		echo ""  >> ${generatedScript}
	done


}

echo "Generating loading script for $releaseDate"
echo "/* Generated Loader Script */" >  ${generatedScript}
addLoadScript sct2_Concept_TYPE_INT_DATE.txt concept
addLoadScript sct2_Description_TYPE-en_INT_DATE.txt description
addLoadScript sct2_StatedRelationship_TYPE_INT_DATE.txt stated_relationship
addLoadScript sct2_Relationship_TYPE_INT_DATE.txt relationship
addLoadScript der2_cRefset_AttributeValueTYPE_INT_DATE.txt attributevaluerefset

echo "Passing $generatedScript to MYSQL"

mysql -u root  << EOF
	drop database IF EXISTS ${dbName} ;
	create database ${dbName};
	use ${dbName}
	source environment-mysql.sql
	source ${generatedScript};
EOF