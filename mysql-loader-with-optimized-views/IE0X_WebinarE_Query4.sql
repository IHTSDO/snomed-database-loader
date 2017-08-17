--
-- QUERY 3
-- Find the lung disorders with an associated morphology equal to edema
-- Expression Constraint: < 19829001 |disorder of lung|: 116676008 |associated morphology| = 79654002 |edema|
--
SELECT tc.subtypeId, pt.term
FROM snomedct.ss_transclose as tc, 
snomedct.sva_pref as pt
WHERE tc.supertypeId = 19829001 
AND pt.conceptId = tc.subtypeId
AND tc.subtypeId IN 
(SELECT sourceId FROM snomedct.sva_relationship as r
WHERE r.active = 1 AND r.typeId = 116676008
AND r.destinationId = 79654002)
ORDER BY pt.term;


