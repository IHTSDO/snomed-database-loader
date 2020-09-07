@echo off
@echo --Importing SNOMED CT into MS SQL DB> import.sql
@echo TRUNCATE TABLE curr_extendedmaprefset_f;>> import.sql
@echo TRUNCATE TABLE curr_simplemaprefset_f;>> import.sql
@echo TRUNCATE TABLE curr_attributevaluerefset_f;>> import.sql
@echo TRUNCATE TABLE curr_simplerefset_f;>> import.sql
@echo TRUNCATE TABLE curr_associationrefset_f;>> import.sql
@echo TRUNCATE TABLE curr_langrefset_f;>> import.sql
@echo TRUNCATE TABLE curr_stated_relationship_f;>> import.sql
@echo TRUNCATE TABLE curr_relationship_f;>> import.sql
@echo TRUNCATE TABLE curr_description_f;>> import.sql
@echo TRUNCATE TABLE curr_concept_f;>> import.sql

IF NOT EXIST Full\Terminology\sct2_Concept_Full_INT_* (
	@echo Cannot find Full\Terminology\sct2_Concept_Full_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Terminology\sct2_Concept_Full_INT_*) do ( 
@echo BULK INSERT curr_concept_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Terminology\sct2_Description_Full-en_INT_* (
	@echo Cannot find Full\Terminology\sct2_Description_Full-en_INT_
	EXIT /B 1
)
for /r %%i in (Full\Terminology\sct2_Description_Full-en_INT_*) do ( 
@echo BULK INSERT curr_description_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Terminology\sct2_TextDefinition_Full-en_INT_* (
	@echo Cannot find Full\Terminology\sct2_TextDefinition_Full-en_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Terminology\sct2_TextDefinition_Full-en_INT_*) do ( 
@echo BULK INSERT curr_textdefinition_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Terminology\sct2_Relationship_Full_INT_* (
	@echo Cannot find Full\Terminology\sct2_Relationship_Full_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Terminology\sct2_Relationship_Full_INT_*) do ( 
@echo BULK INSERT curr_relationship_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Terminology\sct2_StatedRelationship_Full_INT_* (
	@echo Cannot find Full\Terminology\sct2_StatedRelationship_Full_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Terminology\sct2_StatedRelationship_Full_INT_*) do ( 
@echo BULK INSERT curr_stated_relationship_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Refset\Language\der2_cRefset_LanguageFull-en_INT_* (
	@echo Cannot find Full\Refset\Language\der2_cRefset_LanguageFull-en_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Refset\Language\der2_cRefset_LanguageFull-en_INT_*) do ( 
@echo BULK INSERT curr_langrefset_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Refset\Content\der2_cRefset_AssociationReferenceFull_INT_* (
	@echo Cannot find Full\Refset\Content\der2_cRefset_AssociationReferenceFull_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Refset\Content\der2_cRefset_AssociationReferenceFull_INT_*) do ( 
@echo BULK INSERT curr_associationrefset_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Refset\Content\der2_Refset_SimpleFull_INT_* (
	@echo Cannot find Full\Refset\Content\der2_Refset_SimpleFull_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Refset\Content\der2_Refset_SimpleFull_INT_*) do ( 
@echo BULK INSERT curr_simplerefset_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Refset\Content\der2_cRefset_AttributeValueFull_INT_* (
	@echo Cannot find Full\Refset\Content\der2_cRefset_AttributeValueFull_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Refset\Content\der2_cRefset_AttributeValueFull_INT_*) do ( 
@echo BULK INSERT curr_attributevaluerefset_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Refset\Map\der2_sRefset_SimpleMapFull_INT_* (
	@echo Cannot find Full\Refset\Map\der2_sRefset_SimpleMapFull_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Refset\Map\der2_sRefset_SimpleMapFull_INT_*) do ( 
@echo BULK INSERT curr_simplemaprefset_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

IF NOT EXIST Full\Refset\Map\der2_iisssccRefset_ExtendedMapFull_INT_* (
	@echo Cannot find Full\Refset\Map\der2_iisssccRefset_ExtendedMapFull_INT_*
	EXIT /B 1
)
for /r %%i in (Full\Refset\Map\der2_iisssccRefset_ExtendedMapFull_INT_*) do ( 
@echo BULK INSERT curr_extendedmaprefset_f FROM '%%i' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', TABLOCK^); >>import.sql
)

