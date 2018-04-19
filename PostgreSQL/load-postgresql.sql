/* loads the SNOMED CT release - replace folder, type and release number with relevant locations of base SNOMED CT release files*/

SET SCHEMA 'snomedct';

DO $$
DECLARE
  folder TEXT := '/RF2Release'; -- Change the root directory based on your file location
  type TEXT := 'Full'; -- Change between Full, Delta, Snapshot.
  release TEXT := 'INT_20170731'; -- Change between each release
  suffix TEXT := '_f'; -- Suffix of the database table. _f stands for full, _d stands for delta, _s stands for snapshot
BEGIN
  suffix := CASE type WHEN 'Full' THEN '_f' WHEN 'Delta' THEN '_d' WHEN 'Snapshot' THEN '_s' ELSE '' END;

  EXECUTE 'TRUNCATE TABLE concept' || suffix;
  EXECUTE 'COPY concept' || suffix || '(id, effectivetime, active, moduleid, definitionstatusid) FROM '''
        || folder || '/' || type || '/Terminology/sct2_Concept_' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE description' || suffix;
  EXECUTE 'COPY description' || suffix || '(id, effectivetime, active, moduleid, conceptid, languagecode, typeid, term, casesignificanceid) FROM '''
        || folder || '/' || type || '/Terminology/sct2_Description_' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE textdefinition' || suffix;
  EXECUTE 'COPY description' || suffix || '(id, effectivetime, active, moduleid, conceptid, languagecode, typeid, term, casesignificanceid) FROM '''
        || folder || '/' || type || '/Terminology/sct2_TextDefinition_' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';
  
  EXECUTE 'TRUNCATE TABLE relationship' || suffix;
  EXECUTE 'COPY relationship' || suffix || '(id, effectivetime, active, moduleid, sourceid, destinationid, relationshipgroup, typeid,characteristictypeid, modifierid) FROM '''
        || folder || '/' || type || '/Terminology/sct2_Relationship_' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE stated_relationship' || suffix;
  EXECUTE 'COPY stated_relationship' || suffix || '(id, effectivetime, active, moduleid, sourceid, destinationid, relationshipgroup, typeid,  characteristictypeid, modifierid) FROM '''
        || folder || '/' || type || '/Terminology/sct2_StatedRelationship_' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';
  
  EXECUTE 'TRUNCATE TABLE langrefset' || suffix;
  EXECUTE 'COPY langrefset' || suffix || '(id, effectivetime, active, moduleid, refsetid, referencedcomponentid, acceptabilityid) FROM '''
        || folder || '/' || type || '/Refset/Language/der2_cRefset_Language' || type || '-en_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';
  
  EXECUTE 'TRUNCATE TABLE associationrefset' || suffix;
  EXECUTE 'COPY associationrefset' || suffix || '(id, effectivetime, active, moduleid, refsetid, referencedcomponentid, targetcomponentid) FROM '''
        || folder || '/' || type || '/Refset/Content/der2_cRefset_Association' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE simplerefset' || suffix;
  EXECUTE 'COPY simplerefset' || suffix || '(id, effectivetime, active, moduleid, refsetid, referencedcomponentid) FROM '''
        || folder || '/' || type || '/Refset/Content/der2_Refset_Simple' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE attributevaluerefset' || suffix;
  EXECUTE 'COPY attributevaluerefset' || suffix || '(id, effectivetime, active, moduleid, refsetid, referencedcomponentid, valueid) FROM '''
        || folder || '/' || type || '/Refset/Content/der2_cRefset_AttributeValue' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE simplemaprefset' || suffix;
  EXECUTE 'COPY simplemaprefset' || suffix || '(id, effectivetime, active, moduleid, refsetid,  referencedcomponentid, maptarget) FROM '''
        || folder || '/' || type || '/Refset/Map/der2_sRefset_SimpleMap' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE complexmaprefset' || suffix;
  EXECUTE 'COPY complexmaprefset' || suffix || '(id, effectivetime, active, moduleid, refsetid, referencedcomponentid, mapGroup, mapPriority, mapRule, mapAdvice, mapTarget, correlationId) FROM '''
        || folder || '/' || type || '/Refset/Map/der2_iissscRefset_ComplexMap' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';

  EXECUTE 'TRUNCATE TABLE extendedmaprefset' || suffix;
  EXECUTE 'COPY extendedmaprefset' || suffix || '(id, effectivetime, active, moduleid, refsetid, referencedcomponentid, mapGroup, mapPriority, mapRule, mapAdvice, mapTarget, correlationId, mapCategoryId) FROM '''
        || folder || '/' || type || '/Refset/Map/der2_iisssccRefset_ExtendedMap' || type || '_' || release || '.txt'' WITH (FORMAT csv, HEADER true, DELIMITER ''	'')';
END $$