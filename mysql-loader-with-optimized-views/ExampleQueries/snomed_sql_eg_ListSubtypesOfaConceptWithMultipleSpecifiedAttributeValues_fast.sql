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

-- THIS IS AN OPTIMIZED VERSION OF:
--    snomed_sql_eg_ListSubtypesOfaConceptWithMultipleSpecifiedAttributeValues_slow.sql
-- Unlike the slower version it run the individual tests separately and then logically combines them.
-- While the slow version takes between 1 and 2 minutes to run, this version returns exactly the same result 2 or 3 seconds.

SET @supertypeid=404684003;
SET @attributeid1=363698007;
SET @valueid1=39057004;
SET @attributeid2=116676008;
SET @valueid2=415582006;--

DROP TABLE IF EXISTS tmp1;
DROP TABLE IF EXISTS tmp2;
DROP TABLE IF EXISTS tmp3;

-- Create temporary tables
CREATE TEMPORARY TABLE IF NOT EXISTS tmp1 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp2 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp3 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END OF PREPARATION STEPS

-- ADD ALL CONCEPTS PASSING THE SUBSUMPTION TEST TO A TEMPORARY TABLE 1
INSERT INTO tmp1 SELECT subtypeId FROM ss_transclose as tc WHERE tc.supertypeId = @supertypeid;

-- ADD ALL CONCEPTS PASSING THE FIRST ATTRIBUTE VALUE TEST TO TEMPORARY TABLE 2
INSERT INTO tmp2 SELECT DISTINCT sourceId FROM sva_relationship as r WHERE r.active = 1 AND r.typeId = @attributeid1 
AND (r.destinationId = @valueid1 OR r.destinationId IN
(SELECT tc.subTypeId FROM ss_transclose as tc
WHERE tc.supertypeId = @valueid1 ));

-- ADD ALL CONCEPTS PASSING THE SECOND ATTRIBUTE VALUE TEST TO TEMPORARY TABLE 3
INSERT INTO tmp3 SELECT DISTINCT sourceId FROM sva_relationship as r WHERE r.active = 1 AND r.typeId = @attributeid2 
AND (r.destinationId = @valueid2 OR r.destinationId IN
(SELECT tc.subTypeId FROM ss_transclose as tc
WHERE tc.supertypeId = @valueid2 ));

-- LIST ALL THE CONCEPT THAT ARE IN ALL THREE TEMPORARY TABLES
SELECT pt.conceptId,pt.term
FROM tmp1, sva_pref as pt
WHERE  pt.conceptId = tmp1.id 
AND tmp1.id IN (SELECT id FROM tmp2)
AND tmp1.id IN (SELECT id FROM tmp3)
ORDER BY pt.term;

-- Remove the temporary tables
DROP TABLE IF EXISTS tmp1;
DROP TABLE IF EXISTS tmp2;
DROP TABLE IF EXISTS tmp3;
