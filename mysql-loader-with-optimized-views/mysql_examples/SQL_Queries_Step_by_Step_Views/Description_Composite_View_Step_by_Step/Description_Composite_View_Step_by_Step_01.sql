-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 1: Show all description for a concept.

-- In this series of steps we look at descriptions of the concept 80146002 before applying the 
-- resulting views more generally. 
-- You can repeat the same queries with other concepts but some concepts will not illustrate all the points
-- in these examples.

SELECT * FROM snap_description
    WHERE conceptId = 80146002

-- Run this query.
-- Note that:
-- 1. The result contains some rows that have a 0 (zero) in the active column.
--    - Those descriptions are inactive and in the next step we will filter them out.
-- 2. The typeId values vary
--    - Some rows have the typeId 900000000000013009 (Synonym)
--    - Other rows have the typeId 900000000000003001 (Fully specified name)