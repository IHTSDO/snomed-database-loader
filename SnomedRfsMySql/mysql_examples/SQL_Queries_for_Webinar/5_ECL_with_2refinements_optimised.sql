--
-- Find the clinical findings with a finding site of pulmonary valve (or subtype) and an associated morphology of stenosis (or subtype)
-- Expression Constraint: < 404684003 |clinical finding|:
--                              363698007 |finding site| = << 39057004 |pulmonary valve|,
--                              116676008 |associated morphology| = << 415582006 |stenosis|

-- Delete temporary tables in case they were not destroyed earlier (this is redundant since we do this at the end)
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

INSERT INTO tmp1 SELECT subtypeId FROM snap_transclose as tc WHERE tc.supertypeId = 404684003;

INSERT INTO tmp2 SELECT DISTINCT sourceId FROM snap_relationship as r WHERE r.active = 1 AND r.typeId = 363698007 
AND (r.destinationId = 39057004 OR r.destinationId IN
(SELECT tc2.subTypeId FROM snap_transclose as tc2
WHERE tc2.supertypeId = 39057004 ));


INSERT INTO tmp3 SELECT DISTINCT sourceId FROM snap_relationship as r WHERE r.active = 1 AND r.typeId = 116676008 
AND (r.destinationId = 415582006 OR r.destinationId IN
(SELECT tc2.subTypeId FROM snap_transclose as tc2
WHERE tc2.supertypeId = 415582006 ));

-- Show the concepts that are in all three of the temporary tables
-- these meet all the specified criteria
SELECT pt.conceptId,pt.term
FROM tmp1, snap_pref as pt
WHERE  pt.conceptId = tmp1.id 
AND tmp1.id IN (SELECT id FROM tmp2)
AND tmp1.id IN (SELECT id FROM tmp3)
ORDER BY pt.term;

-- Remove the temporary tables
DROP TABLE IF EXISTS tmp1;
DROP TABLE IF EXISTS tmp2;
DROP TABLE IF EXISTS tmp3;
