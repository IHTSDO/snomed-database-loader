--
-- QUERY 2
-- Find the Preferred Term of subtypes of the concept with id “19829001” 
-- Expression Constraint: < 19829001
--
SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc, sva_pref as pt
WHERE tc.supertypeId = 19829001 
AND pt.conceptId = tc.subtypeId
ORDER BY pt.term

