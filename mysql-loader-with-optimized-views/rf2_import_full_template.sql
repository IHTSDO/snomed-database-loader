-- IMPORTS SNOMED CT RF2 FULL RELEASE INTO MYSQL DATA BASE

-- MySQL Script David Markwell developed in 2011 - Apache 1.2 license applies

-- ------------------------------------------------------------------------
-- Copyright 2011 David C Markwell 

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- NOTES 
-- Imports FULL release from folder: $PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/
-- Adjust source folder by replacing all instances of the above path with required path
-- Adjust release date by replacing all instances of INT_$YYYYMMDD$ with appropriate INT_YYYYMMDD
-- At or about line 455 add lines like the following for each release date - replace YYYY-MM-DD with the required Snapshot view dates.

-- INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 1,900000000000509007,'YYYY-MM-DD',0,'YYYY-MM-DD Lang:en-US'$$
-- INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 2,900000000000508004,'YYYY-MM-DD',0,'YYYY-MM-DD Lang:en-GB'$$
-- These line create a configuration for setting a snapshot view for those dates
-- in each of the languages or dialect in the import (en-US and en-GB).
-- The active view is specified by a 1 in the column between the two instance of the date

-- The script creates tables, imports, indexes and generates a range of views of the tables including some linked views that are useful for
-- viewing particular types of data.

-- Most of the examples in the SNOMED CT TIG http://snomed.org/tig.pdf are built on the results of this import.


-- *********************************************************************************************
-- PART 1
-- CREATES TABLES  - THIS PART DOES NOT REQUIRE CONFIGURATION FOR EACH RELEASE
--
-- NEW TABLES MAY NEED TO BE CREATED FOR ADDITIONAL REFSETS FOLLOWING SAME PATTERNS AS THOSE
-- ALREADY PRESENT BUT TAKING ACCOUNT OF ADDITIONAL ATTRIBUTES
-- *********************************************************************************************


DELIMITER $$
DROP DATABASE IF EXISTS `snomedct`$$ 
CREATE DATABASE `snomedct` /*!40100 DEFAULT CHARACTER SET utf8 */$$
SET GLOBAL net_write_timeout = 60$$ 
SET GLOBAL net_read_timeout=120$$
USE snomedct$$



-- CREATE TABLES

-- CREATE TABLE  `sct2_concept`

CREATE TABLE `sct2_concept` (
`id` BIGINT NOT NULL DEFAULT  0,
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`definitionStatusId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$

-- CREATE TABLE  `sct2_description`

DROP TABLE IF EXISTS `sct2_description`$$

CREATE TABLE `sct2_description` (
`id` BIGINT NOT NULL DEFAULT  0,
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`conceptId` BIGINT NOT NULL DEFAULT  0,
`languageCode` VARCHAR (3) NOT NULL DEFAULT  '',
`typeId` BIGINT NOT NULL DEFAULT  0,
`term` VARCHAR (255) NOT NULL DEFAULT  '',
`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE TABLE  `sct2_identifier`

DROP TABLE IF EXISTS `sct2_identifier`$$

CREATE TABLE `sct2_identifier` (
`identifierSchemeId` BIGINT NOT NULL DEFAULT  0,
`alternateIdentifier` VARCHAR (255) NOT NULL DEFAULT  '',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`identifierSchemeId`,`alternateIdentifier`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE TABLE  `sct2_relationship`

DROP TABLE IF EXISTS `sct2_relationship`$$

CREATE TABLE `sct2_relationship` (
`id` BIGINT NOT NULL DEFAULT  0,
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`sourceId` BIGINT NOT NULL DEFAULT  0,
`destinationId` BIGINT NOT NULL DEFAULT  0,
`relationshipGroup` INT NOT NULL DEFAULT  0,
`typeId` BIGINT NOT NULL DEFAULT  0,
`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
`modifierId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE TABLE  `sct2_statedrelationship`

DROP TABLE IF EXISTS `sct2_statedrelationship`$$

CREATE TABLE `sct2_statedrelationship` (
`id` BIGINT NOT NULL DEFAULT  0,
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`sourceId` BIGINT NOT NULL DEFAULT  0,
`destinationId` BIGINT NOT NULL DEFAULT  0,
`relationshipGroup` INT NOT NULL DEFAULT  0,
`typeId` BIGINT NOT NULL DEFAULT  0,
`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
`modifierId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE TABLE  `sct2_textdefinition`

DROP TABLE IF EXISTS `sct2_textdefinition`$$

CREATE TABLE `sct2_textdefinition` (
`id` BIGINT NOT NULL DEFAULT  0,
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`conceptId` BIGINT NOT NULL DEFAULT  0,
`languageCode` VARCHAR (3) NOT NULL DEFAULT  '',
`typeId` BIGINT NOT NULL DEFAULT  0,
`term` VARCHAR (4096) NOT NULL DEFAULT  '',
`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_c`$$

CREATE TABLE `sct2_refset_c` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`attribute1` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset`$$

CREATE TABLE `sct2_refset` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_iissscc`$$

CREATE TABLE `sct2_refset_iissscc` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`attribute1` INT NOT NULL DEFAULT  0,
`attribute2` INT NOT NULL DEFAULT  0,
`attribute3` VARCHAR (255) NOT NULL DEFAULT  '',
`attribute4` VARCHAR (255) NOT NULL DEFAULT  '',
`attribute5` VARCHAR (255) NOT NULL DEFAULT  '',
`attribute6` BIGINT NOT NULL DEFAULT  0,
`attribute7` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_iisssc`$$

CREATE TABLE `sct2_refset_iisssc` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`attribute1` INT NOT NULL DEFAULT  0,
`attribute2` INT NOT NULL DEFAULT  0,
`attribute3` VARCHAR (255) NOT NULL DEFAULT  '',
`attribute4` VARCHAR (255) NOT NULL DEFAULT  '',
`attribute5` VARCHAR (255) NOT NULL DEFAULT  '',
`attribute6` BIGINT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_s`$$

CREATE TABLE `sct2_refset_s` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`attribute1` VARCHAR (255) NOT NULL DEFAULT  '',
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_cci`$$

CREATE TABLE `sct2_refset_cci` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`attribute1` BIGINT NOT NULL DEFAULT  0,
`attribute2` BIGINT NOT NULL DEFAULT  0,
`attribute3` INT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_ci`$$

CREATE TABLE `sct2_refset_ci` (
`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
`active` TINYINT NOT NULL DEFAULT  0,
`moduleId` BIGINT NOT NULL DEFAULT  0,
`refSetId` BIGINT NOT NULL DEFAULT  0,
`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
`attribute1` BIGINT NOT NULL DEFAULT  0,
`attribute2` INT NOT NULL DEFAULT  0,
`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
PRIMARY KEY (`id`,`effectiveTime`))
ENGINE=MyISAM DEFAULT CHARSET=utf8;$$


-- CREATE sct2_refset

DROP TABLE IF EXISTS `sct2_refset_ss`$$

CREATE TABLE `sct2_refset_ss` (
    `id` BINARY(16) NOT NULL DEFAULT '',
    `effectiveTime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
    `active` TINYINT NOT NULL DEFAULT 0,
    `moduleId` BIGINT NOT NULL DEFAULT 0,
    `refSetId` BIGINT NOT NULL DEFAULT 0,
    `referencedComponentId` BIGINT NOT NULL DEFAULT 0,
    `attribute1` VARCHAR(255) NOT NULL DEFAULT '',
    `attribute2` VARCHAR(255) NOT NULL DEFAULT '',
    `supersededTime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY (`id` , `effectiveTime`)
)  ENGINE=MYISAM DEFAULT CHARSET=UTF8;$$

-- ***********************************************************************************
-- PART 2
-- LOAD PART FILE
--
-- THIS IS THE PART THAT REQUIRES CONFIGURATION FOR EACH RELEASE
-- $PATH$ OF FILES AND $YYYMMDD$ DATE STAMP
--
-- NEW TABLES MAY NEED TO BE IMPORTED FOR ADDITIONAL REFSETS FOLLOWING SAME PATTERNS AS THOSE
-- ALREADY PRESENT BUT TAKING ACCOUNT OF ADDITIONAL ATTRIBUTES
-- ***********************************************************************************

DELIMITER $$
USE snomedct$$

-- LOAD FILES INTO TABLES

LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Terminology/sct2_Concept_Full_INT_$YYYYMMDD$.txt'
INTO TABLE sct2_concept
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES

(`id`,`effectiveTime`,`active`,`moduleId`,`definitionStatusId`);$$

LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Terminology/sct2_Description_Full-en_INT_$YYYYMMDD$.txt'
INTO TABLE sct2_description
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES

(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Terminology/sct2_Identifier_Full_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_identifier`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES

(`identifierSchemeId`,`alternateIdentifier`,`effectiveTime`,`active`,`moduleId`,`referencedComponentId`);$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Terminology/sct2_Relationship_Full_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_relationship`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES

(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Terminology/sct2_StatedRelationship_Full_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_statedrelationship`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES

(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Terminology/sct2_TextDefinition_Full-en_INT_$YYYYMMDD$.txt'
INTO TABLE sct2_textdefinition
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES

(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Content/der2_cRefset_AssociationReferenceFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_c`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Content/der2_cRefset_AttributeValueFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_c`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Content/der2_Refset_SimpleFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` )
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Language/der2_cRefset_LanguageFull-en_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_c`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Map/der2_iisssccRefset_ExtendedMapFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_iissscc`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,`attribute7`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Map/der2_iissscRefset_ComplexMapFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_iisssc`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Map/der2_sRefset_SimpleMapFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_s`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Metadata/der2_cciRefset_RefsetDescriptorFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_cci`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`,`attribute2`,`attribute3`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Metadata/der2_ciRefset_DescriptionTypeFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_ci`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`,`attribute2`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$


LOAD DATA LOCAL INFILE '$PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/Full/Refset/Metadata/der2_ssRefset_ModuleDependencyFull_INT_$YYYYMMDD$.txt'
INTO TABLE `sct2_refset_ss`
LINES TERMINATED BY '\r\n'
 IGNORE 1 LINES
(@uid_id,`effectiveTime`,`active`,`moduleId`,`refSetId`,`referencedComponentId` ,`attribute1`,`attribute2`)
SET `id`=UNHEX(REPLACE(@uid_id,'-',''));$$

-- *********************************************************************************************
-- PART 3
-- VIEWS AND INDEXING PART OF SCRIPT - THIS PART DOES NOT REQUIRE CONFIGURATION FOR EACH RELEASE
--
-- NEW VIEWS AND INDEXES MAY BE NEEDED FOR ADDITIONAL REFSETS FOLLOWING SAME PATTERNS AS THOSE
-- ALREADY PRESENT BUT TAKING ACCOUNT OF ADDITIONAL ATTRIBUTES
-- *********************************************************************************************


DELIMITER $$
USE snomedct$$

-- CREATE CONFIG FILE AND RELATED FUNCTIONS

-- CREATE config

DROP TABLE IF EXISTS `config`;$$

CREATE TABLE `config` (`id` int(11) NOT NULL DEFAULT '0',`languageId` bigint(20) DEFAULT '0',`versionTime` datetime DEFAULT '9999-12-31 00:00:00',`active` tinyint(4) DEFAULT '0',`name` varchar(255) DEFAULT '',PRIMARY KEY (`id`),KEY `config_active` (`active`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;$$

DROP FUNCTION IF EXISTS `ShowUid`$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ShowUid`(Uid blob) RETURNS varchar(36) CHARSET utf8
BEGIN
SET @Tmp = Hex(uid);
RETURN CONCAT(SUBSTRING(@Tmp,1,8),'-',SUBSTRING(@Tmp,9,4),'-',SUBSTRING(@Tmp,13,4),'-',SUBSTRING(@Tmp,17,4),'-',SUBSTRING(@Tmp,21));
END$$

DROP VIEW IF EXISTS `config_v`;$$

CREATE VIEW `config_v` AS select `config`.`languageId` AS `languageId`,`config`.`versionTime` AS `versionTime` from `config` where (`config`.`active` = 1) limit 1;$$

DROP FUNCTION IF EXISTS `configTime`;$$

CREATE DEFINER=`root`@`localhost` FUNCTION `configTime`() RETURNS datetime
BEGIN
    RETURN(SELECT `versionTime` FROM `config_v`);
END$$

DROP FUNCTION IF EXISTS `configLangId`;$$

CREATE FUNCTION `configLangId`() RETURNS bigint(20)
BEGIN
    RETURN(SELECT `languageId` FROM `config_v`);
END$$

DROP FUNCTION IF EXISTS `allversions`;$$

CREATE VIEW `allversions` AS select distinct `config`.`versionTime` AS `versionTime` from `config`$$

INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 1,900000000000509007,'2015-07-31',1,'2015-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 2,900000000000508004,'2015-07-31',0,'2015-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 3,900000000000509007,'2015-01-31',0,'2015-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 4,900000000000508004,'2015-01-31',0,'2015-01-31 Lang:en-GB'$$ 
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 5,900000000000509007,'2016-07-31',0,'2016-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 6,900000000000508004,'2016-07-31',0,'2016-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 7,900000000000509007,'2016-01-31',0,'2016-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 8,900000000000508004,'2016-01-31',0,'2016-01-31 Lang:en-GB'$$ 
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 9,900000000000509007,'2017-01-31',0,'2017-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 10,900000000000508004,'2017-01-31',0,'2017-01-31 Lang:en-GB'$$ 
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 61,900000000000509007,'2014-07-31',0,'2014-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 62,900000000000508004,'2014-07-31',0,'2014-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 63,900000000000509007,'2014-01-31',0,'2014-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 64,900000000000508004,'2014-01-31',0,'2014-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 65,900000000000509007,'2013-07-31',0,'2013-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 66,900000000000508004,'2013-07-31',0,'2013-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 67,900000000000509007,'2013-01-31',0,'2013-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 68,900000000000508004,'2013-01-31',0,'2013-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 69,900000000000509007,'2012-07-31',0,'2012-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 70,900000000000508004,'2012-07-31',0,'2012-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 11,900000000000509007,'2012-01-31',0,'2012-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 12,900000000000508004,'2012-01-31',0,'2012-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 13,900000000000509007,'2011-07-31',0,'2011-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 14,900000000000508004,'2011-07-31',0,'2011-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 15,900000000000509007,'2011-01-31',0,'2011-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 16,900000000000508004,'2011-01-31',0,'2011-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 17,900000000000509007,'2010-07-31',0,'2010-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 18,900000000000508004,'2010-07-31',0,'2010-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 19,900000000000509007,'2010-01-31',0,'2010-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 20,900000000000508004,'2010-01-31',0,'2010-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 21,900000000000509007,'2009-07-31',0,'2009-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 22,900000000000508004,'2009-07-31',0,'2009-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 23,900000000000509007,'2009-01-31',0,'2009-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 24,900000000000508004,'2009-01-31',0,'2009-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 25,900000000000509007,'2008-07-31',0,'2008-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 26,900000000000508004,'2008-07-31',0,'2008-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 27,900000000000509007,'2008-01-31',0,'2008-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 28,900000000000508004,'2008-01-31',0,'2008-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 29,900000000000509007,'2007-07-31',0,'2007-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 30,900000000000508004,'2007-07-31',0,'2007-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 31,900000000000509007,'2007-01-31',0,'2007-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 32,900000000000508004,'2007-01-31',0,'2007-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 33,900000000000509007,'2006-07-31',0,'2006-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 34,900000000000508004,'2006-07-31',0,'2006-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 35,900000000000509007,'2006-01-31',0,'2006-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 36,900000000000508004,'2006-01-31',0,'2006-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 37,900000000000509007,'2005-07-31',0,'2005-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 38,900000000000508004,'2005-07-31',0,'2005-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 39,900000000000509007,'2005-01-31',0,'2005-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 40,900000000000508004,'2005-01-31',0,'2005-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 41,900000000000509007,'2004-07-31',0,'2004-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 42,900000000000508004,'2004-07-31',0,'2004-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 43,900000000000509007,'2004-01-31',0,'2004-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 44,900000000000508004,'2004-01-31',0,'2004-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 45,900000000000509007,'2003-07-31',0,'2003-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 46,900000000000508004,'2003-07-31',0,'2003-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 47,900000000000509007,'2003-01-31',0,'2003-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 48,900000000000508004,'2003-01-31',0,'2003-01-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 49,900000000000509007,'2002-07-31',0,'2002-07-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 50,900000000000508004,'2002-07-31',0,'2002-07-31 Lang:en-GB'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 51,900000000000509007,'2002-01-31',0,'2002-01-31 Lang:en-US'$$
INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 52,900000000000508004,'2002-01-31',0,'2002-01-31 Lang:en-GB'$$

DELIMITER $$
USE snomedct$$

-- CREATE UNOPTIMIZED VIEWS

DROP VIEW IF EXISTS `sva_concept`;$$

CREATE VIEW `sva_concept` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`definitionStatusId` AS `definitionStatusId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_concept` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_concept` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_concept'
DROP VIEW IF EXISTS `svx_concept`;$$

CREATE VIEW `svx_concept` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`definitionStatusId` AS `definitionStatusId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_concept` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_concept` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$


-- Views for 'sva of sct2_description'
DROP VIEW IF EXISTS `sva_description`;$$

CREATE VIEW `sva_description` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_description` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_description` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_description'
DROP VIEW IF EXISTS `svx_description`;$$

CREATE VIEW `svx_description` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_description` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_description` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

DROP VIEW IF EXISTS `sva_identifier`;$$

CREATE VIEW `sva_identifier` AS (select `c`.`identifierSchemeId` AS `identifierSchemeId`,`c`.`alternateIdentifier` AS `alternateIdentifier`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`referencedComponentId` AS `referencedComponentId`, `c`.`supersededTime` AS `supersededTime` from `sct2_identifier` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_identifier` `c2` where (`c2`.`identifierSchemeId` = `c`.`identifierSchemeId` and `c2`.`alternateIdentifier` = `c`.`alternateIdentifier`))))$$

DROP VIEW IF EXISTS `svx_identifier`;$$

CREATE VIEW `svx_identifier` AS (select `c`.`identifierSchemeId` AS `identifierSchemeId`,`c`.`alternateIdentifier` AS `alternateIdentifier`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`referencedComponentId` AS `referencedComponentId`,`c`.`supersededTime` AS `supersededTime` from `sct2_identifier` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_identifier` `c2` where (`c2`.`identifierSchemeId` = `c`.`identifierSchemeId` and `c2`.`alternateIdentifier` = `c`.`alternateIdentifier`) and (`c2`.`effectiveTime` <= `configTime`()))))$$

-- Views for 'sva of sct2_relationship'
DROP VIEW IF EXISTS `sva_relationship`;$$

CREATE VIEW `sva_relationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_relationship` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_relationship` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_relationship'
DROP VIEW IF EXISTS `svx_relationship`;$$

CREATE VIEW `svx_relationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_relationship` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_relationship` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_statedrelationship'
DROP VIEW IF EXISTS `sva_statedrelationship`;$$

CREATE VIEW `sva_statedrelationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_statedrelationship` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_statedrelationship` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_statedrelationship'
DROP VIEW IF EXISTS `svx_statedrelationship`;$$

CREATE VIEW `svx_statedrelationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_statedrelationship` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_statedrelationship` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_textdefinition'
DROP VIEW IF EXISTS `sva_textdefinition`;$$

CREATE VIEW `sva_textdefinition` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_textdefinition` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_textdefinition` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_textdefinition'
DROP VIEW IF EXISTS `svx_textdefinition`;$$

CREATE VIEW `svx_textdefinition` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_textdefinition` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_textdefinition` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_c'
DROP VIEW IF EXISTS `sva_refset_c`;$$

CREATE VIEW `sva_refset_c` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_c` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_c` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_c'
DROP VIEW IF EXISTS `svx_refset_c`;$$

CREATE VIEW `svx_refset_c` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_c` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_c` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset'
DROP VIEW IF EXISTS `sva_refset`;$$

CREATE VIEW `sva_refset` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset'
DROP VIEW IF EXISTS `svx_refset`;$$

CREATE VIEW `svx_refset` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_iissscc'
DROP VIEW IF EXISTS `sva_refset_iissscc`;$$

CREATE VIEW `sva_refset_iissscc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,`attribute7`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iissscc` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_iissscc` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_iissscc'
DROP VIEW IF EXISTS `svx_refset_iissscc`;$$

CREATE VIEW `svx_refset_iissscc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,`attribute7`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iissscc` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_iissscc` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_iisssc'
DROP VIEW IF EXISTS `sva_refset_iisssc`;$$

CREATE VIEW `sva_refset_iisssc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iisssc` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_iisssc` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_iisssc'
DROP VIEW IF EXISTS `svx_refset_iisssc`;$$

CREATE VIEW `svx_refset_iisssc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iisssc` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_iisssc` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_s'
DROP VIEW IF EXISTS `sva_refset_s`;$$

CREATE VIEW `sva_refset_s` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_s` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_s` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_s'
DROP VIEW IF EXISTS `svx_refset_s`;$$

CREATE VIEW `svx_refset_s` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_s` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_s` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_cci'
DROP VIEW IF EXISTS `sva_refset_cci`;$$

CREATE VIEW `sva_refset_cci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_cci` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_cci` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_cci'
DROP VIEW IF EXISTS `svx_refset_cci`;$$

CREATE VIEW `svx_refset_cci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_cci` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_cci` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_ci'
DROP VIEW IF EXISTS `sva_refset_ci`;$$

CREATE VIEW `sva_refset_ci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ci` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_ci` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_ci'
DROP VIEW IF EXISTS `svx_refset_ci`;$$

CREATE VIEW `svx_refset_ci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ci` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_ci` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

-- Views for 'sva of sct2_refset_ss'
DROP VIEW IF EXISTS `sva_refset_ss`;$$

CREATE VIEW `sva_refset_ss` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ss` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_ss` `c2` where (`c2`.`id` = `c`.`id`))))$$

-- Views for 'svx of sct2_refset_ss'
DROP VIEW IF EXISTS `svx_refset_ss`;$$

CREATE VIEW `svx_refset_ss` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ss` `c` where (`c`.`effectiveTime` = (select max(`c2`.`effectiveTime`) AS `recentEffectiveTime` from `sct2_refset_ss` `c2` where ((`c2`.`id` = `c`.`id`) and (`c2`.`effectiveTime` <= `configTime`())))))$$

DELIMITER $$
USE snomedct$$

-- CREATE UNOPTIMIZED SPECIAL VIEWS

-- Special Views for 'sva'
DROP VIEW IF EXISTS `sva_fsn`$$

CREATE VIEW `sva_fsn` AS (select `d`.* from (`sva_description` `d` join `sva_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000003001) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `sva_pref`$$

CREATE VIEW `sva_pref` AS (select `d`.* from (`sva_description` `d` join `sva_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `sva_syn`$$

CREATE VIEW `sva_syn` AS (select `d`.* from (`sva_description` `d` join `sva_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000549004)))$$

DROP VIEW IF EXISTS `sva_synall`$$

CREATE VIEW `sva_synall` AS (select `d`.*,`rs`.attribute1 from (`sva_description` `d` join `sva_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1)))$$

DROP VIEW IF EXISTS `sva_rel_pref`$$

CREATE VIEW `sva_rel_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sva_relationship` `r` join `sva_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sva_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sva_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `sva_rel_fsn`$$

CREATE VIEW `sva_rel_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sva_relationship` `r` join `sva_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sva_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sva_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `sva_rel_def_pref`$$

CREATE VIEW `sva_rel_def_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sva_relationship` `r` join `sva_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sva_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sva_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `sva_rel_def_fsn`$$

CREATE VIEW `sva_rel_def_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sva_relationship` `r` join `sva_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sva_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sva_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `sva_rel_child_fsn`$$

CREATE VIEW `sva_rel_child_fsn` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `sva_relationship` `r` join `sva_fsn` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `sva_rel_parent_fsn`$$

CREATE VIEW `sva_rel_parent_fsn` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `sva_relationship` `r` join `sva_fsn` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `sva_rel_child_pref`$$

CREATE VIEW `sva_rel_child_pref` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `sva_relationship` `r` join `sva_pref` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `sva_rel_parent_pref`$$

CREATE VIEW `sva_rel_parent_pref` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `sva_relationship` `r` join `sva_pref` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

CREATE FUNCTION `sva_FsnExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM sva_fsn WHERE `conceptId`=`id`)," |");
END$$

CREATE FUNCTION `sva_PrefExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM sva_pref WHERE `conceptId`=`id`)," |");
END$$

-- Special Views for 'svx'
DROP VIEW IF EXISTS `svx_fsn`$$

CREATE VIEW `svx_fsn` AS (select `d`.* from (`svx_description` `d` join `svx_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000003001) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `svx_pref`$$

CREATE VIEW `svx_pref` AS (select `d`.* from (`svx_description` `d` join `svx_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `svx_syn`$$

CREATE VIEW `svx_syn` AS (select `d`.* from (`svx_description` `d` join `svx_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000549004)))$$

DROP VIEW IF EXISTS `svx_synall`$$

CREATE VIEW `svx_synall` AS (select `d`.*,`rs`.attribute1 from (`svx_description` `d` join `svx_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1)))$$

DROP VIEW IF EXISTS `svx_rel_pref`$$

CREATE VIEW `svx_rel_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`svx_relationship` `r` join `svx_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `svx_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `svx_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `svx_rel_fsn`$$

CREATE VIEW `svx_rel_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`svx_relationship` `r` join `svx_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `svx_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `svx_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `svx_rel_def_pref`$$

CREATE VIEW `svx_rel_def_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`svx_relationship` `r` join `svx_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `svx_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `svx_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `svx_rel_def_fsn`$$

CREATE VIEW `svx_rel_def_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`svx_relationship` `r` join `svx_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `svx_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `svx_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `svx_rel_child_fsn`$$

CREATE VIEW `svx_rel_child_fsn` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `svx_relationship` `r` join `svx_fsn` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `svx_rel_parent_fsn`$$

CREATE VIEW `svx_rel_parent_fsn` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `svx_relationship` `r` join `svx_fsn` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `svx_rel_child_pref`$$

CREATE VIEW `svx_rel_child_pref` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `svx_relationship` `r` join `svx_pref` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `svx_rel_parent_pref`$$

CREATE VIEW `svx_rel_parent_pref` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `svx_relationship` `r` join `svx_pref` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

CREATE FUNCTION `svx_FsnExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM svx_fsn WHERE `conceptId`=`id`)," |");
END$$

CREATE FUNCTION `svx_PrefExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM svx_pref WHERE `conceptId`=`id`)," |");
END$$

DELIMITER $$
USE snomedct$$

-- SET Superseded TIME AND CREATE OPTIMIZED VIEWS



SET SQL_SAFE_UPDATES=0;$$

DROP TABLE IF EXISTS `tmp`;$$
-- Superseded time for 'sct2_concept'
-- SET SUPERCEDED TIME sct2_concept 

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_concept` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_concept` AS `c`;$$

UPDATE `sct2_concept` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_concept'
DROP VIEW IF EXISTS `soa_concept`;$$

CREATE VIEW `soa_concept` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`definitionStatusId` AS `definitionStatusId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_concept` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_concept'
DROP VIEW IF EXISTS `sox_concept`;$$

CREATE VIEW `sox_concept` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`definitionStatusId` AS `definitionStatusId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_concept` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

DROP TABLE IF EXISTS `tmp`;$$
-- Superseded time for 'sct2_description'
-- SET SUPERCEDED TIME sct2_description 

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_description` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_description` AS `c`;$$

UPDATE `sct2_description` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_description'
DROP VIEW IF EXISTS `soa_description`;$$

CREATE VIEW `soa_description` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_description` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_description'
DROP VIEW IF EXISTS `sox_description`;$$

CREATE VIEW `sox_description` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_description` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_relationship'
-- SET SUPERCEDED TIME sct2_relationship 

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_relationship` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_relationship` AS `c`;$$

UPDATE `sct2_relationship` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_relationship'
DROP VIEW IF EXISTS `soa_relationship`;$$

CREATE VIEW `soa_relationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_relationship` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_relationship'
DROP VIEW IF EXISTS `sox_relationship`;$$

CREATE VIEW `sox_relationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_relationship` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_statedrelationship'
-- SET SUPERCEDED TIME sct2_statedrelationship 

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_statedrelationship` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_statedrelationship` AS `c`;$$

UPDATE `sct2_statedrelationship` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_statedrelationship'
DROP VIEW IF EXISTS `soa_statedrelationship`;$$

CREATE VIEW `soa_statedrelationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_statedrelationship` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_statedrelationship'
DROP VIEW IF EXISTS `sox_statedrelationship`;$$

CREATE VIEW `sox_statedrelationship` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`sourceId` AS `sourceId`,`c`.`destinationId` AS `destinationId`,`c`.`relationshipGroup` AS `relationshipGroup`,`c`.`typeId` AS `typeId`,`c`.`characteristicTypeId` AS `characteristicTypeId`,`c`.`modifierId` AS `modifierId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_statedrelationship` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_textdefinition'
-- SET SUPERCEDED TIME sct2_textdefinition 

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_textdefinition` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_textdefinition` AS `c`;$$

UPDATE `sct2_textdefinition` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_textdefinition'
DROP VIEW IF EXISTS `soa_textdefinition`;$$

CREATE VIEW `soa_textdefinition` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_textdefinition` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_textdefinition'
DROP VIEW IF EXISTS `sox_textdefinition`;$$

CREATE VIEW `sox_textdefinition` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`conceptId` AS `conceptId`,`c`.`languageCode` AS `languageCode`,`c`.`typeId` AS `typeId`,`c`.`term` AS `term`,`c`.`caseSignificanceId` AS `caseSignificanceId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_textdefinition` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_c'
-- SET SUPERCEDED TIME sct2_refset_c 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_c` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_c` AS `c`;$$

UPDATE `sct2_refset_c` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_c'
DROP VIEW IF EXISTS `soa_refset_c`;$$

CREATE VIEW `soa_refset_c` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_c` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_c'
DROP VIEW IF EXISTS `sox_refset_c`;$$

CREATE VIEW `sox_refset_c` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_c` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset'
-- SET SUPERCEDED TIME sct2_refset 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset` AS `c`;$$

UPDATE `sct2_refset` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset'
DROP VIEW IF EXISTS `soa_refset`;$$

CREATE VIEW `soa_refset` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset'
DROP VIEW IF EXISTS `sox_refset`;$$

CREATE VIEW `sox_refset` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_iissscc'
-- SET SUPERCEDED TIME sct2_refset_iissscc 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_iissscc` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_iissscc` AS `c`;$$

UPDATE `sct2_refset_iissscc` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_iissscc'
DROP VIEW IF EXISTS `soa_refset_iissscc`;$$

CREATE VIEW `soa_refset_iissscc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,`attribute7`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iissscc` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_iissscc'
DROP VIEW IF EXISTS `sox_refset_iissscc`;$$

CREATE VIEW `sox_refset_iissscc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,`attribute7`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iissscc` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_iisssc'
-- SET SUPERCEDED TIME sct2_refset_iisssc 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_iisssc` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_iisssc` AS `c`;$$

UPDATE `sct2_refset_iisssc` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_iisssc'
DROP VIEW IF EXISTS `soa_refset_iisssc`;$$

CREATE VIEW `soa_refset_iisssc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iisssc` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_iisssc'
DROP VIEW IF EXISTS `sox_refset_iisssc`;$$

CREATE VIEW `sox_refset_iisssc` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,`attribute4`,`attribute5`,`attribute6`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_iisssc` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_s'
-- SET SUPERCEDED TIME sct2_refset_s 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_s` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_s` AS `c`;$$

UPDATE `sct2_refset_s` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_s'
DROP VIEW IF EXISTS `soa_refset_s`;$$

CREATE VIEW `soa_refset_s` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_s` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_s'
DROP VIEW IF EXISTS `sox_refset_s`;$$

CREATE VIEW `sox_refset_s` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_s` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_cci'
-- SET SUPERCEDED TIME sct2_refset_cci 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_cci` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_cci` AS `c`;$$

UPDATE `sct2_refset_cci` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_cci'
DROP VIEW IF EXISTS `soa_refset_cci`;$$

CREATE VIEW `soa_refset_cci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_cci` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_cci'
DROP VIEW IF EXISTS `sox_refset_cci`;$$

CREATE VIEW `sox_refset_cci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,`attribute3`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_cci` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_ci'
-- SET SUPERCEDED TIME sct2_refset_ci 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_ci` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_ci` AS `c`;$$

UPDATE `sct2_refset_ci` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_ci'
DROP VIEW IF EXISTS `soa_refset_ci`;$$

CREATE VIEW `soa_refset_ci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ci` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_ci'
DROP VIEW IF EXISTS `sox_refset_ci`;$$

CREATE VIEW `sox_refset_ci` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ci` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

-- Superseded time for 'sct2_refset_ss'
-- SET SUPERCEDED TIME sct2_refset_ss 

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16),`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));$$

INSERT INTO `tmp` SELECT `c`.`id`, `c`.`effectiveTime`, (SELECT IFNULL(MIN(`c2`.`effectiveTime`),CAST('9999-12-31' AS DATETIME)) FROM `sct2_refset_ss` AS `c2` WHERE `c`.`id`=`c2`.`id` AND `c`.`effectiveTime`<`c2`.`effectiveTime`) AS supersededTime FROM `sct2_refset_ss` AS `c`;$$

UPDATE `sct2_refset_ss` AS `c` JOIN `tmp`
SET `c`.`supersededTime`=`tmp`.`supersededTime`
WHERE `tmp`.`id`=`c`.`id` AND `tmp`.`effectiveTime`=`c`.`effectiveTime`;$$

DROP TABLE IF EXISTS `tmp`;$$

-- Views for 'soa of sct2_refset_ss'
DROP VIEW IF EXISTS `soa_refset_ss`;$$

CREATE VIEW `soa_refset_ss` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ss` `c` where (`c`.`supersededTime` = cast('9999-12-31' as datetime)))$$

-- Views for 'sox of sct2_refset_ss'
DROP VIEW IF EXISTS `sox_refset_ss`;$$

CREATE VIEW `sox_refset_ss` AS (select `c`.`id` AS `id`,`c`.`effectiveTime` AS `effectiveTime`,`c`.`active` AS `active`,`c`.`moduleId` AS `moduleId`,`c`.`refSetId` AS `refSetId`,`c`.`referencedComponentId` AS `referencedComponentId`,`attribute1`,`attribute2`,
 `c`.`supersededTime` AS `supersededTime` from `sct2_refset_ss` `c` where ((`configTime`() >= `c`.`effectiveTime`) and (`configTime`() < `c`.`supersededTime`)))$$

DELIMITER $$
USE snomedct$$

-- CREATE OPTIMIZED SPECIAL VIEWS

-- Special Views for 'soa'§config
DROP VIEW IF EXISTS `soa_fsn`$$

CREATE VIEW `soa_fsn` AS (select `d`.* from (`soa_description` `d` join `soa_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000003001) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `soa_pref`$$

CREATE VIEW `soa_pref` AS (select `d`.* from (`soa_description` `d` join `soa_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `soa_syn`$$

CREATE VIEW `soa_syn` AS (select `d`.* from (`soa_description` `d` join `soa_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000549004)))$$

DROP VIEW IF EXISTS `soa_synall`$$

CREATE VIEW `soa_synall` AS (select `d`.*,`rs`.attribute1 from (`soa_description` `d` join `soa_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1)))$$

DROP VIEW IF EXISTS `soa_rel_pref`$$

CREATE VIEW `soa_rel_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`soa_relationship` `r` join `soa_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `soa_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `soa_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `soa_rel_fsn`$$

CREATE VIEW `soa_rel_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`soa_relationship` `r` join `soa_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `soa_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `soa_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `soa_rel_def_pref`$$

CREATE VIEW `soa_rel_def_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`soa_relationship` `r` join `soa_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `soa_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `soa_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `soa_rel_def_fsn`$$

CREATE VIEW `soa_rel_def_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`soa_relationship` `r` join `soa_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `soa_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `soa_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `soa_rel_child_fsn`$$

CREATE VIEW `soa_rel_child_fsn` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `soa_relationship` `r` join `soa_fsn` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `soa_rel_parent_fsn`$$

CREATE VIEW `soa_rel_parent_fsn` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `soa_relationship` `r` join `soa_fsn` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `soa_rel_child_pref`$$

CREATE VIEW `soa_rel_child_pref` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `soa_relationship` `r` join `soa_pref` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `soa_rel_parent_pref`$$

CREATE VIEW `soa_rel_parent_pref` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `soa_relationship` `r` join `soa_pref` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

CREATE FUNCTION `soa_FsnExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM soa_fsn WHERE `conceptId`=`id`)," |");
END$$

CREATE FUNCTION `soa_PrefExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM soa_pref WHERE `conceptId`=`id`)," |");
END$$

-- Special Views for 'sox'
DROP VIEW IF EXISTS `sox_fsn`$$

CREATE VIEW `sox_fsn` AS (select `d`.* from (`sox_description` `d` join `sox_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000003001) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `sox_pref`$$

CREATE VIEW `sox_pref` AS (select `d`.* from (`sox_description` `d` join `sox_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000548007)))$$

DROP VIEW IF EXISTS `sox_syn`$$

CREATE VIEW `sox_syn` AS (select `d`.* from (`sox_description` `d` join `sox_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1) and (`rs`.`attribute1` = 900000000000549004)))$$

DROP VIEW IF EXISTS `sox_synall`$$

CREATE VIEW `sox_synall` AS (select `d`.*,`rs`.attribute1 from (`sox_description` `d` join `sox_refset_c` `rs` on((`d`.`id` = `rs`.`referencedComponentId`))) where ((`d`.`active` = 1) and (`d`.`typeId` = 900000000000013009) and (`rs`.`refSetId` = configLangId()) and (`rs`.`active` = 1)))$$

DROP VIEW IF EXISTS `sox_rel_pref`$$

CREATE VIEW `sox_rel_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sox_relationship` `r` join `sox_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sox_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sox_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `sox_rel_fsn`$$

CREATE VIEW `sox_rel_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sox_relationship` `r` join `sox_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sox_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sox_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1)))$$

DROP VIEW IF EXISTS `sox_rel_def_pref`$$

CREATE VIEW `sox_rel_def_pref` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sox_relationship` `r` join `sox_pref` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sox_pref` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sox_pref` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `sox_rel_def_fsn`$$

CREATE VIEW `sox_rel_def_fsn` AS (select `r`.`sourceId` AS `src_id`,`src`.`Term` AS `src_term`,`r`.`typeId` AS `type_id`,`typ`.`Term` AS `type_term`,`r`.`destinationId` AS `dest_id`,`dest`.`Term` AS `dest_term`,`r`.`relationshipGroup` AS `relationshipGroup` from (((`sox_relationship` `r` join `sox_fsn` `src` on((`r`.`sourceId` = `src`.`conceptId`))) join `sox_fsn` `typ` on((`r`.`typeId` = `typ`.`conceptId`))) join `sox_fsn` `dest` on((`r`.`destinationId` = `dest`.`conceptId`))) where ((`r`.`active` = 1) and (`r`.`characteristicTypeId` = 900000000000011006)))$$

DROP VIEW IF EXISTS `sox_rel_child_fsn`$$

CREATE VIEW `sox_rel_child_fsn` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `sox_relationship` `r` join `sox_fsn` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `sox_rel_parent_fsn`$$

CREATE VIEW `sox_rel_parent_fsn` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `sox_relationship` `r` join `sox_fsn` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `sox_rel_child_pref`$$

CREATE VIEW `sox_rel_child_pref` AS (select `r`.`sourceId` AS `id`,`d`.`term` AS `term`,`r`.`destinationId` AS `conceptId` from  `sox_relationship` `r` join `sox_pref` `d` on (`r`.`sourceId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

DROP VIEW IF EXISTS `sox_rel_parent_pref`$$

CREATE VIEW `sox_rel_parent_pref` AS (select `r`.`destinationId` AS `id`,`d`.`term` AS `term`,`r`.`sourceId` AS `conceptId` from  `sox_relationship` `r` join `sox_pref` `d` on (`r`.`destinationId` = `d`.`conceptId`) where (`r`.`active` = 1) and (`r`.`typeId` = 116680003))$$

CREATE FUNCTION `sox_FsnExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM sox_fsn WHERE `conceptId`=`id`)," |");
END$$

CREATE FUNCTION `sox_PrefExp`(`id` BIGINT) RETURNS varchar(300) CHARSET utf8
BEGIN
    RETURN CONCAT(`id`," | ", (SELECT `term` FROM sox_pref WHERE `conceptId`=`id`)," |");
END$$

DELIMITER $$
USE snomedct$$

-- ADD INDEXES TO TABLES

-- INDEX TABLE  `sct2_concept`

ALTER TABLE `sct2_concept`
ADD INDEX `sct2_concept_20` (`id` ASC,`supersededTime` ASC)$$

-- INDEX TABLE  `sct2_description`

ALTER TABLE `sct2_description`
ADD INDEX `sct2_description_20` (`id` ASC, `supersededTime` ASC),
ADD INDEX `sct2_description_23` (`conceptId` ASC, `supersededTime` ASC, `languageCode` ASC)$$


-- INDEX TABLE  `sct2_identifier`

ALTER TABLE `sct2_identifier`
ADD INDEX `sct2_identifier_1` (`identifierSchemeId` ASC,`alternateIdentifier` ASC),
ADD INDEX `sct2_identifier_2` (`referencedComponentId` ASC,`identifierSchemeId` ASC)$$


-- INDEX TABLE  `sct2_relationship`

ALTER TABLE `sct2_relationship`
ADD INDEX `sct2_relationship_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_relationship_11` (`sourceId` ASC,`characteristicTypeId` ASC,`typeId` ASC,`destinationId` ASC),
ADD INDEX `sct2_relationship_12` (`destinationId` ASC,`characteristicTypeId` ASC,`sourceId` ASC),
ADD INDEX `sct2_relationship_21` (`sourceId` ASC,`supersededTime` ASC,`characteristicTypeId` ASC,`typeId` ASC,`destinationId` ASC),
ADD INDEX `sct2_relationship_22` (`destinationId` ASC,`supersededTime` ASC,`characteristicTypeId` ASC,`sourceId` ASC)$$


-- INDEX TABLE  `sct2_statedrelationship`

ALTER TABLE `sct2_statedrelationship`
ADD INDEX `sct2_statedrelationship_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_statedrelationship_11` (`sourceId` ASC,`characteristicTypeId` ASC,`typeId` ASC,`destinationId` ASC),
ADD INDEX `sct2_statedrelationship_12` (`destinationId` ASC,`characteristicTypeId` ASC,`sourceId` ASC),
ADD INDEX `sct2_statedrelationship_21` (`sourceId` ASC,`supersededTime` ASC,`characteristicTypeId` ASC,`typeId` ASC,`destinationId` ASC),
ADD INDEX `sct2_statedrelationship_22` (`destinationId` ASC,`supersededTime` ASC,`characteristicTypeId` ASC,`sourceId` ASC)$$


-- INDEX TABLE  `sct2_textdefinition`

ALTER TABLE `sct2_textdefinition`
ADD INDEX `sct2_textdefinition_20` (`id` ASC, `supersededTime` ASC),
ADD INDEX `sct2_textdefinition_23` (`conceptId` ASC, `supersededTime` ASC, `languageCode` ASC)$$


-- INDEX TABLE  `sct2_refset_c`

ALTER TABLE `sct2_refset_c`
ADD INDEX `sct2_refset_c_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_c_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_c_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_c_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_c_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset`

ALTER TABLE `sct2_refset`
ADD INDEX `sct2_refset_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset_iissscc`

ALTER TABLE `sct2_refset_iissscc`
ADD INDEX `sct2_refset_iissscc_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_iissscc_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_iissscc_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_iissscc_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_iissscc_31` (`refsetId`,`referencedComponentId`,`attribute2`),
ADD INDEX `sct2_refset_iissscc_32` (`refsetId`,`referencedComponentId`,`attribute3`),
ADD INDEX `sct2_refset_iissscc_33` (`refsetId`,`referencedComponentId`,`attribute4`),
ADD INDEX `sct2_refset_iissscc_34` (`refsetId`,`referencedComponentId`,`attribute5`),
ADD INDEX `sct2_refset_iissscc_35` (`refsetId`,`referencedComponentId`,`attribute6`),
ADD INDEX `sct2_refset_iissscc_36` (`refsetId`,`referencedComponentId`,`attribute7`),
ADD INDEX `sct2_refset_iissscc_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset_iisssc`

ALTER TABLE `sct2_refset_iisssc`
ADD INDEX `sct2_refset_iisssc_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_iisssc_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_iisssc_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_iisssc_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_iisssc_31` (`refsetId`,`referencedComponentId`,`attribute2`),
ADD INDEX `sct2_refset_iisssc_32` (`refsetId`,`referencedComponentId`,`attribute3`),
ADD INDEX `sct2_refset_iisssc_33` (`refsetId`,`referencedComponentId`,`attribute4`),
ADD INDEX `sct2_refset_iisssc_34` (`refsetId`,`referencedComponentId`,`attribute5`),
ADD INDEX `sct2_refset_iisssc_35` (`refsetId`,`referencedComponentId`,`attribute6`),
ADD INDEX `sct2_refset_iisssc_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset_s`

ALTER TABLE `sct2_refset_s`
ADD INDEX `sct2_refset_s_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_s_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_s_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_s_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_s_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset_cci`

ALTER TABLE `sct2_refset_cci`
ADD INDEX `sct2_refset_cci_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_cci_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_cci_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_cci_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_cci_31` (`refsetId`,`referencedComponentId`,`attribute2`),
ADD INDEX `sct2_refset_cci_32` (`refsetId`,`referencedComponentId`,`attribute3`),
ADD INDEX `sct2_refset_cci_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset_ci`

ALTER TABLE `sct2_refset_ci`
ADD INDEX `sct2_refset_ci_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_ci_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_ci_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_ci_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_ci_31` (`refsetId`,`referencedComponentId`,`attribute2`),
ADD INDEX `sct2_refset_ci_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$


-- INDEX TABLE  `sct2_refset_ss`

ALTER TABLE `sct2_refset_ss`
ADD INDEX `sct2_refset_ss_20` (`id` ASC,`supersededTime` ASC),
ADD INDEX `sct2_refset_ss_1` (`referencedComponentId` ASC),
ADD INDEX `sct2_refset_ss_2` (`refsetId` ASC,`referencedComponentId` ASC),
ADD INDEX `sct2_refset_ss_30` (`refsetId`,`referencedComponentId`,`attribute1`),
ADD INDEX `sct2_refset_ss_31` (`refsetId`,`referencedComponentId`,`attribute2`),
ADD INDEX `sct2_refset_ss_22` (`refsetId` ASC,`supersededTime` ASC,`referencedComponentId` ASC)$$

DELIMITER $$
USE snomedct$$

-- FULL TEXT INDEX

ALTER TABLE `sct2_description`  ADD FULLTEXT INDEX `sct_term` (`term` ASC) $$


-- COMPLETE

