-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 4: Show all active synonyms that are acceptable or preferred in the US.

SELECT d.* FROM snap_description d
    JOIN snap_refset_language rs ON d.id = rs.referencedComponentId
    WHERE d.conceptId = 80146002 AND d.active=1
    AND d.typeId=900000000000013009
    AND rs.refsetId = 900000000000509007 -- US Language Refset -- (for GB Language Refset replace with: 900000000000508004 )
    AND rs.active = 1

-- Run this query.
--  - Note that the synonym "Appendectomy" is shown but NOT "Appendicectomy"
-- Change rs.refsetId = 900000000000509007 to rs.refsetId = 900000000000508004
-- Run the revised query to see the en-GB terms
--  - Note that now the synonym "Appendicectomy" is shown but NOT "Appendectomy" 

-- NOTE
--  - This query only includes synonyms that are referenced by an active row in the US Language Refset.
--  - It does not distinguish between the preferred term and other acceptable synonyms.