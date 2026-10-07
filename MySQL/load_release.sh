#!/bin/bash
set -e;

#--force-delta may appear anywhere in the arguments
forceDelta=false
positionalArgs=()
for arg in "$@"; do
	if [ "${arg}" == "--force-delta" ]
	then
		forceDelta=true
	else
		positionalArgs+=("${arg}")
	fi
done

releasePath=${positionalArgs[0]}
dbName=${positionalArgs[1]}
loadType=${positionalArgs[2]}

if [ -z ${loadType} ]
then
	echo "Usage <release location> <db schema name> <DELTA|SNAP|FULL|ALL> [--force-delta]"
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

#Working files and directory
localExtract="tmp_extracted"
generatedLoadScript="tmp_loader.sql"
generatedEnvScript="tmp_environment-mysql.sql"

#What types of files are we loading - delta, snapshot, full or all?
case "${loadType}" in
	'DELTA') fileTypes=(Delta)
	;;
	'SNAP') fileTypes=(Snapshot)
	;;
	'FULL') fileTypes=(Full)
	;;
	'ALL') fileTypes=(Delta Snapshot Full)
	;;
	*) echo "File load type ${loadType} not recognised"
	exit -1;
	;;
esac

#Release packages no longer include Delta files, so only load Delta when there's a Concept Delta,
#unless forced (eg a translation package has Delta descriptions but no Concept file)
if [[ " ${fileTypes[*]} " == *" Delta "* && "${forceDelta}" = false ]] && ! unzip -Z1 ${releasePath} | grep -q "sct2_Concept_Delta_"
then
	echo -e "\nNo Concept Delta file in the package, so Delta files will not be loaded (use --force-delta to load any that are present)"
	remainingFileTypes=()
	for fileType in ${fileTypes[@]}; do
		if [ "${fileType}" != "Delta" ]
		then
			remainingFileTypes+=("${fileType}")
		fi
	done
	fileTypes=(${remainingFileTypes[@]})
	if [ ${#fileTypes[@]} -eq 0 ]
	then
		echo "Nothing left to load"
		exit -1
	fi
fi

#Unzip only the file types being loaded, junking the structure.
#unzip exits with 11 when a pattern matches nothing, eg forcing Delta on a package without any
unzipPatterns=()
for fileType in ${fileTypes[@]}; do
	unzipPatterns+=("*${fileType}*")
done
unzip -j ${releasePath} "${unzipPatterns[@]}" -d ${localExtract} || [ $? -eq 11 ]

	
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

