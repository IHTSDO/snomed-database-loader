-- SNOMED SQL QUERY EXAMPLE : SEARCH FOR CONCEPTS BY WORDS
-- 
-- Find the active concepts with an 'acceptable' or 'preferred' synonym 
-- containing the words “disorder” and “lung”

-- Change the search terms in the following line to alter the search
-- (Note: + means must include word)

SET @search = '+disorder +lung';

SELECT conceptId, term 
FROM sva_synall
WHERE MATCH (term) AGAINST 
(@search IN BOOLEAN MODE)
AND conceptId IN (SELECT id 
FROM sva_concept 
WHERE active = 1)
UNION
SELECT 'SEARCH:',@search
ORDER BY IF(`conceptId`='SEARCH:',0,length(term));




