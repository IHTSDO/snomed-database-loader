/*
-- IMPORTS SNOMED CT RF2 FULL RELEASE INTO MYSQL DATA BASE

-- MySQL Script for Loading and Optimizing SNOMED CT Release Files
-- Apache 2.0 license applies
-- 
-- MySQL VERSION NOTES: 
--    Tested to work on MySQL 5.7
--    Known issues with MySQL 8.x due to security blocking LOAD DATA LOCAL INFILE statements
--
-- =======================================================
-- Copyright of this version 2018: SNOMED International www.snomed.org
-- Based on work by David Markwell between 2011 and 2018
-- 
-- All these versions are licensed as follows:
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =======================================================
--
-- 1. RELEASE PACKAGE AND VERSION 
-- ==============================
-- This template script is specific a specific version: 20190131
-- of a specific release package:
-- SnomedCT_InternationalRF2_PRODUCTION_20190131T120000Z 
--
-- If this is the release package version you are importing please
-- skip to section 3 of these notes.
--
-- 2. PACKAGE AND VERSION CONFIGURATION
-- ====================================
-- If you are working with a different version of the same release package
-- this script may be adapted to import that package.
--
-- First replace all instances of: SnomedCT_InternationalRF2_PRODUCTION_20190131T120000Z
-- with the release folder name for the release package version to be loaded.
--
-- Then replace all instances of the date stamp: 20190131
-- With the date stamp for the version to be imported.
-- 
-- IMPORTANT NOTE
-- Different release packages or release package versions may contain
-- different sets of files.
-- If expected files are missing the script will fail.
-- If files present in a imported release package are not in the release for which
-- this script was developed those additional files will not be imported.
-- 
-- Updated versions of this script may be available for newer production releases
-- of SNOMED CT International Edition packages.
--
-- 3. FOLDER LOCATION CONFIGURATION
-- ================================
-- This templated version of the file contains placeholders $RELPATH
--
-- Replace all instances of $RELPATH with the fullpath of the folder
-- SnomedCT_InternationalRF2_PRODUCTION_20190131T120000Z
--
-- 4. IF YOU ARE *NOT* IMPORTING A TRANSITIVE CLOSURE FILE
-- ========================================================
-- You are recommended to create a transitive closure file for import.
-- 
-- However, if you do not want to have a transitive closure table or are
-- unable to create the transitive closure file then find the line
-- towards the end of this file that contains the text: #TRANSCLOSE#
-- 
-- Delete that line and all the lines that follow it up to the end
-- of the file. If you do not do this, the script will complete to
-- that point but will report an error when it completes.
--
-- 5. SAVE AND RUN THE SCRIPT
-- ==========================
-- Save a copy of the SQL script with any modifications you have made.
-- Run this script in MySQL (e.g. through the MySQL Workbench).
*/
/*
	CONFIGURATION SETTINGS USED WHEN PRODUCING THIS VERSION
	
	Release Package: SnomedCT_InternationalRF2_PRODUCTION_20190131T120000Z
	Configuration Options
	{"optimization":"supersededTime","optimizationCol":"\t`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',\n","reltype":"Full","dbName":"sct","extend":false,"dbEngine":"MyISAM","charSet":"utf8","relpath":"$RELPATH"}
*/


SELECT Now() `Time Started`;
SELECT "STAGE: Starting to Build Database for SNOMED CT Release Files";

DELIMITER ;

DROP DATABASE IF EXISTS `sct`; 
CREATE DATABASE `sct` /*!40100 DEFAULT CHARACTER SET utf8 */;

-- INITIALIZE SETTINGS

SET GLOBAL net_write_timeout = 60;
SET GLOBAL net_read_timeout=120;
SET GLOBAL sql_mode ='';
SET SESSION sql_mode ='';
-- Create Tables

SELECT Now() `Time Started`;
SELECT "STAGE: Create Tables";

USE `sct`;
DELIMITER ;
-- CREATE TABLES

SELECT "STAGE: Creating Tables";

-- CREATE TABLE `sct_refset_Simple` 

DROP TABLE IF EXISTS `sct_refset_Simple`;

CREATE TABLE `sct_refset_Simple` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_Association` 

DROP TABLE IF EXISTS `sct_refset_Association`;

CREATE TABLE `sct_refset_Association` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`targetComponentId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_AttributeValue` 

DROP TABLE IF EXISTS `sct_refset_AttributeValue`;

CREATE TABLE `sct_refset_AttributeValue` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`valueId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_Language` 

DROP TABLE IF EXISTS `sct_refset_Language`;

CREATE TABLE `sct_refset_Language` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`acceptabilityId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_ExtendedMap` 

DROP TABLE IF EXISTS `sct_refset_ExtendedMap`;

CREATE TABLE `sct_refset_ExtendedMap` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mapGroup` INT NOT NULL DEFAULT 0,
	`mapPriority` INT NOT NULL DEFAULT 0,
	`mapRule` TEXT NOT NULL,
	`mapAdvice` TEXT NOT NULL,
	`mapTarget` VARCHAR (200) NOT NULL DEFAULT '',
	`correlationId` BIGINT NOT NULL DEFAULT  0,
	`mapCategoryId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_SimpleMap` 

DROP TABLE IF EXISTS `sct_refset_SimpleMap`;

CREATE TABLE `sct_refset_SimpleMap` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mapTarget` VARCHAR (200) NOT NULL DEFAULT '',
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_MRCMModuleScope` 

DROP TABLE IF EXISTS `sct_refset_MRCMModuleScope`;

CREATE TABLE `sct_refset_MRCMModuleScope` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mrcmRuleRefsetId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_RefsetDescriptor` 

DROP TABLE IF EXISTS `sct_refset_RefsetDescriptor`;

CREATE TABLE `sct_refset_RefsetDescriptor` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`attributeDescription` BIGINT NOT NULL DEFAULT  0,
	`attributeType` BIGINT NOT NULL DEFAULT  0,
	`attributeOrder` INT NOT NULL DEFAULT 0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_DescriptionType` 

DROP TABLE IF EXISTS `sct_refset_DescriptionType`;

CREATE TABLE `sct_refset_DescriptionType` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`descriptionFormat` BIGINT NOT NULL DEFAULT  0,
	`descriptionLength` INT NOT NULL DEFAULT 0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_MRCMAttributeDomain` 

DROP TABLE IF EXISTS `sct_refset_MRCMAttributeDomain`;

CREATE TABLE `sct_refset_MRCMAttributeDomain` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`domainId` BIGINT NOT NULL DEFAULT  0,
	`grouped` INT NOT NULL DEFAULT 0,
	`attributeCardinality` TEXT NOT NULL,
	`attributeInGroupCardinality` TEXT NOT NULL,
	`ruleStrengthId` BIGINT NOT NULL DEFAULT  0,
	`contentTypeId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_ModuleDependency` 

DROP TABLE IF EXISTS `sct_refset_ModuleDependency`;

CREATE TABLE `sct_refset_ModuleDependency` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`sourceEffectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`targetEffectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_MRCMAttributeRange` 

DROP TABLE IF EXISTS `sct_refset_MRCMAttributeRange`;

CREATE TABLE `sct_refset_MRCMAttributeRange` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`rangeConstraint` TEXT NOT NULL,
	`attributeRule` TEXT NOT NULL,
	`ruleStrengthId` BIGINT NOT NULL DEFAULT  0,
	`contentTypeId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_MRCMDomain` 

DROP TABLE IF EXISTS `sct_refset_MRCMDomain`;

CREATE TABLE `sct_refset_MRCMDomain` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`domainConstraint` TEXT NOT NULL,
	`parentDomain` TEXT NOT NULL,
	`proximalPrimitiveConstraint` TEXT NOT NULL,
	`proximalPrimitiveRefinement` TEXT NOT NULL,
	`domainTemplateForPrecoordination` TEXT NOT NULL,
	`domainTemplateForPostcoordination` TEXT NOT NULL,
	`guideURL` TEXT NOT NULL,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_concept` 

DROP TABLE IF EXISTS `sct_concept`;

CREATE TABLE `sct_concept` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`definitionStatusId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_description` 

DROP TABLE IF EXISTS `sct_description`;

CREATE TABLE `sct_description` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`conceptId` BIGINT NOT NULL DEFAULT  0,
	`languageCode` VARCHAR (3) NOT NULL DEFAULT '',
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`term` TEXT NOT NULL,
	`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_relationship` 

DROP TABLE IF EXISTS `sct_relationship`;

CREATE TABLE `sct_relationship` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`sourceId` BIGINT NOT NULL DEFAULT  0,
	`destinationId` BIGINT NOT NULL DEFAULT  0,
	`relationshipGroup` INT NOT NULL DEFAULT 0,
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
	`modifierId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_statedRelationship` 

DROP TABLE IF EXISTS `sct_statedRelationship`;

CREATE TABLE `sct_statedRelationship` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`sourceId` BIGINT NOT NULL DEFAULT  0,
	`destinationId` BIGINT NOT NULL DEFAULT  0,
	`relationshipGroup` INT NOT NULL DEFAULT 0,
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
	`modifierId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_textDefinition` 

DROP TABLE IF EXISTS `sct_textDefinition`;

CREATE TABLE `sct_textDefinition` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`conceptId` BIGINT NOT NULL DEFAULT  0,
	`languageCode` VARCHAR (3) NOT NULL DEFAULT '',
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`term` TEXT NOT NULL,
	`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE `sct_refset_OWLExpression` 

DROP TABLE IF EXISTS `sct_refset_OWLExpression`;

CREATE TABLE `sct_refset_OWLExpression` (
	`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`owlExpression` TEXT NOT NULL,
	`supersededTime` DATETIME NOT NULL DEFAULT  '0000-00-00 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE Transitive Closure Tables

SELECT "STAGE: Creating Transitive Closure Tables";

-- CREATE TABLE `ss_transclose` 

DROP TABLE IF EXISTS `ss_transclose`;

CREATE TABLE `ss_transclose` (
	`subtypeId` BIGINT NOT NULL DEFAULT  0,
		`supertypeId` BIGINT NOT NULL DEFAULT  0,
		PRIMARY KEY (`subtypeId`,`supertypeId`),
		KEY `t_rev` (`supertypeId`,`subtypeId`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- CREATE TABLE ss_proximal_primitives 

DROP TABLE IF EXISTS ss_proximal_primitives;

CREATE TABLE ss_proximal_primitives (
	`subtypeId` BIGINT NOT NULL DEFAULT  0,
		`supertypeId` BIGINT NOT NULL DEFAULT  0,
		PRIMARY KEY (`subtypeId`,`supertypeId`),
		KEY `t_rev` (`supertypeId`,`subtypeId`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- Load Table Data

SELECT Now() `Time Started`;
SELECT "STAGE: Load Table Data";

USE `sct`;
DELIMITER ;
-- LOAD FILES INTO TABLES

SELECT "STAGE: Load Data Into Tables";

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_Refset_SimpleFull_INT_20190131.txt'
INTO TABLE `sct_refset_Simple`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_cRefset_AssociationFull_INT_20190131.txt'
INTO TABLE `sct_refset_Association`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`targetComponentId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_cRefset_AttributeValueFull_INT_20190131.txt'
INTO TABLE `sct_refset_AttributeValue`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`valueId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Language/der2_cRefset_LanguageFull-en_INT_20190131.txt'
INTO TABLE `sct_refset_Language`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`acceptabilityId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Map/der2_iisssccRefset_ExtendedMapFull_INT_20190131.txt'
INTO TABLE `sct_refset_ExtendedMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Map/der2_sRefset_SimpleMapFull_INT_20190131.txt'
INTO TABLE `sct_refset_SimpleMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapTarget`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cRefset_MRCMModuleScopeFull_INT_20190131.txt'
INTO TABLE `sct_refset_MRCMModuleScope`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mrcmRuleRefsetId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cciRefset_RefsetDescriptorFull_INT_20190131.txt'
INTO TABLE `sct_refset_RefsetDescriptor`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ciRefset_DescriptionTypeFull_INT_20190131.txt'
INTO TABLE `sct_refset_DescriptionType`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`descriptionFormat`,`descriptionLength`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cissccRefset_MRCMAttributeDomainFull_INT_20190131.txt'
INTO TABLE `sct_refset_MRCMAttributeDomain`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainId`,`grouped`,`attributeCardinality`,`attributeInGroupCardinality`,`ruleStrengthId`,`contentTypeId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ssRefset_ModuleDependencyFull_INT_20190131.txt'
INTO TABLE `sct_refset_ModuleDependency`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ssccRefset_MRCMAttributeRangeFull_INT_20190131.txt'
INTO TABLE `sct_refset_MRCMAttributeRange`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`rangeConstraint`,`attributeRule`,`ruleStrengthId`,`contentTypeId`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_sssssssRefset_MRCMDomainFull_INT_20190131.txt'
INTO TABLE `sct_refset_MRCMDomain`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainConstraint`,`parentDomain`,`proximalPrimitiveConstraint`,`proximalPrimitiveRefinement`,`domainTemplateForPrecoordination`,`domainTemplateForPostcoordination`,`guideURL`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_Concept_Full_INT_20190131.txt'
INTO TABLE `sct_concept`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`definitionStatusId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_Description_Full-en_INT_20190131.txt'
INTO TABLE `sct_description`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_Relationship_Full_INT_20190131.txt'
INTO TABLE `sct_relationship`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_StatedRelationship_Full_INT_20190131.txt'
INTO TABLE `sct_statedRelationship`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_TextDefinition_Full-en_INT_20190131.txt'
INTO TABLE `sct_textDefinition`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_sRefset_OWLExpressionFull_INT_20190131.txt'
INTO TABLE `sct_refset_OWLExpression`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@uuid,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`owlExpression`)
SET `id`=UNHEX(REPLACE(@uuid,'-',''));


-- Create Configuration Settings

SELECT Now() `Time Started`;
SELECT "STAGE: Create Configuration Settings";

USE `sct`;
DELIMITER ;

CREATE TABLE `config_language` (
 `id` bigint,
 `prefix` varchar(5),
 `name` VARCHAR (255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  INDEX pfx (`prefix`)
) ENGINE=MyISAM CHARSET=utf8;
INSERT INTO `config_language` (`prefix`,`id`,`name`)
VALUES
('en-US',900000000000509007,'US English'),
('en-GB',900000000000508004,'GB English');

CREATE TABLE `config_settings` (
`id` tinyint DEFAULT 1,
`languageId` bigint DEFAULT 900000000000509007,
`languageName` VARCHAR(255) NOT NULL DEFAULT 'US English',
`snapshotTime` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM CHARSET=utf8;

INSERT INTO `config_settings` (`id`,`languageId`,`languageName`,`snapshotTime`)
VALUES (1,900000000000509007,'US English', DATE_ADD(now(), INTERVAL 6 MONTH));

DELIMITER ;;
CREATE PROCEDURE `setLanguage` (IN `p_lang_prefix` varchar(5))
BEGIN
UPDATE `config_settings` `s`, `config_language` `l`
	SET `s`.`languageId`=`l`.`id`,
	`s`.`languageName`=`l`.`name`
	WHERE `l`.`prefix`=`p_lang_prefix`
	AND `s`.`id`=1;
END;;

CREATE FUNCTION `getsnapshotTime`() RETURNS DATETIME
BEGIN
RETURN (SELECT `snapshotTime` FROM `config_settings` WHERE `id`=1);
END;;

CREATE PROCEDURE `setsnapshotTime` (IN `p_snapshotTime` DATETIME)
BEGIN
UPDATE `config_settings` `s`, `config_language` `c`
	SET `snapshotTime`=`p_snapshotTime`
WHERE `s`.`id`=1;
SELECT `languageId`,`languageName`,`snapshotTime` FROM `config_settings`; 
END;;

CREATE FUNCTION `getLanguage`() RETURNS BIGINT
BEGIN
RETURN (SELECT `languageId` FROM `config_settings` WHERE `id`=1);
END;;

DELIMITER ;;
CREATE FUNCTION `ShowUid`(Uid blob) RETURNS varchar(36) CHARSET utf8
BEGIN
	SET @Tmp = LOWER(Hex(uid));
	RETURN CONCAT(SUBSTRING(@Tmp,1,8),'-',SUBSTRING(@Tmp,9,4),'-',SUBSTRING(@Tmp,13,4),'-',SUBSTRING(@Tmp,17,4),'-',SUBSTRING(@Tmp,21));
END;;

DELIMITER ;
DROP function IF EXISTS `getRefsetSelectLines`;

DELIMITER ;;

CREATE FUNCTION `getRefsetSelectLines`(`p_view_prefix` varchar(6),`p_refset_types_pattern` text,`p_table_abbrev` varchar(6),`p_added_sql` text) RETURNS text CHARSET utf8
BEGIN
DECLARE `v_id_label` varchar(255);
DECLARE `v_table_short` varchar(10);
DECLARE `v_field_pfx` varchar(10);
DECLARE `v_table_name` varchar(64);
DECLARE `v_regexp` text;
DECLARE `v_sql_out` text;
DECLARE `v_done` BOOLEAN DEFAULT FALSE;
DECLARE cur CURSOR FOR SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='sct' AND LOWER(TABLE_NAME) regexp `v_regexp`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `v_done` := TRUE;

SET `v_table_short`=IF(`p_table_abbrev`='','',CONCAT(' `',`p_table_abbrev`,'`'));
SET `v_field_pfx`=IF(`p_table_abbrev`='','',CONCAT('`',`p_table_abbrev`,'`.'));
SET `v_regexp`=CONCAT('^',`p_view_prefix`,'_refset_(',REPLACE(REPLACE(REPLACE(LOWER(`p_refset_types_pattern`),',','|'),' ',''),'%','.*'),')$');
SET `v_sql_out`=CONCAT('-- Refset SELECT lines for tables matching:',`v_regexp`,CHAR(10));

OPEN cur;
tableLoop: LOOP
    FETCH cur INTO `v_table_name`;
    IF `v_done` THEN
      LEAVE tableLoop;
    END IF;
    SET `v_id_label`=CONCAT('`{',SUBSTRING_INDEX(v_table_name,'_',-1),' Refsets} id`');
	SET `v_sql_out`=CONCAT(`v_sql_out`,CHAR(10),'-- ',`v_table_name`,CHAR(10),'SELECT showUid(',`v_field_pfx`,'`id`) ',`v_id_label`,', ', (SELECT GROUP_CONCAT(CONCAT(`v_field_pfx`,'`',COLUMN_NAME,'`')) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = `v_table_name` AND COLUMN_NAME !='id'), ' FROM `',`v_table_name`,'`',`v_table_short`,IF(`p_added_sql`='','',CONCAT(CHAR(10),CHAR(9),CHAR(9),p_added_sql)),';', CHAR(10),CHAR(10));
END LOOP tableLoop;
 RETURN `v_sql_out`;
END;;

DELIMITER ;
-- Create Unoptimized Views

SELECT Now() `Time Started`;
SELECT "STAGE: Create Unoptimized Views";

USE `sct`;
DELIMITER ;


-- Create Actual date view,View at Specified Snapshot Time;

-- CREATE VIEW `sva_refset_Simple` 

DROP VIEW IF EXISTS `sva_refset_Simple`;

CREATE VIEW `sva_refset_Simple` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`
	FROM `sct_refset_Simple` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_Simple` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_Association` 

DROP VIEW IF EXISTS `sva_refset_Association`;

CREATE VIEW `sva_refset_Association` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`targetComponentId` `targetComponentId`
	FROM `sct_refset_Association` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_Association` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_AttributeValue` 

DROP VIEW IF EXISTS `sva_refset_AttributeValue`;

CREATE VIEW `sva_refset_AttributeValue` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`valueId` `valueId`
	FROM `sct_refset_AttributeValue` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_AttributeValue` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_Language` 

DROP VIEW IF EXISTS `sva_refset_Language`;

CREATE VIEW `sva_refset_Language` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`acceptabilityId` `acceptabilityId`
	FROM `sct_refset_Language` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_Language` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_ExtendedMap` 

DROP VIEW IF EXISTS `sva_refset_ExtendedMap`;

CREATE VIEW `sva_refset_ExtendedMap` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`mapGroup` `mapGroup`,`tbl`.`mapPriority` `mapPriority`,`tbl`.`mapRule` `mapRule`,`tbl`.`mapAdvice` `mapAdvice`,`tbl`.`mapTarget` `mapTarget`,`tbl`.`correlationId` `correlationId`,`tbl`.`mapCategoryId` `mapCategoryId`
	FROM `sct_refset_ExtendedMap` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_ExtendedMap` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_SimpleMap` 

DROP VIEW IF EXISTS `sva_refset_SimpleMap`;

CREATE VIEW `sva_refset_SimpleMap` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`mapTarget` `mapTarget`
	FROM `sct_refset_SimpleMap` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_SimpleMap` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_MRCMModuleScope` 

DROP VIEW IF EXISTS `sva_refset_MRCMModuleScope`;

CREATE VIEW `sva_refset_MRCMModuleScope` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`mrcmRuleRefsetId` `mrcmRuleRefsetId`
	FROM `sct_refset_MRCMModuleScope` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMModuleScope` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_RefsetDescriptor` 

DROP VIEW IF EXISTS `sva_refset_RefsetDescriptor`;

CREATE VIEW `sva_refset_RefsetDescriptor` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`attributeDescription` `attributeDescription`,`tbl`.`attributeType` `attributeType`,`tbl`.`attributeOrder` `attributeOrder`
	FROM `sct_refset_RefsetDescriptor` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_RefsetDescriptor` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_DescriptionType` 

DROP VIEW IF EXISTS `sva_refset_DescriptionType`;

CREATE VIEW `sva_refset_DescriptionType` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`descriptionFormat` `descriptionFormat`,`tbl`.`descriptionLength` `descriptionLength`
	FROM `sct_refset_DescriptionType` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_DescriptionType` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_MRCMAttributeDomain` 

DROP VIEW IF EXISTS `sva_refset_MRCMAttributeDomain`;

CREATE VIEW `sva_refset_MRCMAttributeDomain` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`domainId` `domainId`,`tbl`.`grouped` `grouped`,`tbl`.`attributeCardinality` `attributeCardinality`,`tbl`.`attributeInGroupCardinality` `attributeInGroupCardinality`,`tbl`.`ruleStrengthId` `ruleStrengthId`,`tbl`.`contentTypeId` `contentTypeId`
	FROM `sct_refset_MRCMAttributeDomain` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMAttributeDomain` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_ModuleDependency` 

DROP VIEW IF EXISTS `sva_refset_ModuleDependency`;

CREATE VIEW `sva_refset_ModuleDependency` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`sourceEffectiveTime` `sourceEffectiveTime`,`tbl`.`targetEffectiveTime` `targetEffectiveTime`
	FROM `sct_refset_ModuleDependency` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_ModuleDependency` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_MRCMAttributeRange` 

DROP VIEW IF EXISTS `sva_refset_MRCMAttributeRange`;

CREATE VIEW `sva_refset_MRCMAttributeRange` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`rangeConstraint` `rangeConstraint`,`tbl`.`attributeRule` `attributeRule`,`tbl`.`ruleStrengthId` `ruleStrengthId`,`tbl`.`contentTypeId` `contentTypeId`
	FROM `sct_refset_MRCMAttributeRange` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMAttributeRange` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_MRCMDomain` 

DROP VIEW IF EXISTS `sva_refset_MRCMDomain`;

CREATE VIEW `sva_refset_MRCMDomain` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`domainConstraint` `domainConstraint`,`tbl`.`parentDomain` `parentDomain`,`tbl`.`proximalPrimitiveConstraint` `proximalPrimitiveConstraint`,`tbl`.`proximalPrimitiveRefinement` `proximalPrimitiveRefinement`,`tbl`.`domainTemplateForPrecoordination` `domainTemplateForPrecoordination`,`tbl`.`domainTemplateForPostcoordination` `domainTemplateForPostcoordination`,`tbl`.`guideURL` `guideURL`
	FROM `sct_refset_MRCMDomain` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMDomain` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_concept` 

DROP VIEW IF EXISTS `sva_concept`;

CREATE VIEW `sva_concept` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`definitionStatusId` `definitionStatusId`
	FROM `sct_concept` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_concept` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_description` 

DROP VIEW IF EXISTS `sva_description`;

CREATE VIEW `sva_description` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`conceptId` `conceptId`,`tbl`.`languageCode` `languageCode`,`tbl`.`typeId` `typeId`,`tbl`.`term` `term`,`tbl`.`caseSignificanceId` `caseSignificanceId`
	FROM `sct_description` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_description` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_relationship` 

DROP VIEW IF EXISTS `sva_relationship`;

CREATE VIEW `sva_relationship` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`sourceId` `sourceId`,`tbl`.`destinationId` `destinationId`,`tbl`.`relationshipGroup` `relationshipGroup`,`tbl`.`typeId` `typeId`,`tbl`.`characteristicTypeId` `characteristicTypeId`,`tbl`.`modifierId` `modifierId`
	FROM `sct_relationship` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_relationship` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_statedRelationship` 

DROP VIEW IF EXISTS `sva_statedRelationship`;

CREATE VIEW `sva_statedRelationship` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`sourceId` `sourceId`,`tbl`.`destinationId` `destinationId`,`tbl`.`relationshipGroup` `relationshipGroup`,`tbl`.`typeId` `typeId`,`tbl`.`characteristicTypeId` `characteristicTypeId`,`tbl`.`modifierId` `modifierId`
	FROM `sct_statedRelationship` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_statedRelationship` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_textDefinition` 

DROP VIEW IF EXISTS `sva_textDefinition`;

CREATE VIEW `sva_textDefinition` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`conceptId` `conceptId`,`tbl`.`languageCode` `languageCode`,`tbl`.`typeId` `typeId`,`tbl`.`term` `term`,`tbl`.`caseSignificanceId` `caseSignificanceId`
	FROM `sct_textDefinition` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_textDefinition` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));

-- CREATE VIEW `sva_refset_OWLExpression` 

DROP VIEW IF EXISTS `sva_refset_OWLExpression`;

CREATE VIEW `sva_refset_OWLExpression` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`owlExpression` `owlExpression`
	FROM `sct_refset_OWLExpression` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_OWLExpression` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`)))));


-- Create Actual date view,View at Specified Snapshot Time;

-- CREATE VIEW `svx_refset_Simple` 

DROP VIEW IF EXISTS `svx_refset_Simple`;

CREATE VIEW `svx_refset_Simple` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`
	FROM `sct_refset_Simple` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_Simple` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_Association` 

DROP VIEW IF EXISTS `svx_refset_Association`;

CREATE VIEW `svx_refset_Association` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`targetComponentId` `targetComponentId`
	FROM `sct_refset_Association` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_Association` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_AttributeValue` 

DROP VIEW IF EXISTS `svx_refset_AttributeValue`;

CREATE VIEW `svx_refset_AttributeValue` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`valueId` `valueId`
	FROM `sct_refset_AttributeValue` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_AttributeValue` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_Language` 

DROP VIEW IF EXISTS `svx_refset_Language`;

CREATE VIEW `svx_refset_Language` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`acceptabilityId` `acceptabilityId`
	FROM `sct_refset_Language` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_Language` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_ExtendedMap` 

DROP VIEW IF EXISTS `svx_refset_ExtendedMap`;

CREATE VIEW `svx_refset_ExtendedMap` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`mapGroup` `mapGroup`,`tbl`.`mapPriority` `mapPriority`,`tbl`.`mapRule` `mapRule`,`tbl`.`mapAdvice` `mapAdvice`,`tbl`.`mapTarget` `mapTarget`,`tbl`.`correlationId` `correlationId`,`tbl`.`mapCategoryId` `mapCategoryId`
	FROM `sct_refset_ExtendedMap` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_ExtendedMap` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_SimpleMap` 

DROP VIEW IF EXISTS `svx_refset_SimpleMap`;

CREATE VIEW `svx_refset_SimpleMap` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`mapTarget` `mapTarget`
	FROM `sct_refset_SimpleMap` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_SimpleMap` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_MRCMModuleScope` 

DROP VIEW IF EXISTS `svx_refset_MRCMModuleScope`;

CREATE VIEW `svx_refset_MRCMModuleScope` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`mrcmRuleRefsetId` `mrcmRuleRefsetId`
	FROM `sct_refset_MRCMModuleScope` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMModuleScope` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_RefsetDescriptor` 

DROP VIEW IF EXISTS `svx_refset_RefsetDescriptor`;

CREATE VIEW `svx_refset_RefsetDescriptor` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`attributeDescription` `attributeDescription`,`tbl`.`attributeType` `attributeType`,`tbl`.`attributeOrder` `attributeOrder`
	FROM `sct_refset_RefsetDescriptor` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_RefsetDescriptor` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_DescriptionType` 

DROP VIEW IF EXISTS `svx_refset_DescriptionType`;

CREATE VIEW `svx_refset_DescriptionType` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`descriptionFormat` `descriptionFormat`,`tbl`.`descriptionLength` `descriptionLength`
	FROM `sct_refset_DescriptionType` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_DescriptionType` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_MRCMAttributeDomain` 

DROP VIEW IF EXISTS `svx_refset_MRCMAttributeDomain`;

CREATE VIEW `svx_refset_MRCMAttributeDomain` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`domainId` `domainId`,`tbl`.`grouped` `grouped`,`tbl`.`attributeCardinality` `attributeCardinality`,`tbl`.`attributeInGroupCardinality` `attributeInGroupCardinality`,`tbl`.`ruleStrengthId` `ruleStrengthId`,`tbl`.`contentTypeId` `contentTypeId`
	FROM `sct_refset_MRCMAttributeDomain` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMAttributeDomain` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_ModuleDependency` 

DROP VIEW IF EXISTS `svx_refset_ModuleDependency`;

CREATE VIEW `svx_refset_ModuleDependency` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`sourceEffectiveTime` `sourceEffectiveTime`,`tbl`.`targetEffectiveTime` `targetEffectiveTime`
	FROM `sct_refset_ModuleDependency` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_ModuleDependency` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_MRCMAttributeRange` 

DROP VIEW IF EXISTS `svx_refset_MRCMAttributeRange`;

CREATE VIEW `svx_refset_MRCMAttributeRange` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`rangeConstraint` `rangeConstraint`,`tbl`.`attributeRule` `attributeRule`,`tbl`.`ruleStrengthId` `ruleStrengthId`,`tbl`.`contentTypeId` `contentTypeId`
	FROM `sct_refset_MRCMAttributeRange` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMAttributeRange` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_MRCMDomain` 

DROP VIEW IF EXISTS `svx_refset_MRCMDomain`;

CREATE VIEW `svx_refset_MRCMDomain` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`domainConstraint` `domainConstraint`,`tbl`.`parentDomain` `parentDomain`,`tbl`.`proximalPrimitiveConstraint` `proximalPrimitiveConstraint`,`tbl`.`proximalPrimitiveRefinement` `proximalPrimitiveRefinement`,`tbl`.`domainTemplateForPrecoordination` `domainTemplateForPrecoordination`,`tbl`.`domainTemplateForPostcoordination` `domainTemplateForPostcoordination`,`tbl`.`guideURL` `guideURL`
	FROM `sct_refset_MRCMDomain` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_MRCMDomain` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_concept` 

DROP VIEW IF EXISTS `svx_concept`;

CREATE VIEW `svx_concept` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`definitionStatusId` `definitionStatusId`
	FROM `sct_concept` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_concept` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_description` 

DROP VIEW IF EXISTS `svx_description`;

CREATE VIEW `svx_description` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`conceptId` `conceptId`,`tbl`.`languageCode` `languageCode`,`tbl`.`typeId` `typeId`,`tbl`.`term` `term`,`tbl`.`caseSignificanceId` `caseSignificanceId`
	FROM `sct_description` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_description` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_relationship` 

DROP VIEW IF EXISTS `svx_relationship`;

CREATE VIEW `svx_relationship` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`sourceId` `sourceId`,`tbl`.`destinationId` `destinationId`,`tbl`.`relationshipGroup` `relationshipGroup`,`tbl`.`typeId` `typeId`,`tbl`.`characteristicTypeId` `characteristicTypeId`,`tbl`.`modifierId` `modifierId`
	FROM `sct_relationship` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_relationship` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_statedRelationship` 

DROP VIEW IF EXISTS `svx_statedRelationship`;

CREATE VIEW `svx_statedRelationship` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`sourceId` `sourceId`,`tbl`.`destinationId` `destinationId`,`tbl`.`relationshipGroup` `relationshipGroup`,`tbl`.`typeId` `typeId`,`tbl`.`characteristicTypeId` `characteristicTypeId`,`tbl`.`modifierId` `modifierId`
	FROM `sct_statedRelationship` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_statedRelationship` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_textDefinition` 

DROP VIEW IF EXISTS `svx_textDefinition`;

CREATE VIEW `svx_textDefinition` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`conceptId` `conceptId`,`tbl`.`languageCode` `languageCode`,`tbl`.`typeId` `typeId`,`tbl`.`term` `term`,`tbl`.`caseSignificanceId` `caseSignificanceId`
	FROM `sct_textDefinition` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_textDefinition` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));

-- CREATE VIEW `svx_refset_OWLExpression` 

DROP VIEW IF EXISTS `svx_refset_OWLExpression`;

CREATE VIEW `svx_refset_OWLExpression` AS 
(SELECT `tbl`.`id` `id`,`tbl`.`effectiveTime` `effectiveTime`,`tbl`.`active` `active`,`tbl`.`moduleId` `moduleId`,`tbl`.`refsetId` `refsetId`,`tbl`.`referencedComponentId` `referencedComponentId`,`tbl`.`owlExpression` `owlExpression`
	FROM `sct_refset_OWLExpression` `tbl`
	WHERE (`tbl`.`effectiveTime` = (SELECT max(`sub`.`effectiveTime`)
	FROM `sct_refset_OWLExpression` `sub`
	WHERE ((`sub`.`id` = `tbl`.`id`) AND (`sub`.`effectiveTime` <= `getSnapshotTime`())))));


-- Create Unoptimized Special Views

SELECT Now() `Time Started`;
SELECT "STAGE: Create Unoptimized Special Views";

USE `sct`;
DELIMITER ;
-- Create Special Views for '$PREFIX$'

DROP VIEW IF EXISTS `sva_fsn`;

CREATE VIEW `sva_fsn` AS
(SELECT `d`.* FROM (`sva_description` `d`
	JOIN `sva_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000003001) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `sva_pref`;

CREATE VIEW `sva_pref` AS
(SELECT `d`.* FROM (`sva_description` `d`
	JOIN `sva_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `sva_syn`;

CREATE VIEW `sva_syn` AS
(SELECT `d`.* FROM (`sva_description` `d`
	JOIN `sva_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000549004)));

DROP VIEW IF EXISTS `sva_synall`;

CREATE VIEW `sva_synall` AS
(SELECT `d`.*,`rs`.acceptabilityId FROM (`sva_description` `d`
	JOIN `sva_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1)));

DROP VIEW IF EXISTS `sva_rel_pref`;

CREATE VIEW `sva_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sva_relationship` `r`
	JOIN `sva_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sva_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sva_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `sva_rel_fsn`;

CREATE VIEW `sva_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sva_relationship` `r`
	JOIN `sva_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sva_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sva_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `sva_rel_def_pref`;

CREATE VIEW `sva_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sva_relationship` `r`
	JOIN `sva_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sva_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sva_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `sva_rel_def_fsn`;

CREATE VIEW `sva_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sva_relationship` `r`
	JOIN `sva_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sva_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sva_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `sva_rel_child_fsn`;

CREATE VIEW `sva_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `sva_relationship` `r`
	JOIN `sva_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `sva_rel_parent_fsn`;

CREATE VIEW `sva_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `sva_relationship` `r`
	JOIN `sva_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `sva_rel_child_pref`;

CREATE VIEW `sva_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `sva_relationship` `r`
	JOIN `sva_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `sva_rel_parent_pref`;

CREATE VIEW `sva_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `sva_relationship` `r`
JOIN `sva_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));-- Create Special Views for '$PREFIX$'

DROP VIEW IF EXISTS `svx_fsn`;

CREATE VIEW `svx_fsn` AS
(SELECT `d`.* FROM (`svx_description` `d`
	JOIN `svx_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000003001) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `svx_pref`;

CREATE VIEW `svx_pref` AS
(SELECT `d`.* FROM (`svx_description` `d`
	JOIN `svx_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `svx_syn`;

CREATE VIEW `svx_syn` AS
(SELECT `d`.* FROM (`svx_description` `d`
	JOIN `svx_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000549004)));

DROP VIEW IF EXISTS `svx_synall`;

CREATE VIEW `svx_synall` AS
(SELECT `d`.*,`rs`.acceptabilityId FROM (`svx_description` `d`
	JOIN `svx_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1)));

DROP VIEW IF EXISTS `svx_rel_pref`;

CREATE VIEW `svx_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`svx_relationship` `r`
	JOIN `svx_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `svx_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `svx_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `svx_rel_fsn`;

CREATE VIEW `svx_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`svx_relationship` `r`
	JOIN `svx_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `svx_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `svx_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `svx_rel_def_pref`;

CREATE VIEW `svx_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`svx_relationship` `r`
	JOIN `svx_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `svx_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `svx_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `svx_rel_def_fsn`;

CREATE VIEW `svx_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`svx_relationship` `r`
	JOIN `svx_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `svx_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `svx_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `svx_rel_child_fsn`;

CREATE VIEW `svx_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `svx_relationship` `r`
	JOIN `svx_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `svx_rel_parent_fsn`;

CREATE VIEW `svx_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `svx_relationship` `r`
	JOIN `svx_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `svx_rel_child_pref`;

CREATE VIEW `svx_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `svx_relationship` `r`
	JOIN `svx_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `svx_rel_parent_pref`;

CREATE VIEW `svx_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `svx_relationship` `r`
JOIN `svx_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));SELECT "STAGE: Creating Transitive Closure Views";

CREATE  OR REPLACE VIEW `sva_transclose_pref` AS
SELECT `t`.`supertypeId`,`p2`.`term` `supertypeTerm`, `t`.`subtypeId`, `p`.`term` `subtypeTerm`
	FROM ss_transclose `t`
	JOIN `sva_pref` `p` ON `t`.`subtypeId`=`p`.`conceptId`
	JOIN `sva_pref` `p2` ON `t`.`supertypeId`=`p2`.`conceptId`;
	
CREATE  OR REPLACE VIEW `sva_proxprim_pref` AS
SELECT `t`.`supertypeId`,`p2`.`term` `supertypeTerm`, `t`.`subtypeId`, `p`.`term` `subtypeTerm`
	FROM `ss_proximal_primitives` `t`
	JOIN `sva_pref` `p` ON `t`.`subtypeId`=`p`.`conceptId`
	JOIN `sva_pref` `p2` ON `t`.`supertypeId`=`p2`.`conceptId`;

-- Update Superseded Times

SELECT Now() `Time Started`;
SELECT "STAGE: Update Superseded Times";

USE `sct`;
DELIMITER ;


SET SQL_SAFE_UPDATES=0;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_Simple` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_Simple` `tbl`;

UPDATE `sct_refset_Simple` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_Association` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_Association` `tbl`;

UPDATE `sct_refset_Association` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_AttributeValue` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_AttributeValue` `tbl`;

UPDATE `sct_refset_AttributeValue` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_Language` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_Language` `tbl`;

UPDATE `sct_refset_Language` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_ExtendedMap` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_ExtendedMap` `tbl`;

UPDATE `sct_refset_ExtendedMap` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_SimpleMap` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_SimpleMap` `tbl`;

UPDATE `sct_refset_SimpleMap` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_MRCMModuleScope` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_MRCMModuleScope` `tbl`;

UPDATE `sct_refset_MRCMModuleScope` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_RefsetDescriptor` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_RefsetDescriptor` `tbl`;

UPDATE `sct_refset_RefsetDescriptor` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_DescriptionType` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_DescriptionType` `tbl`;

UPDATE `sct_refset_DescriptionType` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_MRCMAttributeDomain` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_MRCMAttributeDomain` `tbl`;

UPDATE `sct_refset_MRCMAttributeDomain` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_ModuleDependency` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_ModuleDependency` `tbl`;

UPDATE `sct_refset_ModuleDependency` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_MRCMAttributeRange` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_MRCMAttributeRange` `tbl`;

UPDATE `sct_refset_MRCMAttributeRange` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_MRCMDomain` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_MRCMDomain` `tbl`;

UPDATE `sct_refset_MRCMDomain` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT NOT NULL DEFAULT  0,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_concept` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_concept` `tbl`;

UPDATE `sct_concept` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT NOT NULL DEFAULT  0,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_description` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_description` `tbl`;

UPDATE `sct_description` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT NOT NULL DEFAULT  0,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_relationship` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_relationship` `tbl`;

UPDATE `sct_relationship` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT NOT NULL DEFAULT  0,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_statedRelationship` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_statedRelationship` `tbl`;

UPDATE `sct_statedRelationship` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BIGINT NOT NULL DEFAULT  0,`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_textDefinition` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_textDefinition` `tbl`;

UPDATE `sct_textDefinition` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;

CREATE TEMPORARY TABLE `tmp` (`id` BINARY(16) NOT NULL DEFAULT  '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',`effectiveTime` DATETIME,`supersededTime` DATETIME, PRIMARY KEY (`id`,`effectiveTime`));

INSERT INTO `tmp` SELECT `tbl`.`id`, `tbl`.`effectiveTime`, (SELECT IFNULL(MIN(`sub`.`effectiveTime`),DATE "99991231") FROM `sct_refset_OWLExpression` `sub`
	WHERE `tbl`.`id`=`sub`.`id` AND `tbl`.`effectiveTime`<`sub`.`effectiveTime`) `supersededTime` FROM `sct_refset_OWLExpression` `tbl`;

UPDATE `sct_refset_OWLExpression` `tbl`
	JOIN `tmp`
	SET `tbl`.`supersededTime`=`tmp`.`supersededTime`
		WHERE `tmp`.`id`=`tbl`.`id` AND `tmp`.`effectiveTime`=`tbl`.`effectiveTime`;

DROP TABLE IF EXISTS `tmp`;
-- Create Optimized Views

SELECT Now() `Time Started`;
SELECT "STAGE: Create Optimized Views";

USE `sct`;
DELIMITER ;


-- Create Optimized Current View,Optimized View at Specified Snapshot Time;

-- CREATE VIEW `soa_refset_Simple` 

DROP VIEW IF EXISTS `soa_refset_Simple`;

CREATE VIEW `soa_refset_Simple` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`
	FROM `sct_refset_Simple`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_Association` 

DROP VIEW IF EXISTS `soa_refset_Association`;

CREATE VIEW `soa_refset_Association` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`targetComponentId`
	FROM `sct_refset_Association`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_AttributeValue` 

DROP VIEW IF EXISTS `soa_refset_AttributeValue`;

CREATE VIEW `soa_refset_AttributeValue` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`valueId`
	FROM `sct_refset_AttributeValue`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_Language` 

DROP VIEW IF EXISTS `soa_refset_Language`;

CREATE VIEW `soa_refset_Language` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`acceptabilityId`
	FROM `sct_refset_Language`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_ExtendedMap` 

DROP VIEW IF EXISTS `soa_refset_ExtendedMap`;

CREATE VIEW `soa_refset_ExtendedMap` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`
	FROM `sct_refset_ExtendedMap`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_SimpleMap` 

DROP VIEW IF EXISTS `soa_refset_SimpleMap`;

CREATE VIEW `soa_refset_SimpleMap` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapTarget`
	FROM `sct_refset_SimpleMap`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_MRCMModuleScope` 

DROP VIEW IF EXISTS `soa_refset_MRCMModuleScope`;

CREATE VIEW `soa_refset_MRCMModuleScope` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mrcmRuleRefsetId`
	FROM `sct_refset_MRCMModuleScope`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_RefsetDescriptor` 

DROP VIEW IF EXISTS `soa_refset_RefsetDescriptor`;

CREATE VIEW `soa_refset_RefsetDescriptor` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`
	FROM `sct_refset_RefsetDescriptor`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_DescriptionType` 

DROP VIEW IF EXISTS `soa_refset_DescriptionType`;

CREATE VIEW `soa_refset_DescriptionType` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`descriptionFormat`,`descriptionLength`
	FROM `sct_refset_DescriptionType`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_MRCMAttributeDomain` 

DROP VIEW IF EXISTS `soa_refset_MRCMAttributeDomain`;

CREATE VIEW `soa_refset_MRCMAttributeDomain` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainId`,`grouped`,`attributeCardinality`,`attributeInGroupCardinality`,`ruleStrengthId`,`contentTypeId`
	FROM `sct_refset_MRCMAttributeDomain`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_ModuleDependency` 

DROP VIEW IF EXISTS `soa_refset_ModuleDependency`;

CREATE VIEW `soa_refset_ModuleDependency` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`
	FROM `sct_refset_ModuleDependency`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_MRCMAttributeRange` 

DROP VIEW IF EXISTS `soa_refset_MRCMAttributeRange`;

CREATE VIEW `soa_refset_MRCMAttributeRange` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`rangeConstraint`,`attributeRule`,`ruleStrengthId`,`contentTypeId`
	FROM `sct_refset_MRCMAttributeRange`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_MRCMDomain` 

DROP VIEW IF EXISTS `soa_refset_MRCMDomain`;

CREATE VIEW `soa_refset_MRCMDomain` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainConstraint`,`parentDomain`,`proximalPrimitiveConstraint`,`proximalPrimitiveRefinement`,`domainTemplateForPrecoordination`,`domainTemplateForPostcoordination`,`guideURL`
	FROM `sct_refset_MRCMDomain`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_concept` 

DROP VIEW IF EXISTS `soa_concept`;

CREATE VIEW `soa_concept` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`definitionStatusId`
	FROM `sct_concept`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_description` 

DROP VIEW IF EXISTS `soa_description`;

CREATE VIEW `soa_description` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`
	FROM `sct_description`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_relationship` 

DROP VIEW IF EXISTS `soa_relationship`;

CREATE VIEW `soa_relationship` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`
	FROM `sct_relationship`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_statedRelationship` 

DROP VIEW IF EXISTS `soa_statedRelationship`;

CREATE VIEW `soa_statedRelationship` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`
	FROM `sct_statedRelationship`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_textDefinition` 

DROP VIEW IF EXISTS `soa_textDefinition`;

CREATE VIEW `soa_textDefinition` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`
	FROM `sct_textDefinition`
	WHERE `supersededTime` = DATE "99991231");

-- CREATE VIEW `soa_refset_OWLExpression` 

DROP VIEW IF EXISTS `soa_refset_OWLExpression`;

CREATE VIEW `soa_refset_OWLExpression` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`owlExpression`
	FROM `sct_refset_OWLExpression`
	WHERE `supersededTime` = DATE "99991231");


-- Create Optimized Current View,Optimized View at Specified Snapshot Time;

-- CREATE VIEW `sox_refset_Simple` 

DROP VIEW IF EXISTS `sox_refset_Simple`;

CREATE VIEW `sox_refset_Simple` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`
	FROM `sct_refset_Simple`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_Association` 

DROP VIEW IF EXISTS `sox_refset_Association`;

CREATE VIEW `sox_refset_Association` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`targetComponentId`
	FROM `sct_refset_Association`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_AttributeValue` 

DROP VIEW IF EXISTS `sox_refset_AttributeValue`;

CREATE VIEW `sox_refset_AttributeValue` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`valueId`
	FROM `sct_refset_AttributeValue`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_Language` 

DROP VIEW IF EXISTS `sox_refset_Language`;

CREATE VIEW `sox_refset_Language` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`acceptabilityId`
	FROM `sct_refset_Language`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_ExtendedMap` 

DROP VIEW IF EXISTS `sox_refset_ExtendedMap`;

CREATE VIEW `sox_refset_ExtendedMap` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`
	FROM `sct_refset_ExtendedMap`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_SimpleMap` 

DROP VIEW IF EXISTS `sox_refset_SimpleMap`;

CREATE VIEW `sox_refset_SimpleMap` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapTarget`
	FROM `sct_refset_SimpleMap`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_MRCMModuleScope` 

DROP VIEW IF EXISTS `sox_refset_MRCMModuleScope`;

CREATE VIEW `sox_refset_MRCMModuleScope` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mrcmRuleRefsetId`
	FROM `sct_refset_MRCMModuleScope`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_RefsetDescriptor` 

DROP VIEW IF EXISTS `sox_refset_RefsetDescriptor`;

CREATE VIEW `sox_refset_RefsetDescriptor` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`
	FROM `sct_refset_RefsetDescriptor`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_DescriptionType` 

DROP VIEW IF EXISTS `sox_refset_DescriptionType`;

CREATE VIEW `sox_refset_DescriptionType` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`descriptionFormat`,`descriptionLength`
	FROM `sct_refset_DescriptionType`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_MRCMAttributeDomain` 

DROP VIEW IF EXISTS `sox_refset_MRCMAttributeDomain`;

CREATE VIEW `sox_refset_MRCMAttributeDomain` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainId`,`grouped`,`attributeCardinality`,`attributeInGroupCardinality`,`ruleStrengthId`,`contentTypeId`
	FROM `sct_refset_MRCMAttributeDomain`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_ModuleDependency` 

DROP VIEW IF EXISTS `sox_refset_ModuleDependency`;

CREATE VIEW `sox_refset_ModuleDependency` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`
	FROM `sct_refset_ModuleDependency`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_MRCMAttributeRange` 

DROP VIEW IF EXISTS `sox_refset_MRCMAttributeRange`;

CREATE VIEW `sox_refset_MRCMAttributeRange` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`rangeConstraint`,`attributeRule`,`ruleStrengthId`,`contentTypeId`
	FROM `sct_refset_MRCMAttributeRange`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_MRCMDomain` 

DROP VIEW IF EXISTS `sox_refset_MRCMDomain`;

CREATE VIEW `sox_refset_MRCMDomain` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainConstraint`,`parentDomain`,`proximalPrimitiveConstraint`,`proximalPrimitiveRefinement`,`domainTemplateForPrecoordination`,`domainTemplateForPostcoordination`,`guideURL`
	FROM `sct_refset_MRCMDomain`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_concept` 

DROP VIEW IF EXISTS `sox_concept`;

CREATE VIEW `sox_concept` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`definitionStatusId`
	FROM `sct_concept`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_description` 

DROP VIEW IF EXISTS `sox_description`;

CREATE VIEW `sox_description` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`
	FROM `sct_description`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_relationship` 

DROP VIEW IF EXISTS `sox_relationship`;

CREATE VIEW `sox_relationship` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`
	FROM `sct_relationship`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_statedRelationship` 

DROP VIEW IF EXISTS `sox_statedRelationship`;

CREATE VIEW `sox_statedRelationship` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`
	FROM `sct_statedRelationship`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_textDefinition` 

DROP VIEW IF EXISTS `sox_textDefinition`;

CREATE VIEW `sox_textDefinition` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`
	FROM `sct_textDefinition`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));

-- CREATE VIEW `sox_refset_OWLExpression` 

DROP VIEW IF EXISTS `sox_refset_OWLExpression`;

CREATE VIEW `sox_refset_OWLExpression` AS 
(SELECT `id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`owlExpression`
	FROM `sct_refset_OWLExpression`
	WHERE ((`getsnapshotTime`() >= `effectiveTime`) AND (`getSnapshotTime`() < `supersededTime`)));


-- Create Optimized Special Views

SELECT Now() `Time Started`;
SELECT "STAGE: Create Optimized Special Views";

USE `sct`;
DELIMITER ;
-- Create Special Views for '$PREFIX$'

DROP VIEW IF EXISTS `soa_fsn`;

CREATE VIEW `soa_fsn` AS
(SELECT `d`.* FROM (`soa_description` `d`
	JOIN `soa_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000003001) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `soa_pref`;

CREATE VIEW `soa_pref` AS
(SELECT `d`.* FROM (`soa_description` `d`
	JOIN `soa_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `soa_syn`;

CREATE VIEW `soa_syn` AS
(SELECT `d`.* FROM (`soa_description` `d`
	JOIN `soa_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000549004)));

DROP VIEW IF EXISTS `soa_synall`;

CREATE VIEW `soa_synall` AS
(SELECT `d`.*,`rs`.acceptabilityId FROM (`soa_description` `d`
	JOIN `soa_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1)));

DROP VIEW IF EXISTS `soa_rel_pref`;

CREATE VIEW `soa_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`soa_relationship` `r`
	JOIN `soa_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `soa_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `soa_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `soa_rel_fsn`;

CREATE VIEW `soa_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`soa_relationship` `r`
	JOIN `soa_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `soa_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `soa_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `soa_rel_def_pref`;

CREATE VIEW `soa_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`soa_relationship` `r`
	JOIN `soa_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `soa_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `soa_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `soa_rel_def_fsn`;

CREATE VIEW `soa_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`soa_relationship` `r`
	JOIN `soa_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `soa_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `soa_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `soa_rel_child_fsn`;

CREATE VIEW `soa_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `soa_relationship` `r`
	JOIN `soa_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `soa_rel_parent_fsn`;

CREATE VIEW `soa_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `soa_relationship` `r`
	JOIN `soa_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `soa_rel_child_pref`;

CREATE VIEW `soa_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `soa_relationship` `r`
	JOIN `soa_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `soa_rel_parent_pref`;

CREATE VIEW `soa_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `soa_relationship` `r`
JOIN `soa_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));-- Create Special Views for '$PREFIX$'

DROP VIEW IF EXISTS `sox_fsn`;

CREATE VIEW `sox_fsn` AS
(SELECT `d`.* FROM (`sox_description` `d`
	JOIN `sox_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000003001) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `sox_pref`;

CREATE VIEW `sox_pref` AS
(SELECT `d`.* FROM (`sox_description` `d`
	JOIN `sox_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000548007)));

DROP VIEW IF EXISTS `sox_syn`;

CREATE VIEW `sox_syn` AS
(SELECT `d`.* FROM (`sox_description` `d`
	JOIN `sox_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1) AND (`rs`.`acceptabilityId` = 900000000000549004)));

DROP VIEW IF EXISTS `sox_synall`;

CREATE VIEW `sox_synall` AS
(SELECT `d`.*,`rs`.acceptabilityId FROM (`sox_description` `d`
	JOIN `sox_refset_Language` `rs` ON ((`d`.`id` = `rs`.`referencedComponentId`))) WHERE ((`d`.`active` = 1) AND (`d`.`typeId` = 900000000000013009) AND (`rs`.`refSetId` = getLanguage()) AND (`rs`.`active` = 1)));

DROP VIEW IF EXISTS `sox_rel_pref`;

CREATE VIEW `sox_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sox_relationship` `r`
	JOIN `sox_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sox_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sox_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `sox_rel_fsn`;

CREATE VIEW `sox_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sox_relationship` `r`
	JOIN `sox_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sox_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sox_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `sox_rel_def_pref`;

CREATE VIEW `sox_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sox_relationship` `r`
	JOIN `sox_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sox_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sox_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `sox_rel_def_fsn`;

CREATE VIEW `sox_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`sox_relationship` `r`
	JOIN `sox_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `sox_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `sox_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `sox_rel_child_fsn`;

CREATE VIEW `sox_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `sox_relationship` `r`
	JOIN `sox_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `sox_rel_parent_fsn`;

CREATE VIEW `sox_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `sox_relationship` `r`
	JOIN `sox_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `sox_rel_child_pref`;

CREATE VIEW `sox_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `sox_relationship` `r`
	JOIN `sox_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `sox_rel_parent_pref`;

CREATE VIEW `sox_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `sox_relationship` `r`
JOIN `sox_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));SELECT "STAGE: Creating Transitive Closure Views";

CREATE  OR REPLACE VIEW `soa_transclose_pref` AS
SELECT `t`.`supertypeId`,`p2`.`term` `supertypeTerm`, `t`.`subtypeId`, `p`.`term` `subtypeTerm`
	FROM ss_transclose `t`
	JOIN `soa_pref` `p` ON `t`.`subtypeId`=`p`.`conceptId`
	JOIN `soa_pref` `p2` ON `t`.`supertypeId`=`p2`.`conceptId`;
	
CREATE  OR REPLACE VIEW `soa_proxprim_pref` AS
SELECT `t`.`supertypeId`,`p2`.`term` `supertypeTerm`, `t`.`subtypeId`, `p`.`term` `subtypeTerm`
	FROM `ss_proximal_primitives` `t`
	JOIN `soa_pref` `p` ON `t`.`subtypeId`=`p`.`conceptId`
	JOIN `soa_pref` `p2` ON `t`.`supertypeId`=`p2`.`conceptId`;

-- Add Additional Indexes

SELECT Now() `Time Started`;
SELECT "STAGE: Add Additional Indexes";

USE `sct`;
DELIMITER ;

-- Index `sct_refset_Simple` 

ALTER TABLE `sct_refset_Simple`
ADD INDEX `Simple_super` (`id`,`supersededTime`),
ADD INDEX `Simple_c` (`referencedComponentId`),
ADD INDEX `Simple_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `Simple_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_Association` 

ALTER TABLE `sct_refset_Association`
ADD INDEX `Association_super` (`id`,`supersededTime`),
ADD INDEX `Association_c` (`referencedComponentId`),
ADD INDEX `Association_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `Association_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_AttributeValue` 

ALTER TABLE `sct_refset_AttributeValue`
ADD INDEX `AttributeValue_super` (`id`,`supersededTime`),
ADD INDEX `AttributeValue_c` (`referencedComponentId`),
ADD INDEX `AttributeValue_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `AttributeValue_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_Language` 

ALTER TABLE `sct_refset_Language`
ADD INDEX `Language_super` (`id`,`supersededTime`),
ADD INDEX `Language_c` (`referencedComponentId`),
ADD INDEX `Language_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `Language_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_ExtendedMap` 

ALTER TABLE `sct_refset_ExtendedMap`
ADD INDEX `ExtendedMap_super` (`id`,`supersededTime`),
ADD INDEX `ExtendedMap_c` (`referencedComponentId`),
ADD INDEX `ExtendedMap_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `ExtendedMap_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`),
ADD INDEX `ExtendedMap_map` (`mapTarget`);

-- Index `sct_refset_SimpleMap` 

ALTER TABLE `sct_refset_SimpleMap`
ADD INDEX `SimpleMap_super` (`id`,`supersededTime`),
ADD INDEX `SimpleMap_c` (`referencedComponentId`),
ADD INDEX `SimpleMap_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `SimpleMap_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`),
ADD INDEX `SimpleMap_map` (`mapTarget`);

-- Index `sct_refset_MRCMModuleScope` 

ALTER TABLE `sct_refset_MRCMModuleScope`
ADD INDEX `MRCMModuleScope_super` (`id`,`supersededTime`),
ADD INDEX `MRCMModuleScope_c` (`referencedComponentId`),
ADD INDEX `MRCMModuleScope_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `MRCMModuleScope_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_RefsetDescriptor` 

ALTER TABLE `sct_refset_RefsetDescriptor`
ADD INDEX `RefsetDescriptor_super` (`id`,`supersededTime`),
ADD INDEX `RefsetDescriptor_c` (`referencedComponentId`),
ADD INDEX `RefsetDescriptor_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `RefsetDescriptor_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_DescriptionType` 

ALTER TABLE `sct_refset_DescriptionType`
ADD INDEX `DescriptionType_super` (`id`,`supersededTime`);

-- Index `sct_refset_MRCMAttributeDomain` 

ALTER TABLE `sct_refset_MRCMAttributeDomain`
ADD INDEX `MRCMAttributeDomain_super` (`id`,`supersededTime`),
ADD INDEX `MRCMAttributeDomain_c` (`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_dom` (`domainId`);

-- Index `sct_refset_ModuleDependency` 

ALTER TABLE `sct_refset_ModuleDependency`
ADD INDEX `ModuleDependency_super` (`id`,`supersededTime`),
ADD INDEX `ModuleDependency_c` (`referencedComponentId`),
ADD INDEX `ModuleDependency_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `ModuleDependency_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_MRCMAttributeRange` 

ALTER TABLE `sct_refset_MRCMAttributeRange`
ADD INDEX `MRCMAttributeRange_super` (`id`,`supersededTime`),
ADD INDEX `MRCMAttributeRange_c` (`referencedComponentId`),
ADD INDEX `MRCMAttributeRange_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `MRCMAttributeRange_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_refset_MRCMDomain` 

ALTER TABLE `sct_refset_MRCMDomain`
ADD INDEX `MRCMDomain_super` (`id`,`supersededTime`),
ADD INDEX `MRCMDomain_c` (`referencedComponentId`),
ADD INDEX `MRCMDomain_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `MRCMDomain_rsc` (`refsetId`,`supersededTime`,`referencedComponentId`);

-- Index `sct_concept` 

ALTER TABLE `sct_concept`
ADD INDEX `concept_super` (`id`,`supersededTime`);

-- Index `sct_description` 

ALTER TABLE `sct_description`
ADD INDEX `description_super` (`id`,`supersededTime`),
ADD INDEX `description_concept` (`conceptId`,`supersededTime`,`languageCode`);


ALTER TABLE `sct_description`ADD FULLTEXT INDEX `description_term` (`term`);

-- Index `sct_relationship` 

ALTER TABLE `sct_relationship`
ADD INDEX `relationship_super` (`id`,`supersededTime`),
ADD INDEX `relationship_source` (`sourceId`,`characteristicTypeId`,`typeId`,`destinationId`),
ADD INDEX `relationship_dest` (`destinationId`,`characteristicTypeId`,`sourceId`),
ADD INDEX `relationship_source2` (`sourceId`,`supersededTime`,`characteristicTypeId`,`typeId`,`destinationId`),
ADD INDEX `relationship_dest2` (`destinationId`,`supersededTime`,`characteristicTypeId`,`sourceId`);

-- Index `sct_statedRelationship` 

ALTER TABLE `sct_statedRelationship`
ADD INDEX `statedRelationship_super` (`id`,`supersededTime`),
ADD INDEX `statedRelationship_source` (`sourceId`,`characteristicTypeId`,`typeId`,`destinationId`),
ADD INDEX `statedRelationship_dest` (`destinationId`,`characteristicTypeId`,`sourceId`),
ADD INDEX `statedRelationship_source2` (`sourceId`,`supersededTime`,`characteristicTypeId`,`typeId`,`destinationId`),
ADD INDEX `statedRelationship_dest2` (`destinationId`,`supersededTime`,`characteristicTypeId`,`sourceId`);

-- Index `sct_textDefinition` 

ALTER TABLE `sct_textDefinition`
ADD INDEX `textDefinition_super` (`id`,`supersededTime`),
ADD INDEX `textDefinition_concept` (`conceptId`,`supersededTime`,`languageCode`);

-- Index `sct_refset_OWLExpression` 

ALTER TABLE `sct_refset_OWLExpression`
ADD INDEX `OWLExpression_super` (`id`,`supersededTime`),
ADD INDEX `OWLExpression_c` (`referencedComponentId`),
ADD INDEX `OWLExpression_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `OWLExpression_rsc` (`refsetId`,`supersededTime`);

-- #TRANSCLOSE#
-- ===============================================
-- REQUIRES TRANSCLOSE
-- IF YOU DO NOT HAVE A TRANSITIVE CLOSURE FILE
-- DELETE FROM THIS POINT TO THE END OF THE SCRIPT
-- ================================================

-- The SQL Script Generate a Snapshot View Table 
-- that links all concepts to all their Supertype Ancestors


SELECT "STAGE: Loading Transitive Closure Data and Generating Proximal Primitives";

USE `sct`;

LOAD DATA LOCAL INFILE '$RELPATH/xder_TransitiveClosure_Snapshot_INT_20190131.txt'
	INTO TABLE `ss_transclose`
	LINES TERMINATED BY '\n'
	(`subtypeId`,`supertypeId`);

-- Create proximal primitive supertypes table
	
DROP TABLE IF EXISTS `ss_supertypes_defprim`;
DROP TABLE IF EXISTS `ss_supertypes_primprim`;
DROP TABLE IF EXISTS `ss_supertypes_prim_nonprox`;

CREATE TEMPORARY TABLE `ss_supertypes_defprim` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `p_rev` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TEMPORARY TABLE `ss_supertypes_primprim` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `pp_rev` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TEMPORARY TABLE `ss_supertypes_prim_nonprox` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `p_rev` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Create table with Primitive Supertypes only and ignore rows where subtypes is primitive
INSERT INTO `ss_supertypes_defprim`
SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
	FROM ss_transclose `tc`
	JOIN `soa_concept` `c` on `c`.`id`=`tc`.`supertypeId` 
		AND `c`.`definitionStatusId`=900000000000074008
    JOIN `soa_concept` `c2` on `c2`.`id`=`tc`.`subtypeId`
		AND `c2`.`definitionStatusId`<>900000000000074008
WHERE `tc`.`supertypeId`<>138875005;

-- Now for all concepts that are primitive supertypes get their primitive supertypes
INSERT INTO `ss_supertypes_primprim`
SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
	FROM ss_transclose `tc`
	JOIN `soa_concept` `c` on `c`.`id`=`tc`.`supertypeId` 
		AND `c`.`definitionStatusId`=900000000000074008
    WHERE `tc`.`subtypeId` IN (SELECT `supertypeId`
			FROM `ss_supertypes_defprim`)
		AND `tc`.`supertypeId`<>138875005;

-- Now identify the non-promixal relationships
INSERT INTO `ss_supertypes_prim_nonprox`
SELECT DISTINCT `tc`.`subtypeId`,`tp`.`supertypeId`
	FROM `ss_supertypes_defprim` `tc`
	JOIN `ss_supertypes_primprim` `tp` ON `tp`.`subtypeId`=`tc`.`supertypeId`;

-- Now insert the proximal primitives into the table
INSERT INTO `ss_proximal_primitives` 
SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
	FROM `ss_supertypes_defprim` `tc`
	WHERE NOT EXISTS(SELECT * FROM `ss_supertypes_prim_nonprox` `tp`
	WHERE `tp`.`subtypeId`=`tc`.`subtypeId` 
		AND `tp`.`supertypeId`=`tc`.`supertypeId`);

		
