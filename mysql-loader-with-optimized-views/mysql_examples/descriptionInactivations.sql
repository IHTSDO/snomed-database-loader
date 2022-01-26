-- The following three queries return information about description inactivations in last three releases
SELECT * FROM delta_inactive_descriptions;
SELECT * FROM delta1_inactive_descriptions;
SELECT * FROM delta2_inactive_descriptions;
-- The following query return historical information about all inactive descriptions in the current snapshot
SELECT * FROM snap_inactive_descriptions;