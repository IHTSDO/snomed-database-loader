-- The following three queries return information about concept inactivations in last three releases
SELECT * FROM delta_inactive_concepts;
SELECT * FROM delta1_inactive_concepts;
SELECT * FROM delta2_inactive_concepts;
-- The following query return historical information about all inactive concepts in the current snapshot
SELECT * FROM delta2_inactive_concepts;