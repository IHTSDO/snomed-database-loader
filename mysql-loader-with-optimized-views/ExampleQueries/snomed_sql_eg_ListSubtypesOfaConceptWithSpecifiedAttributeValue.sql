-- SNOMED SQL QUERY EXAMPLE : LIST PREFERRED TERM OF ALL SUBTYPES OF A CONCEPT

-- Find the Preferred Term of subtypes of the concept with id @supertypeid (set here to 19829001)
-- With an attribute with id @attributeid (here set to 116676008)
-- With a value equal to @valueid (here set to 79654002)

-- Equivalent to Expression Constraint: 
-- < 19829001 |disorder of lung|: 
-- 		116676008 |associated morphology| = 79654002 |edema|

-- This query uses the transitive closure table.

SET @supertypeid=19829001;
SET @attributeid=116676008;
SET @valueid=79654002;

SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc, sva_pref as pt
WHERE tc.supertypeId = @supertypeid 
AND pt.conceptId = tc.subtypeId
AND tc.subtypeId IN 
(SELECT sourceId FROM sva_relationship as r
WHERE r.active = 1 AND r.typeId = @attributeid
AND r.destinationId = @valueid)
ORDER BY pt.term;
