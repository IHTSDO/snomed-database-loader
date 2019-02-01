-- SNOMED SQL QUERY EXAMPLE : LIST PREFERRED TERM OF ALL SUBTYPES OF A CONCEPT

-- Find the Preferred Term of subtypes of the concept with id @supertypeid (set here to 404684003)
-- With an attribute with id @attributeid1 (here set to 363698007)
-- With a value equal to or a subtype of @valueid1 (here set to 39057004)
-- AND
-- With an attribute with id @attributeid2 (here set to 116676008)
-- With a value equal to or a subtype of @valueid2 (here set to 415582006)

-- Find the clinical findings with a finding site of pulmonary valve (or subtype) and an 
-- associated morphology of stenosis (or subtype)
-- Expression Constraint: < 404684003 |clinical finding|:
--                              363698007 |finding site| = << 39057004 |pulmonary valve|,
--                              116676008 |associated morphology| = << 415582006 |stenosis|
--
-- NOTE THIS QUERY IS SLOW
--  It typically takes between 1 and 2 minutes to run!
--  This is because ...
--  a) There are over 100,000 subtypes of Clinical Finding
--  b) Two attribute are being tested
--  c) Overall the query is complex
-- ALSO NOTE THERE IS A FASTER VERSION OF THIS QUERY!
-- Please see: 
--     snomed_sql_eg_ListSubtypesOfaConceptWithMultipleSpecifiedAttributeValues_fast.sql

SET @supertypeid=404684003;
SET @attributeid1=363698007;
SET @valueid1=39057004;
SET @attributeid2=116676008;
SET @valueid2=415582006;

SELECT tc.subtypeId, pt.term
FROM ss_transclose as tc, sva_pref as pt
WHERE tc.supertypeId = @supertypeid AND pt.conceptId = tc.subtypeId 

AND tc.subtypeId IN (SELECT sourceId FROM sva_relationship as r
WHERE r.active = 1 AND r.typeId = @attributeid1 
AND (r.destinationId = @valueid1 OR r.destinationId IN
(SELECT tc2.subtypeID FROM ss_transclose as tc2
WHERE tc2.supertypeId = @valueid1 )))

AND tc.subtypeId IN (SELECT sourceId FROM sva_relationship as r 
WHERE r.active = 1 AND r.typeId = @attributeid2 
AND (r.destinationId = @valueid2 OR r.destinationId IN
(SELECT tc2.subtypeID FROM ss_transclose as tc2
WHERE tc2.supertypeId = @valueid2 )))
ORDER BY pt.term;
