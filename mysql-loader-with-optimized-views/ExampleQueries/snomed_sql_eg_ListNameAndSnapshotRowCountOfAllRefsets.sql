-- SNOMED SQL QUERY EXAMPLE : LIST THE NAMES OF REFSETS OF SPECIFIED TYPES

-- Also returns the count of the number of rows in the current snapshot of each refset

-- Add other refset tables following the same style to included these in the results

DROP TABLE IF EXISTS `ids`;
CREATE TEMPORARY TABLE `ids`
(`id` BIGINT(10),`refsetType` text, `rowCount` BIGINT(10)); 


INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Association',COUNT(`id`)  FROM `soa_refset_association` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Attribute Value',COUNT(`id`)  FROM `soa_refset_attributeValue` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Description Type',COUNT(`id`)  FROM `sct_refset_descriptiontype` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Extended Map',COUNT(`id`)  FROM `soa_refset_extendedmap` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Language',COUNT(`id`)  FROM `soa_refset_language` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'MRCM Attribute Domain',COUNT(`id`)  FROM `soa_refset_MRCMAttributeDomain` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'MRCM Attribute Range',COUNT(`id`)  FROM `soa_refset_MRCMAttributeRange` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'MRCM Domain',COUNT(`id`)  FROM `soa_refset_MRCMDomain` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'MRCM Module Scope',COUNT(`id`)  FROM `soa_refset_MRCMModuleScope` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Module Dependency',COUNT(`id`)  FROM `soa_refset_ModuleDependency` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'OWL Expression',COUNT(`id`)  FROM `soa_refset_owlexpression` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'RefsetDescriptor',COUNT(`id`)  FROM `soa_refset_RefsetDescriptor` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Simple',COUNT(`id`)  FROM `soa_refset_simple` GROUP BY `refsetId`;

INSERT INTO `ids` (`id`,`refsetType`,`rowCount`)
SELECT DISTINCT `refsetId`,'Simple Map',COUNT(`id`) FROM `soa_refset_simplemap` GROUP BY `refsetId`;

SELECT `refsetType` 'Type', `conceptId` 'id', `term` 'name',`ids`.`rowCount`  FROM `soa_pref` JOIN `ids` ON `ids`.`id`=`conceptId` ORDER BY `refsetType`,`term`;


