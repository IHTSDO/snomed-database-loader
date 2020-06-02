-- Preferred synonym for concept 80146002
SELECT d.* FROM
       snap_description d
   JOIN 
	   snap_refset_language rs ON d.id = rs.referencedComponentId
   WHERE d.conceptId = 80146002
       AND d.active = 1 AND rs.active = 1
       AND d.typeId = 900000000000013009 -- Synonym
     AND rs.refsetId = 900000000000509007 -- US Language Refset
   --   AND rs.refsetId = 900000000000508004 -- GB Language Refset     
	   AND rs.acceptabilityId = 900000000000548007; -- Preferred Acceptability