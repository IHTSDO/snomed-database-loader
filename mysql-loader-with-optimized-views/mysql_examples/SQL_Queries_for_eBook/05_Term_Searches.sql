--
-- Find the active concepts with an 'acceptable' or 'preferred' synonym 
-- containing the words “disorder” and “lung”
-- 
SELECT conceptId, term -- select specific columns
FROM snap_synall -- from view snap_synall which is a snapshot of all active synonyms
WHERE MATCH (term) AGAINST -- look in the term column
('+disorder +lung' IN BOOLEAN MODE) -- must include both term1 and term2
AND conceptId IN (SELECT id -- conceptId
FROM snap_concept -- from snapshot concept table
WHERE active = 1) -- only interested active concepts
ORDER BY length (term) -- order the results such that shortest appear first