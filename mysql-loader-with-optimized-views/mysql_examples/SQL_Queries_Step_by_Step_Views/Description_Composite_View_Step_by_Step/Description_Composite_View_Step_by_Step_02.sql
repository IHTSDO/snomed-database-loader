-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 2: Show all ACTIVE descriptions for a concept.

SELECT * FROM snap_description
    WHERE conceptId = 80146002 AND active=1;

-- Run this query.
-- Note that:
-- 1. The inactive description shown in the previous step are no longer shown.
-- 2. The typeId values vary
--    - Most rows have the typeId 900000000000013009 (Synonym)
--    - One row has the typeId 900000000000003001 (Fully specified name)
-- 3. The synonyms include both "Appendectomy" and "Appendicectomy"
--