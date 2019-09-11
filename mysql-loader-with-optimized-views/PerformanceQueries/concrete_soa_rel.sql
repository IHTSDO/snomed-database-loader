# This script replaces the soa_relationship VIEW with the soa_relationship table
# Major improvement in attribute relationship queries

DROP VIEW IF EXISTS `soa_relationship`;

CREATE TABLE `soa_relationship` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `effectiveTime` datetime NOT NULL DEFAULT '2002-01-31 00:00:00',
  `active` tinyint(4) NOT NULL DEFAULT '0',
  `moduleId` bigint(20) NOT NULL DEFAULT '0',
  `sourceId` bigint(20) NOT NULL DEFAULT '0',
  `destinationId` bigint(20) NOT NULL DEFAULT '0',
  `relationshipGroup` int(11) NOT NULL DEFAULT '0',
  `typeId` bigint(20) NOT NULL DEFAULT '0',
  `characteristicTypeId` bigint(20) NOT NULL DEFAULT '0',
  `modifierId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`effectiveTime`),
  KEY `soa_relationship_sd1` (`sourceId`,`destinationId`),
  KEY `soa_relationship_ts1` (`typeId`,`sourceId`),
  KEY `soa_relationship_td1` (`typeId`,`destinationId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `sctdb`.`soa_relationship`
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`)
SELECT `id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`
FROM `sva_relationship`;


