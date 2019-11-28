-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 6: Create a View that displays synonymous terms for a concept

DROP VIEW IF EXISTS myview_synonyms;
CREATE VIEW myview_synonyms AS
SELECT d.* FROM snap_description d
    JOIN snap_refset_language rs ON d.id = rs.referencedComponentId
    WHERE d.active=1
    AND d.typeId=900000000000013009
    AND rs.refsetId = 900000000000509007 -- US Language Refset -- (for GB Language Refset replace with: 900000000000508004 )
    AND rs.active = 1;

-- When this view has been created as simple query like the one shown below
-- can be used to show the preferred and acceptable synonyms for any concept.

SELECT term FROM myview_synonyms 
    WHERE conceptId=80146002;

-- Modifications to the view to allow the language reference set identifier to be read from a configuration table can allow the
-- same view to be used show synonyms in different languages. This feature is supported by the snap_syn view in the SNOMED Example Database.
