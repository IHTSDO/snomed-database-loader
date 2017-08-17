--
-- QUERY 2
-- Find the Preferred Term of concept with id “19829001” 
-- Expression Constraint: 19829001
--
SELECT conceptId, term 
FROM snomedct.sva_pref
WHERE conceptId = 19829001;
