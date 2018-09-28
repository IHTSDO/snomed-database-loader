--
-- QUERY 6
-- Find the clinical findings with a finding site of pulmonary valve (or subtype) and an 
-- associated morphology of stenosis (or subtype)
-- Expression Constraint: < 404684003 |clinical finding|:
--                              363698007 |finding site| = << 39057004 |pulmonary valve|,
--                              116676008 |associated morphology| = << 415582006 |stenosis|
--
SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc, sva_pref as pt
WHERE tc.supertypeId = 404684003 AND pt.conceptId = tc.subtypeId 

AND tc.subtypeId IN (SELECT sourceId FROM sva_relationship as r
WHERE r.active = 1 AND r.typeId = 363698007 
AND (r.destinationId = 39057004 OR r.destinationId IN
(SELECT tc2.subtypeID FROM ss_transclose as tc2
WHERE tc2.supertypeId = 39057004 )))

AND tc.subtypeId IN (SELECT sourceId FROM sva_relationship as r 
WHERE r.active = 1 AND r.typeId = 116676008 
AND (r.destinationId = 415582006 OR r.destinationId IN
(SELECT tc2.subtypeID FROM ss_transclose as tc2
WHERE tc2.supertypeId = 415582006 )))
ORDER BY pt.term
