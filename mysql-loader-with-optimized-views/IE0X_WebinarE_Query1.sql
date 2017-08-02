--
-- QUERY 1
-- Find the active concepts with an 'acceptable' synonym containing the words “disorder” and “lung”
-- 
SELECT conceptId, term 
FROM snomedct.sva_synall
WHERE MATCH (term) AGAINST 
('+disorder +lung' IN BOOLEAN MODE)
AND conceptId IN (SELECT id 
FROM snomedct.sva_concept 
WHERE active = 1)
ORDER BY length (term);




