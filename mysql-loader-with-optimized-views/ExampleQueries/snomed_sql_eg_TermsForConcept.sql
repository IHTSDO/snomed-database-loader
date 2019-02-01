-- SNOMED SQL QUERY EXAMPLE : FIND TERMS FOR A CONCEPT
-- 
-- Find the Terms associated with a concept with id “19829001” 
--

SET @concept=19829001;

SELECT 'FSN' `type` ,conceptId, term 
FROM sva_fsn
WHERE conceptId = @concept

UNION

SELECT 'Syn [Preferred]' ,conceptId, term 
FROM sva_pref
WHERE conceptId = @concept

UNION

SELECT 'Syn [Acceptable]' ,conceptId, term 
FROM sva_syn
WHERE conceptId = @concept;



