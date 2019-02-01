-- SNOMED SQL QUERY EXAMPLE : SHOWS THE RAW SQL CODE TO GET THE PREFERRED SYNONYM IN A LANGUAGE

SET @conceptid=19829001;

SELECT 'Directly using the full tables' `Example`,`d`.`conceptid`,`d`.`id` `descriptionid`,`d`.`term`
FROM `sct_description` `d`
JOIN `sct_refset_Language` `l` ON `d`.`id` = `l`.`referencedComponentId`
WHERE `d`.`active` = 1
AND `d`.`conceptId` = @conceptid
  AND `d`.`typeId` = 900000000000013009 -- SYNONYM
  AND `d`.`effectiveTime`=(SELECT MAX(`effectiveTime`) FROM `sct_description` WHERE `id`=`d`.`id`)
  AND `l`.`active` = 1
  AND `l`.`refsetId` = 900000000000509007 -- US Language Refset
  AND `l`.`acceptabilityId` = 900000000000548007 -- Preferred
  AND `l`.`effectiveTime`=(SELECT MAX(`effectiveTime`) FROM `sct_refset_Language` WHERE `id`=`l`.`id`) ;


-- Note - the sva_ or soa_ views simplify this as shown below removing the need include code to get the latest snapshot
  
SELECT 'Using sva_ snapshot views of full tables' `Example`,`d`.`conceptid`,`d`.`id` `descriptionid`,`d`.`term`
FROM `sva_description` `d`
JOIN `sva_refset_Language` `l` ON `d`.`id` = `l`.`referencedComponentId`
WHERE `d`.`active` = 1
AND `d`.`conceptId` = @conceptid
  AND `d`.`typeId` = 900000000000013009 -- SYNONYM
  AND `l`.`active` = 1
  AND `l`.`refsetId` = 900000000000509007 -- US Language Refset
  AND `l`.`acceptabilityId` = 900000000000548007;  -- Preferred 
  
-- Note - the sva_pref view further simplifies this as shown below as it provides all the other constraints on values
  
  SELECT 'Using the sva_pref Preferred Term snapshot' `Example`,`conceptid`,`id` `descriptionid`,`term`
  FROM `sva_pref`   WHERE `conceptid`= @conceptid;