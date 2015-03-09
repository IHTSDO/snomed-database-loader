/* loads the SNOMED CT 'Full', 'Snapshot' and 'Delta' release - replace filenames with relevant locations of base SNOMED CT release files*/

/* Filenames may need to change depending on the release you wish to upload, currently set to January 2015 release */

/* * * * *  FULL * * * * */
load data local 
	infile 'RF2Release/Full/Terminology/sct2_Concept_Full_INT_20150131.txt' 
	into table curr_concept_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_Description_Full-en_INT_20150131.txt' 
	into table curr_description_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_TextDefinition_Full-en_INT_20150131.txt' 
	into table curr_textdefinition_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_Relationship_Full_INT_20150131.txt' 
	into table curr_relationship_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Terminology/sct2_StatedRelationship_Full_INT_20150131.txt' 
	into table curr_stated_relationship_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Language/der2_cRefset_LanguageFull-en_INT_20150131.txt' 
	into table curr_langrefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Content/der2_cRefset_AssociationReferenceFull_INT_20150131.txt' 
	into table curr_associationrefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Content/der2_cRefset_AttributeValueFull_INT_20150131.txt' 
	into table curr_attributevaluerefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Map/der2_sRefset_SimpleMapFull_INT_20150131.txt' 
	into table curr_simplemaprefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Content/der2_Refset_SimpleFull_INT_20150131.txt' 
	into table curr_simplerefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Full/Refset/Map/der2_iissscRefset_ComplexMapFull_INT_20150131.txt' 
	into table curr_complexmaprefset_f
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;


/* * * * *  Snapshot * * * * */
load data local 
	infile 'RF2Release/Snapshot/Terminology/sct2_Concept_Snapshot_INT_20150131.txt' 
	into table curr_concept_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Terminology/sct2_Description_Snapshot-en_INT_20150131.txt' 
	into table curr_description_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Terminology/sct2_TextDefinition_Snapshot-en_INT_20150131.txt' 
	into table curr_textdefinition_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Terminology/sct2_Relationship_Snapshot_INT_20150131.txt' 
	into table curr_relationship_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Terminology/sct2_StatedRelationship_Snapshot_INT_20150131.txt' 
	into table curr_stated_relationship_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Refset/Language/der2_cRefset_LanguageSnapshot-en_INT_20150131.txt' 
	into table curr_langrefset_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Refset/Content/der2_cRefset_AssociationReferenceSnapshot_INT_20150131.txt' 
	into table curr_associationrefset_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Refset/Content/der2_cRefset_AttributeValueSnapshot_INT_20150131.txt' 
	into table curr_attributevaluerefset_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Refset/Map/der2_sRefset_SimpleMapSnapshot_INT_20150131.txt' 
	into table curr_simplemaprefset_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Refset/Content/der2_Refset_SimpleSnapshot_INT_20150131.txt' 
	into table curr_simplerefset_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Snapshot/Refset/Map/der2_iissscRefset_ComplexMapSnapshot_INT_20150131.txt' 
	into table curr_complexmaprefset_s
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

/* * * * *  Delta * * * * */
load data local 
	infile 'RF2Release/Delta/Terminology/sct2_Concept_Delta_INT_20150131.txt' 
	into table curr_concept_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Terminology/sct2_Description_Delta-en_INT_20150131.txt' 
	into table curr_description_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Terminology/sct2_TextDefinition_Delta-en_INT_20150131.txt' 
	into table curr_textdefinition_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Terminology/sct2_Relationship_Delta_INT_20150131.txt' 
	into table curr_relationship_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Terminology/sct2_StatedRelationship_Delta_INT_20150131.txt' 
	into table curr_stated_relationship_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Refset/Language/der2_cRefset_LanguageDelta-en_INT_20150131.txt' 
	into table curr_langrefset_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Refset/Content/der2_cRefset_AssociationReferenceDelta_INT_20150131.txt' 
	into table curr_associationrefset_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Refset/Content/der2_cRefset_AttributeValueDelta_INT_20150131.txt' 
	into table curr_attributevaluerefset_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Refset/Map/der2_sRefset_SimpleMapDelta_INT_20150131.txt' 
	into table curr_simplemaprefset_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Refset/Content/der2_Refset_SimpleDelta_INT_20150131.txt' 
	into table curr_simplerefset_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;

load data local 
	infile 'RF2Release/Delta/Refset/Map/der2_iissscRefset_ComplexMapDelta_INT_20150131.txt' 
	into table curr_complexmaprefset_d
	columns terminated by '\t' 
	lines terminated by '\r\n' 
	ignore 1 lines;























