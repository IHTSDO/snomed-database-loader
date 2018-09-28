--
-- QUERY 6
-- Find the clinical findings with a finding site of pulmonary valve (or subtype) and an associated morphology of stenosis (or subtype)
-- Expression Constraint: < 404684003 |clinical finding|:
--                              363698007 |finding site| = << 39057004 |pulmonary valve|,
--                              116676008 |associated morphology| = << 415582006 |stenosis|
--
DROP TABLE IF EXISTS tmp1;
DROP TABLE IF EXISTS tmp2;
DROP TABLE IF EXISTS tmp3;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp1 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO tmp1 SELECT subtypeId FROM ss_transclose as tc WHERE tc.supertypeId = 404684003;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp2 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO tmp2 SELECT DISTINCT sourceId FROM sva_relationship as r WHERE r.active = 1 AND r.typeId = 363698007 
AND (r.destinationId = 39057004 OR r.destinationId IN
(SELECT tc2.subTypeId FROM ss_transclose as tc2
WHERE tc2.supertypeId = 39057004 ));

CREATE TEMPORARY TABLE IF NOT EXISTS tmp3 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO tmp3 SELECT DISTINCT sourceId FROM sva_relationship as r WHERE r.active = 1 AND r.typeId = 116676008 
AND (r.destinationId = 415582006 OR r.destinationId IN
(SELECT tc2.subTypeId FROM ss_transclose as tc2
WHERE tc2.supertypeId = 415582006 ));

SELECT pt.conceptId,pt.term
FROM tmp1, sva_pref as pt
WHERE  pt.conceptId = tmp1.id 
AND tmp1.id IN (SELECT id FROM tmp2)
AND tmp1.id IN (SELECT id FROM tmp3)
ORDER BY pt.term;

DROP TABLE IF EXISTS tmp1;
DROP TABLE IF EXISTS tmp2;
DROP TABLE IF EXISTS tmp3;
