-- SNOMED SQL QUERY EXAMPLE : SHOWS 100 ROWS OF RAW DATA FROM EACH TABLE

-- Add other refset tables following the same style to included these in the results

SELECT * FROM `sct_concept` ORDER BY `id` LIMIT 100;

SELECT * FROM `sct_description` ORDER BY `id` LIMIT 100;

SELECT * FROM `sct_relationship` ORDER BY `id` LIMIT 100;

SELECT * FROM `ss_transclose` ORDER BY `subtypeid` LIMIT 100;

