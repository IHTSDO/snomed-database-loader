#!/bin/bash
set -e;

releasePath=$1
dbName=$2
loadType=$3

if [ -z ${loadType} ]
then
	echo "Usage <release location> <db schema name> <DELTA|SNAP|FULL|ALL>"
	exit -1
fi

dbUsername=root
echo "Enter database username [$dbUsername]:"
read newDbUsername
if [ -n "$newDbUsername" ]
then
	dbUsername=$newDbUsername
fi

dbUserPassword=""
echo "Enter database password (or return for none):"
read newDbPassword
if [ -n "$newDbPassword" ]
then
	dbUserPassword="-p${newDbPassword}"
fi

#Unzip the files here, junking the structure
localExtract="tmp_extracted"
generatedLoadScript="tmp_loader.sql"
generatedEnvScript="tmp_environment-mysql.sql"

#What types of files are we loading - delta, snapshot, full or all?
case "${loadType}" in 
	'DELTA') fileTypes=(Delta)
		unzip -j ${releasePath} "*Delta*" -d ${localExtract}
	;;
	'SNAP') fileTypes=(Snapshot)
		unzip -j ${releasePath} "*Snapshot*" -d ${localExtract}
	;;
	'FULL') fileTypes=(Full)
		unzip -j ${releasePath} "*Full*" -d ${localExtract}
	;;
	'ALL') fileTypes=(Delta Snapshot Full)	
		unzip -j ${releasePath} -d ${localExtract}
	;;
	*) echo "File load type ${loadType} not recognised"
	exit -1;
	;;
esac

	
#Determine the release date from the filenames
releaseDate=`ls -1 ${localExtract}/*.txt | head -1 | egrep -o '[0-9]{8}'`	

#Generate the environemnt script by running through the template as 
#many times as required
now=`date +"%Y%m%d_%H%M%S"`
echo -e "\nGenerating Environment script for ${loadType} type(s)"
echo "/* Script Generated Automatically by load_release.sh ${now} */" > ${generatedEnvScript}
for fileType in ${fileTypes[@]}; do
	fileTypeLetter=`echo "${fileType}" | head -c 1 | tr '[:upper:]' '[:lower:]'`
	tail -n +2 environment-mysql-template.sql | while read thisLine
	do
		echo "${thisLine/TYPE/${fileTypeLetter}}" >> ${generatedEnvScript}
	done
done

function addLoadScript() {
	for fileType in ${fileTypes[@]}; do
		echo "load data local" >> ${generatedLoadScript}
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

		echo -e "\tinfile '"${localExtract}/${fileName}"'" >> ${generatedLoadScript}
		echo -e "\tinto table ${tableName}" >> ${generatedLoadScript}
		echo -e "\tcolumns terminated by '\\\t'" >> ${generatedLoadScript}
		echo -e "\tlines terminated by '\\\r\\\n'" >> ${generatedLoadScript}
		echo -e "\tignore 1 lines;" >> ${generatedLoadScript}
		echo -e ""  >> ${generatedLoadScript}
		echo -e "select 'Loaded ${fileName} into ${tableName}' as '  ';" >> ${generatedLoadScript}
		echo -e ""  >> ${generatedLoadScript}
	done
}

echo -e "\nGenerating loading script for $releaseDate"
echo "/* Generated Loader Script */" >  ${generatedLoadScript}
addLoadScript sct2_Concept_TYPE_INT_DATE.txt concept
addLoadScript sct2_Description_TYPE-en_INT_DATE.txt description
addLoadScript sct2_StatedRelationship_TYPE_INT_DATE.txt stated_relationship
addLoadScript sct2_Relationship_TYPE_INT_DATE.txt relationship
addLoadScript der2_cRefset_AttributeValueTYPE_INT_DATE.txt attributevaluerefset
addLoadScript der2_cRefset_LanguageTYPE-en_INT_DATE.txt langrefset
addLoadScript der2_cRefset_AssociationReferenceTYPE_INT_DATE.txt associationrefset

mysql -u ${dbUsername} ${dbUserPassword}  --local-infile << EOF
	select 'Ensuring schema ${dbName} exists' as '  ';
	create database IF NOT EXISTS ${dbName};
	use ${dbName};
	select '(re)Creating Schema using ${generatedEnvScript}' as '  ';
	source ${generatedEnvScript};
	select 'Loading RF2 Data using ${generatedLoadScript}' as '  ';
	source ${generatedLoadScript};
EOF

rm -rf $localExtract
#We'll leave the generated environment & load scripts for inspection
