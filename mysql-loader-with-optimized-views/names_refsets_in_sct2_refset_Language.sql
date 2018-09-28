DROP TABLE IF EXISTS ids;
CREATE TEMPORARY TABLE ids
(id BIGINT(10)); 

INSERT INTO ids
(SELECT DISTINCT refsetId FROM soa_refset_Language);

SELECT Concat(" {concept:t=",conceptId," ",term) FROM soa_pref JOIN ids ON ids.id=conceptId;


