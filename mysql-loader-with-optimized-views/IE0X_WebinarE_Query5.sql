--
-- QUERY 5
-- Find the lung disorders with an associated morphology of edema (or subtype)
-- Expression Constraint: < 19829001 |disorder of lung|: 116676008 |associated morphology|
-- = << 79654002 |edema|

SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc, sva_pref as pt
WHERE tc.supertypeId = 19829001 
AND pt.conceptId = tc.subtypeId 
AND tc.subtypeId IN
(SELECT sourceId FROM sva_relationship as r
WHERE r.active = 1 AND r.typeId = 116676008 
AND (r.destinationId = 79654002 
OR r.destinationId IN -- or any descendants of edema
(SELECT tc2.subtypeID
FROM ss_transclose as tc2
WHERE tc2.supertypeId = 79654002)))
ORDER BY pt.term





