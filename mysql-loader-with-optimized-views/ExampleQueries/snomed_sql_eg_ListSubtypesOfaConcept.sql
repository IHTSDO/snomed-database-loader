-- SNOMED SQL QUERY EXAMPLE : LIST PREFERRED TERM OF ALL SUBTYPES OF A CONCEPT

-- Equivalent to Expression Constraint: < @conceptid
-- Find the Preferred Term of subtypes of the concept with id @conceptid (set here to 19829001) 

-- This query uses the transitive closure table.

SET @conceptid=19829001;

SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc, sva_pref as pt
WHERE tc.supertypeId = @conceptid 
AND pt.conceptId = tc.subtypeId
ORDER BY pt.term

