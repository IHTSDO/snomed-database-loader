-- CREATE ICD-10 MAP VIEW
DROP VIEW IF EXISTS snap_extendedMapView;
CREATE VIEW  snap_extendedMapView AS
SELECT id, effectiveTime, active, moduleId, refsetId, 
			 referencedComponentId, (SELECT term FROM snap_pref WHERE conceptId=m.referencedComponentId) Term, 
			 mapGroup, mapPriority, mapRule, mapAdvice, mapTarget, 
			 correlationId, (SELECT term FROM snap_pref WHERE conceptId=m.correlationId) correlationTerm,
			 mapCategoryId, (SELECT term FROM snap_pref WHERE conceptId=m.mapCategoryId) mapCategoryTerm
FROM snap_refset_extendedmap m
			WHERE refsetId=447562003 -- MODIFY THIS CODE FOR OTHER MAPS USING SAME REFSET TYPE (e.g. ICD-10-CM 6011000124106, ICPC 450993002)
			AND active=1
			ORDER BY referencedComponentId,mapGroup,mapPriority;

-- ICD-10 MAP EXAMPLE 1: SIMPLE
-- 74400008|Appendicitis| 
SELECT * FROM snap_extendedMapView WHERE referencedComponentId=74400008;

-- ICD-10 MAP EXAMPLE 2: TWO MAP GROUPS
--  196607008|Esophageal ulcer due to aspirin|
SELECT * FROM snap_extendedMapView WHERE referencedComponentId=196607008;

-- ICD-10 MAP EXAMPLE 3: AGE BASED RULE
--  32398004|Bronchitis|
SELECT * FROM snap_extendedMapView WHERE referencedComponentId=32398004;

-- ICD-10 MAP EXAMPLE 4: GENDER BASED RULE
--  8619003|Infertility|
SELECT * FROM snap_extendedMapView WHERE referencedComponentId=8619003;

-- ICD-10 MAP EXAMPLE 5: EXTERNAL CAUSES
--  111613008|Closed skull fracture with intracranial injury|
SELECT * FROM snap_extendedMapView WHERE referencedComponentId=111613008;
