/* loads the SNOMED CT 'Full' release - replace filenames with relevant locations of base SNOMED CT release files*/

/* Filenames may need to change depending on the release you wish to upload, currently set to July 2014 release */

load data local 
	infile 'RF2Release/Full/Terminology/sct2_Concept_Full_INT_20140731.txt' 
	into table concept_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_Description_Full-en_INT_20140731.txt' 
	into table description_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_TextDefinition_Full-en_INT_20140731.txt' 
	into table textdefinition_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_Relationship_Full_INT_20140731.txt' 
	into table relationship_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_StatedRelationship_Full_INT_20140731.txt' 
	into table stated_relationship_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Language/der2_cRefset_LanguageFull-en_INT_20140731.txt' 
	into table langrefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Content/der2_cRefset_AssociationReferenceFull_INT_20140731.txt' 
	into table associationrefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Content/der2_cRefset_AttributeValueFull_INT_20140731.txt' 
	into table attributevaluerefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Map/der2_sRefset_SimpleMapFull_INT_20140731.txt' 
	into table simplemaprefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Content/der2_Refset_SimpleFull_INT_20140731.txt' 
	into table simplerefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Map/der2_iissscRefset_ComplexMapFull_INT_20140731.txt' 
	into table complexmaprefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;
























