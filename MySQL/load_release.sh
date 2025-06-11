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

moduleStr=INT
echo "Enter module string used in filenames [$moduleStr]:"
read newModuleStr
if [ -n "$newModuleStr" ]
then
	moduleStr=$newModuleStr
fi

ORIG_IFS=$IFS
IFS=","
langCodeArray=(en)
echo "Enter the language code(s) string used in filenames. Comma separate if multiple [en]:"
read newLangCode
if [ -n "$newLangCode" ]
then
	langCodeArray=($newLangCode)
fi
IFS=$ORIG_IFS

for i in "${langCodeArray[@]}"; do
  echo "Language Code: $i"
done

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

includeTransitiveClosure=false
echo "Calculate and store inferred transitive closure? [Y/N]:"
read tcResponse
if [[ "${tcResponse}" == "Y"  ||  "${tcResponse}" == "y" ]]
then
	echo "Including transitive closure table - transclos"
	includeTransitiveClosure=true
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

#Generate the environment script by running through the template as 
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
		fileName=${1/TYPE/${fileType}}
		fileName=${fileName/DATE/${releaseDate}}
		fileName=${fileName/MOD/${moduleStr}}
		fileName=${fileName/LANG/${3}}
		parentPath="${localExtract}/"
		tableName=${2}_`echo $fileType | head -c 1 | tr '[:upper:]' '[:lower:]'`
		snapshotOnly=false
		#Check file exists - try beta version, or filepath directly if not
		if [ ! -f ${parentPath}${fileName} ]; then
			origFilename=${fileName}
			fileName="x${fileName}"
			if [ ! -f ${parentPath}${fileName} ]; then
  				parentPath=""
				fileName=${origFilename}
				tableName=${2} #Files loaded outside of extract directory use own names for table
				snapshotOnly=true
				if [ ! -f ${parentPath}${fileName} ]; then
					echo "Unable to find ${origFilename} or beta version, skipping..."
					#SI are stopping producing Delta files, so don't worry about those missing
					if [ "$fileType" == "Delta" ]
					then 
						echo "Checking next file type"
						continue
					else 
						echo "Skipping"
						return
					fi
				fi
			fi
		fi
		
		if [[ $snapshotOnly = false || ($snapshotOnly = true && "$fileType" == "Snapshot") ]]
		then 
			echo "alter table ${tableName} disable keys;" >> ${generatedLoadScript}
			echo "load data local" >> ${generatedLoadScript}
			echo -e "\tinfile '"${parentPath}${fileName}"'" >> ${generatedLoadScript}
			echo -e "\tinto table ${tableName}" >> ${generatedLoadScript}
			echo -e "\tcolumns terminated by '\\\t'" >> ${generatedLoadScript}
			echo -e "\tlines terminated by '\\\r\\\n'" >> ${generatedLoadScript}
			echo -e "\tignore 1 lines;" >> ${generatedLoadScript}
			echo -e ""  >> ${generatedLoadScript}
			echo "alter table ${tableName} enable keys;" >> ${generatedLoadScript}
			echo -e "select 'Loaded ${fileName} into ${tableName}' as '  ';" >> ${generatedLoadScript}
			echo -e ""  >> ${generatedLoadScript}
		fi
	done 
}

echo -e "\nGenerating loading script for $releaseDate"
echo "/* Generated Loader Script */" >  ${generatedLoadScript}
addLoadScript sct2_Concept_TYPE_MOD_DATE.txt concept
for i in ${langCodeArray[@]}; do
  addLoadScript sct2_Description_TYPE-LANG_MOD_DATE.txt description $i
  addLoadScript sct2_TextDefinition_TYPE-LANG_MOD_DATE.txt textdefinition $i
  addLoadScript der2_cRefset_LanguageTYPE-LANG_MOD_DATE.txt langrefset $i
done
addLoadScript sct2_StatedRelationship_TYPE_MOD_DATE.txt stated_relationship
addLoadScript sct2_Relationship_TYPE_MOD_DATE.txt relationship
addLoadScript sct2_RelationshipConcreteValues_TYPE_MOD_DATE.txt relationship_concrete
addLoadScript sct2_sRefset_OWLExpressionTYPE_MOD_DATE.txt owlexpression
addLoadScript der2_cRefset_AttributeValueTYPE_MOD_DATE.txt attributevaluerefset
addLoadScript der2_cRefset_AssociationTYPE_MOD_DATE.txt associationrefset
addLoadScript der2_sRefset_SimpleMapTYPE_MOD_DATE.txt simplemaprefset
addLoadScript der2_iissscRefset_ComplexMapTYPE_MOD_DATE.txt complexmaprefset
addLoadScript der2_iisssccRefset_ExtendedMapTYPE_MOD_DATE.txt extendedmaprefset

mysql -u ${dbUsername} ${dbUserPassword}  --local-infile << EOF
        select 'Ensuring schema ${dbName} exists' as '  ';
        create database IF NOT EXISTS ${dbName};
        use ${dbName};
        select '(re)Creating Schema using ${generatedEnvScript}' as '  ';
        source ${generatedEnvScript};
EOF

if [ "${includeTransitiveClosure}" = true ]
then
	echo "Generating Transitive Closure file..."
	tempFile=$(mktemp)
        infRelFile=${localExtract}/sct2_Relationship_Snapshot_${moduleStr}_${releaseDate}.txt
        if [ ! -f ${infRelFile} ]; then
                infRelFile=${localExtract}/xsct2_Relationship_Snapshot_${moduleStr}_${releaseDate}.txt
        fi
        perl ./transitiveClosureRf2Snap_dbCompatible.pl ${infRelFile} ${tempFile}
	mysql -u ${dbUsername} ${dbUserPassword} ${dbName} << EOF
DROP TABLE IF EXISTS transclos;
CREATE TABLE transclos (
  sourceid varchar(18) DEFAULT NULL,
  destinationid varchar(18) DEFAULT NULL,
  KEY idx_tc_source (sourceid),
  KEY idx_tc_destination (destinationid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOF
addLoadScript ${tempFile} transclos
fi

mysql -u ${dbUsername} ${dbUserPassword} ${dbName}  --local-infile << EOF
	select 'Loading RF2 Data using ${generatedLoadScript}' as '  ';
	source ${generatedLoadScript};
EOF

rm -rf $localExtract
#We'll leave the generated environment & load scripts for inspection

