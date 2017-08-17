--
-- QUERY 3
-- Find all the subtypes of lung disorder
-- Expression Constraint: < 19829001 |disorder of lung|
--
SELECT tc.subtypeId, pt.term
FROM snomedct.ss_transclose as tc, snomedct.sva_pref as pt
WHERE tc.supertypeId = 19829001 
AND pt.conceptId = tc.subtypeId
ORDER BY pt.term
