--
-- Find the Preferred Term of subtypes of the concept with id “80146002” 
-- Uses SNAPSHOT view of preferred synonyms
--
SELECT conceptId, term 
FROM snap_pref
WHERE conceptId = 80146002;