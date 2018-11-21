SELECT * FROM `sct_concept`;

SELECT * FROM `sct_description`;

SELECT * FROM `sct_relationship`;

SELECT * FROM `sct_refset_Language`;

SELECT * FROM `ss_transclose`;

SELECT 'sct_concept',count(*) count FROM `sct_concept`
UNION
SELECT 'sct_description', count(*) FROM `sct_description`
UNION
SELECT 'sct_relationship', count(*) FROM `sct_relationship`
UNION
SELECT 'sct_refset_Language', count(*) FROM `sct_refset_Language`
UNION
SELECT 'ss_concept', count(*) FROM `soa_concept`
UNION
SELECT 'ss_description', count(*) FROM `soa_description`
UNION
SELECT 'ss_relationship', count(*) FROM `soa_relationship`
UNION
SELECT 'ss_refset_Language', count(*) FROM `soa_refset_Language`
UNION
SELECT 'ss_transclose', count(*) FROM `ss_transclose`;
