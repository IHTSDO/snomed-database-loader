-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 5: Show the preferred term in US English

SELECT d.* FROM snap_description d
    JOIN snap_refset_language rs ON d.id = rs.referencedComponentId
    WHERE d.conceptId = 80146002 AND d.active=1
    AND d.typeId=900000000000013009
    AND rs.refsetId = 900000000000509007 -- US Language Refset -- (for GB Language Refset replace with: 900000000000508004 )
    AND rs.active = 1
    AND rs.acceptabilityId = 900000000000548007; -- Preferred Acceptability

-- Run this query.
--  - Note that the US preferred term "Appendectomy" is shown 
-- Change rs.refsetId = 900000000000509007 to rs.refsetId = 900000000000508004
-- Run the revised query to see the en-GB terms
--  - Note that now the GB preferred term "Appendicectomy" is shown
-- You can also change this query show it shows only synonyms that are acceptable (excluding the preferred term)
--  - Change rs.acceptabilityId = 900000000000548007 to rs.acceptabilityId = 900000000000549004