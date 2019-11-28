-- Step By Step Development of Description Composite Views from Concepts, Descriptions and Language refsets

-- STEP 3: Show all active synonyms for a concept.

SELECT * FROM snap_description
    WHERE conceptId = 80146002 AND active=1
    AND typeId=900000000000013009;

-- Run this query.
-- Note that:
-- 1. Only active synonyms are now shown.
--    - typeId 900000000000013009 (Synonym)
-- 2. The synonyms include both "Appendectomy" and "Appendicectomy"
--    - One of these is valid in US English and the other is valid in GB English
-- The next step uses the language reference sets to identify the appropriate term to display.
--
-- You can modify this query to see  fully specified name description(s):
--   - replace typeId=900000000000013009 
--   - with    typeId=900000000000003001
--
