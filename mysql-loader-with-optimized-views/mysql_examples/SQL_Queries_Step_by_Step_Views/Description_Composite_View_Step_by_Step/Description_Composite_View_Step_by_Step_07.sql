-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 7: Using a View for searches

-- While the view in STEP 6 can be searched, it is worth noting that it includes active terms associated with inactive concepts
--  the terms are important for displaying the a human-readable term for concepts that have been inactivated since they were used.
-- However, in most cases, searches for concepts should only return active concepts. Therefore the view can be adjusted to
--  ensure it can be searched without finding terms associated with inactive concepts.

-- One way to do this is to use the view created in STEP 6 in the following query

SELECT term, conceptId 
    FROM myview_synonyms d
    JOIN snap_concept c ON c.id=d.conceptId
    WHERE c.active=1
    AND MATCH (term) 	AGAINST ('+pneumonia +bacterial' IN BOOLEAN MODE) ;

-- Alternatively a modified view can be created as shown below including the condition requiring the associated concept to be active.

DROP VIEW IF EXISTS myview_search;
CREATE VIEW myview_search AS
SELECT d.* FROM snap_description d
    JOIN snap_concept c ON c.id=d.conceptId
    JOIN snap_refset_language rs ON d.id = rs.referencedComponentId
    WHERE d.active=1
    AND d.typeId=900000000000013009
    AND rs.refsetId = 900000000000509007 -- US Language Refset -- (for GB Language Refset replace with: 900000000000508004 )
    AND rs.active = 1
    AND c.active = 1;

-- When this view has been created the search query is simplified
-- can be used to show the preferred and acceptable synonyms for any concept.

SELECT term, conceptId FROM myview_search 
    WHERE MATCH (term) AGAINST ('+pneumonia +bacterial' IN BOOLEAN MODE) ;

