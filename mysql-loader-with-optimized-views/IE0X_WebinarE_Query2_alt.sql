SELECT d.*
FROM (sva_description d
JOIN sva_refset_Language l ON d.id = l.referencedComponentId)
WHERE d.active = 1
  AND l.active = 1
  AND d.conceptId = 19829001
  AND d.typeId = 900000000000013009
  AND l.refsetId = 900000000000509007
  AND l.attribute1 = 900000000000548007;