--
-- Find the Preferred Term of subtypes of the concept with id “19829001” 
-- Expression Constraint: < 19829001
--
SELECT tc.subtypeId, pt.term -- select these columns
FROM snap_transclose as tc, snap_pref as pt -- from snapshot transitive closure table and snapshot of preferred terms
WHERE tc.supertypeId = 19829001 -- where the value in the transitive closure supertype column is equal to this SCTID
AND pt.conceptId = tc.subtypeId -- and the value in preferred term conceptId column is equal to the value in the trasitive closure subtypeId column
ORDER BY pt.term -- sort alphabetically by preferred term