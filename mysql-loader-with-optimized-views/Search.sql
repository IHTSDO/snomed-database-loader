--
-- Search
-- Find the active concepts with an 'acceptable' or 'preferred' synonym containing the words “disorder” and “lung”

SET @term='+disorder +lung';

SET @term= :search_phrase

SELECT CONCAT('SEARCH: ',@term) `term`,'' `conceptId`

UNION

SELECT term, conceptId
FROM sva_synall
WHERE MATCH (term) AGAINST 
(@term IN BOOLEAN MODE)
AND conceptId IN (SELECT id 
FROM sva_concept 
WHERE active = 1)
ORDER BY IF(conceptId='',0,length(term))