--
-- QUERY 1
-- Find the active concepts with an 'acceptable' or 'preferred' synonym 
-- containing the words “disorder” and “lung”
-- 
SELECT conceptId, term 
FROM sva_synall
WHERE MATCH (term) AGAINST 
('+disorder +lung' IN BOOLEAN MODE)
AND conceptId IN (SELECT id 
FROM sva_concept 
WHERE active = 1)
ORDER BY length (term)




