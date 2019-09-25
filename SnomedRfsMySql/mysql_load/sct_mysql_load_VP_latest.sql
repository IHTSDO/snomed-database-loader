-- IMPORTS SNOMED CT RF2 FULL RELEASE INTO MYSQL DATA BASE

-- MySQL Script for Loading and Optimizing SNOMED CT Release Files
-- Apache 2.0 license applies
-- 
-- =======================================================
-- Copyright of this version 2018: SNOMED International www.snomed.org
-- Based on work by David Markwell between 2011 and 2019
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
-- This MySQL script file is designed to load the following SNOMED CT release package
-- into a MySQL database.
-- Release Package: SnomedCT_InternationalRF2_PRODUCTION_20190731T120000Z 
--
-- If you are working with another version of the same release package
-- this script MAY work with that package. 
-- However:
-- a) if the release package being imported contains file types not present in
--    the version for which this is configured those files will not be imported.
-- b) if the release package being imported does not contains files of the types
--    present in the original version the import process will fail when attempting
--    to import missing files.
-- 
-- 2. IF YOU ARE MANUALLY EDITING THIS FILE
-- ========================================
-- Make a copy of the file and then:
-- 
-- a) Replace all instances of the following placeholders with appropriate values:
--
--  $RELPATH : The path to the release package folder.
--  $DBNAME  : The name of database to be created      (e.g. snomedct )
--  $RELDATE : The release date in the YYYYMMDD format (e.g. 20190731)
--
-- b) If you have NOT created the transitive closure table
--    Replace all instances of 
--     '-- ifTC'  with '/*'
--    and replace all instances of 
--     '-- fiTC'  with '*/'
--
-- 3. SAVE AND RUN THE SCRIPT
-- ==========================
-- Save a copy of the SQL script with any modifications you have made.
-- Run this script in MySQL (e.g. through the MySQL Workbench).
--
/*

USE A TERMINAL COMMAND LIKE THE FOLLOWING TO RUN THE IMPORT

 mysql --defaults-file="$mysql_cnf_filename"  --protocol=tcp --host=localhost --port=$portnumber default-character-set=utf8mb4 --password  < "$sct_mysql_load_filename"

REPLACEMENTS IN THE COMMAND LINE

$mysql_cnf_filename :  The full path of the MySQL configuration file to be used when running the script (e.g. /etct/my.cnf)

$portnumber :  The portnumber on which the MySQL server is running.

$sct_mysql_load_filename : The full path to your copy of this file with the modification noted above.

RECOMMENDED SETTINGS FOR THE my.cnf FILE

[mysqld]
local-infile=1
ft_stopword_file = ''
ft_min_word_len = 2
disable-log-bin
skip-log-bin
default-authentication-plugin=mysql_native_password
[mysql]
local-infile=1
ft_stopword_file = '' 
ft_min_word_len = 2
[client]
local-infile=1
protocol=tcp
host=localhost
port=3306

 END OF HEADER */
 -- END OF HEADER

/*
	CONFIGURATION SETTINGS USED WHEN PRODUCING THIS VERSION
	
	Release Package: SnomedCT_InternationalRF2_PRODUCTION_20190731T120000Z
	Configuration Options
	{"reltype":"full","tablePrefix":"full","fileType":"Full","relpath":"$RELPATH","dbname":"$DBNAME","dbengine":"MyISAM","charset":"utf8mb4","optimization":"concrete","optimizationCol":"","extend":false,"uuid":"char(36)","rfsFolder":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/rfs","sqlFolder":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/sql","templateFolder":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/templates","sqlLoaderFolder":"$EPSDRIVE/SnomedRfs/SnomedRfsMySql/mysql_load","sqlFileTag":"$TS","rfsGetinfo":"getinfo_latest","rfsReference":"reference_latest","releaseRoot":"$HOME/SnomedCT_ReleaseFiles","releasePackage":"","releaseDate":"","pathTag":"VP","releasePackagePath":"$HOME/SnomedCT_ReleaseFiles","sqlScriptPath":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/sql/sct_mysql_load_VP_$TS.sql","sqlLatestPath":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/sql/sct_mysql_load_VP_latest.sql","sqlLoaderPath":"$EPSDRIVE/SnomedRfs/SnomedRfsMySql/mysql_load/sct_mysql_load_VP_latest.sql","rfsGetinfoPath":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/rfs/rfs_getinfo_latest.json","rfsRefPath":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/rfs/rfs_reference_latest.json","rfsOutPath":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/rfs/rfs_output_latest.json","rfsLatestPath":"$EPSDRIVE/SnomedRfs/SnomedRfsFactory/rfs/rfs_getinfo_latest.json","extraTemplates":"proc_ecl,proc_search,proc_languages,table_shortcuts","extras":[]}
*/


SELECT Now() `--`,"Create Database and Initialize" '--';
-- CREATE DATABASE
DROP DATABASE IF EXISTS `$DBNAME`; 
CREATE DATABASE `$DBNAME` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `$DBNAME`;
-- INITIALIZE SETTINGS
SET GLOBAL net_write_timeout = 60;
SET GLOBAL net_read_timeout=120;
SET GLOBAL sql_mode ='';
SET SESSION sql_mode ='';
DELIMITER ;

-- Create Tables --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Tables";

-- createTables(full);

-- CREATE TABLE `full_refset_Simple` 

DROP TABLE IF EXISTS `full_refset_Simple`;

CREATE TABLE `full_refset_Simple` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_Association` 

DROP TABLE IF EXISTS `full_refset_Association`;

CREATE TABLE `full_refset_Association` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`targetComponentId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_AttributeValue` 

DROP TABLE IF EXISTS `full_refset_AttributeValue`;

CREATE TABLE `full_refset_AttributeValue` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`valueId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_Language` 

DROP TABLE IF EXISTS `full_refset_Language`;

CREATE TABLE `full_refset_Language` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`acceptabilityId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_ExtendedMap` 

DROP TABLE IF EXISTS `full_refset_ExtendedMap`;

CREATE TABLE `full_refset_ExtendedMap` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
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
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_SimpleMap` 

DROP TABLE IF EXISTS `full_refset_SimpleMap`;

CREATE TABLE `full_refset_SimpleMap` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mapTarget` VARCHAR (200) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_MRCMModuleScope` 

DROP TABLE IF EXISTS `full_refset_MRCMModuleScope`;

CREATE TABLE `full_refset_MRCMModuleScope` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mrcmRuleRefsetId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_RefsetDescriptor` 

DROP TABLE IF EXISTS `full_refset_RefsetDescriptor`;

CREATE TABLE `full_refset_RefsetDescriptor` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`attributeDescription` BIGINT NOT NULL DEFAULT  0,
	`attributeType` BIGINT NOT NULL DEFAULT  0,
	`attributeOrder` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_DescriptionType` 

DROP TABLE IF EXISTS `full_refset_DescriptionType`;

CREATE TABLE `full_refset_DescriptionType` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`descriptionFormat` BIGINT NOT NULL DEFAULT  0,
	`descriptionLength` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_MRCMAttributeDomain` 

DROP TABLE IF EXISTS `full_refset_MRCMAttributeDomain`;

CREATE TABLE `full_refset_MRCMAttributeDomain` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
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
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_ModuleDependency` 

DROP TABLE IF EXISTS `full_refset_ModuleDependency`;

CREATE TABLE `full_refset_ModuleDependency` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`sourceEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`targetEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_MRCMAttributeRange` 

DROP TABLE IF EXISTS `full_refset_MRCMAttributeRange`;

CREATE TABLE `full_refset_MRCMAttributeRange` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`rangeConstraint` TEXT NOT NULL,
	`attributeRule` TEXT NOT NULL,
	`ruleStrengthId` BIGINT NOT NULL DEFAULT  0,
	`contentTypeId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_MRCMDomain` 

DROP TABLE IF EXISTS `full_refset_MRCMDomain`;

CREATE TABLE `full_refset_MRCMDomain` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
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
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_concept` 

DROP TABLE IF EXISTS `full_concept`;

CREATE TABLE `full_concept` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`definitionStatusId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_description` 

DROP TABLE IF EXISTS `full_description`;

CREATE TABLE `full_description` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`conceptId` BIGINT NOT NULL DEFAULT  0,
	`languageCode` VARCHAR (3) NOT NULL DEFAULT '',
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`term` TEXT NOT NULL,
	`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_relationship` 

DROP TABLE IF EXISTS `full_relationship`;

CREATE TABLE `full_relationship` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`sourceId` BIGINT NOT NULL DEFAULT  0,
	`destinationId` BIGINT NOT NULL DEFAULT  0,
	`relationshipGroup` INT NOT NULL DEFAULT 0,
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
	`modifierId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_statedRelationship` 

DROP TABLE IF EXISTS `full_statedRelationship`;

CREATE TABLE `full_statedRelationship` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`sourceId` BIGINT NOT NULL DEFAULT  0,
	`destinationId` BIGINT NOT NULL DEFAULT  0,
	`relationshipGroup` INT NOT NULL DEFAULT 0,
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
	`modifierId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_textDefinition` 

DROP TABLE IF EXISTS `full_textDefinition`;

CREATE TABLE `full_textDefinition` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`conceptId` BIGINT NOT NULL DEFAULT  0,
	`languageCode` VARCHAR (3) NOT NULL DEFAULT '',
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`term` TEXT NOT NULL,
	`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `full_refset_OWLExpression` 

DROP TABLE IF EXISTS `full_refset_OWLExpression`;

CREATE TABLE `full_refset_OWLExpression` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`owlExpression` TEXT NOT NULL,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- createTables(snap);

-- CREATE TABLE `snap_refset_Simple` 

DROP TABLE IF EXISTS `snap_refset_Simple`;

CREATE TABLE `snap_refset_Simple` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_Association` 

DROP TABLE IF EXISTS `snap_refset_Association`;

CREATE TABLE `snap_refset_Association` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`targetComponentId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_AttributeValue` 

DROP TABLE IF EXISTS `snap_refset_AttributeValue`;

CREATE TABLE `snap_refset_AttributeValue` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`valueId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_Language` 

DROP TABLE IF EXISTS `snap_refset_Language`;

CREATE TABLE `snap_refset_Language` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`acceptabilityId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_ExtendedMap` 

DROP TABLE IF EXISTS `snap_refset_ExtendedMap`;

CREATE TABLE `snap_refset_ExtendedMap` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
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
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_SimpleMap` 

DROP TABLE IF EXISTS `snap_refset_SimpleMap`;

CREATE TABLE `snap_refset_SimpleMap` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mapTarget` VARCHAR (200) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_MRCMModuleScope` 

DROP TABLE IF EXISTS `snap_refset_MRCMModuleScope`;

CREATE TABLE `snap_refset_MRCMModuleScope` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`mrcmRuleRefsetId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_RefsetDescriptor` 

DROP TABLE IF EXISTS `snap_refset_RefsetDescriptor`;

CREATE TABLE `snap_refset_RefsetDescriptor` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`attributeDescription` BIGINT NOT NULL DEFAULT  0,
	`attributeType` BIGINT NOT NULL DEFAULT  0,
	`attributeOrder` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_DescriptionType` 

DROP TABLE IF EXISTS `snap_refset_DescriptionType`;

CREATE TABLE `snap_refset_DescriptionType` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`descriptionFormat` BIGINT NOT NULL DEFAULT  0,
	`descriptionLength` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_MRCMAttributeDomain` 

DROP TABLE IF EXISTS `snap_refset_MRCMAttributeDomain`;

CREATE TABLE `snap_refset_MRCMAttributeDomain` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
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
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_ModuleDependency` 

DROP TABLE IF EXISTS `snap_refset_ModuleDependency`;

CREATE TABLE `snap_refset_ModuleDependency` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`sourceEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`targetEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_MRCMAttributeRange` 

DROP TABLE IF EXISTS `snap_refset_MRCMAttributeRange`;

CREATE TABLE `snap_refset_MRCMAttributeRange` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`rangeConstraint` TEXT NOT NULL,
	`attributeRule` TEXT NOT NULL,
	`ruleStrengthId` BIGINT NOT NULL DEFAULT  0,
	`contentTypeId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_MRCMDomain` 

DROP TABLE IF EXISTS `snap_refset_MRCMDomain`;

CREATE TABLE `snap_refset_MRCMDomain` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
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
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_concept` 

DROP TABLE IF EXISTS `snap_concept`;

CREATE TABLE `snap_concept` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`definitionStatusId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_description` 

DROP TABLE IF EXISTS `snap_description`;

CREATE TABLE `snap_description` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`conceptId` BIGINT NOT NULL DEFAULT  0,
	`languageCode` VARCHAR (3) NOT NULL DEFAULT '',
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`term` TEXT NOT NULL,
	`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_relationship` 

DROP TABLE IF EXISTS `snap_relationship`;

CREATE TABLE `snap_relationship` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`sourceId` BIGINT NOT NULL DEFAULT  0,
	`destinationId` BIGINT NOT NULL DEFAULT  0,
	`relationshipGroup` INT NOT NULL DEFAULT 0,
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
	`modifierId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_statedRelationship` 

DROP TABLE IF EXISTS `snap_statedRelationship`;

CREATE TABLE `snap_statedRelationship` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`sourceId` BIGINT NOT NULL DEFAULT  0,
	`destinationId` BIGINT NOT NULL DEFAULT  0,
	`relationshipGroup` INT NOT NULL DEFAULT 0,
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`characteristicTypeId` BIGINT NOT NULL DEFAULT  0,
	`modifierId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_textDefinition` 

DROP TABLE IF EXISTS `snap_textDefinition`;

CREATE TABLE `snap_textDefinition` (
	`id` BIGINT NOT NULL DEFAULT  0,
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`conceptId` BIGINT NOT NULL DEFAULT  0,
	`languageCode` VARCHAR (3) NOT NULL DEFAULT '',
	`typeId` BIGINT NOT NULL DEFAULT  0,
	`term` TEXT NOT NULL,
	`caseSignificanceId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE `snap_refset_OWLExpression` 

DROP TABLE IF EXISTS `snap_refset_OWLExpression`;

CREATE TABLE `snap_refset_OWLExpression` (
	`id` char(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`owlExpression` TEXT NOT NULL,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- Create Transitive Closure Table --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Transitive Closure Table";

-- createTransitiveTables();

-- CREATE TABLE `snap_transclose` 

DROP TABLE IF EXISTS `snap_transclose`;

CREATE TABLE `snap_transclose` (
	`subtypeId` BIGINT NOT NULL DEFAULT  0,
		`supertypeId` BIGINT NOT NULL DEFAULT  0,
		PRIMARY KEY (`subtypeId`,`supertypeId`),
		KEY `t_rev` (`supertypeId`,`subtypeId`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE snap_proximal_primitives 

DROP TABLE IF EXISTS snap_proximal_primitives;

CREATE TABLE snap_proximal_primitives (
	`subtypeId` BIGINT NOT NULL DEFAULT  0,
		`supertypeId` BIGINT NOT NULL DEFAULT  0,
		PRIMARY KEY (`subtypeId`,`supertypeId`),
		KEY `t_rev` (`supertypeId`,`subtypeId`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- Load Table Data --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data";

-- loadTableData(full);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_Refset_SimpleFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_Simple`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_cRefset_AssociationFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_Association`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`targetComponentId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_cRefset_AttributeValueFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_AttributeValue`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`valueId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Language/der2_cRefset_LanguageFull-en_INT_$RELDATE.txt'
INTO TABLE `full_refset_Language`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`acceptabilityId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Map/der2_iisssccRefset_ExtendedMapFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_ExtendedMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Map/der2_sRefset_SimpleMapFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_SimpleMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapTarget`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cRefset_MRCMModuleScopeFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_MRCMModuleScope`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mrcmRuleRefsetId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cciRefset_RefsetDescriptorFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_RefsetDescriptor`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ciRefset_DescriptionTypeFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_DescriptionType`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`descriptionFormat`,`descriptionLength`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cissccRefset_MRCMAttributeDomainFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_MRCMAttributeDomain`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainId`,`grouped`,`attributeCardinality`,`attributeInGroupCardinality`,`ruleStrengthId`,`contentTypeId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ssRefset_ModuleDependencyFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_ModuleDependency`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ssccRefset_MRCMAttributeRangeFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_MRCMAttributeRange`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`rangeConstraint`,`attributeRule`,`ruleStrengthId`,`contentTypeId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_sssssssRefset_MRCMDomainFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_MRCMDomain`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainConstraint`,`parentDomain`,`proximalPrimitiveConstraint`,`proximalPrimitiveRefinement`,`domainTemplateForPrecoordination`,`domainTemplateForPostcoordination`,`guideURL`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_Concept_Full_INT_$RELDATE.txt'
INTO TABLE `full_concept`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`definitionStatusId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_Description_Full-en_INT_$RELDATE.txt'
INTO TABLE `full_description`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_Relationship_Full_INT_$RELDATE.txt'
INTO TABLE `full_relationship`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_StatedRelationship_Full_INT_$RELDATE.txt'
INTO TABLE `full_statedRelationship`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_TextDefinition_Full-en_INT_$RELDATE.txt'
INTO TABLE `full_textDefinition`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);

LOAD DATA LOCAL INFILE '$RELPATH/Full/Terminology/sct2_sRefset_OWLExpressionFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_OWLExpression`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`owlExpression`);


-- loadTableData(snap);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Content/der2_Refset_SimpleSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_Simple`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Content/der2_cRefset_AssociationSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_Association`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`targetComponentId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Content/der2_cRefset_AttributeValueSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_AttributeValue`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`valueId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Language/der2_cRefset_LanguageSnapshot-en_INT_$RELDATE.txt'
INTO TABLE `snap_refset_Language`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`acceptabilityId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Map/der2_iisssccRefset_ExtendedMapSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_ExtendedMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Map/der2_sRefset_SimpleMapSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_SimpleMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapTarget`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_cRefset_MRCMModuleScopeSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_MRCMModuleScope`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mrcmRuleRefsetId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_cciRefset_RefsetDescriptorSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_RefsetDescriptor`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_ciRefset_DescriptionTypeSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_DescriptionType`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`descriptionFormat`,`descriptionLength`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_cissccRefset_MRCMAttributeDomainSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_MRCMAttributeDomain`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainId`,`grouped`,`attributeCardinality`,`attributeInGroupCardinality`,`ruleStrengthId`,`contentTypeId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_ssRefset_ModuleDependencySnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_ModuleDependency`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_ssccRefset_MRCMAttributeRangeSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_MRCMAttributeRange`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`rangeConstraint`,`attributeRule`,`ruleStrengthId`,`contentTypeId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_sssssssRefset_MRCMDomainSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_MRCMDomain`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainConstraint`,`parentDomain`,`proximalPrimitiveConstraint`,`proximalPrimitiveRefinement`,`domainTemplateForPrecoordination`,`domainTemplateForPostcoordination`,`guideURL`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Terminology/sct2_Concept_Snapshot_INT_$RELDATE.txt'
INTO TABLE `snap_concept`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`definitionStatusId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Terminology/sct2_Description_Snapshot-en_INT_$RELDATE.txt'
INTO TABLE `snap_description`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Terminology/sct2_Relationship_Snapshot_INT_$RELDATE.txt'
INTO TABLE `snap_relationship`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Terminology/sct2_StatedRelationship_Snapshot_INT_$RELDATE.txt'
INTO TABLE `snap_statedRelationship`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`sourceId`,`destinationId`,`relationshipGroup`,`typeId`,`characteristicTypeId`,`modifierId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Terminology/sct2_TextDefinition_Snapshot-en_INT_$RELDATE.txt'
INTO TABLE `snap_textDefinition`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`conceptId`,`languageCode`,`typeId`,`term`,`caseSignificanceId`);

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Terminology/sct2_sRefset_OWLExpressionSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_OWLExpression`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`owlExpression`);

USE `$DBNAME`;
-- Create Configuration Settings
DELIMITER ;
SELECT Now() `--`,"Create Configuration Settings" '--';
DROP TABLE IF EXISTS `config_language`;
CREATE TABLE `config_language` (
 `id` bigint,
 `prefix` varchar(5),
 `name` VARCHAR (255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  INDEX pfx (`prefix`)
) ENGINE=MyISAM CHARSET=utf8mb4;
INSERT INTO `config_language` (`prefix`,`id`,`name`)
VALUES
('en-US',900000000000509007,'US English'),
('en-GB',900000000000508004,'GB English');

DROP TABLE IF EXISTS `config_settings`;
CREATE TABLE `config_settings` (
  `id` tinyint(1) NOT NULL DEFAULT '1',
  `languageId` bigint(20) DEFAULT '900000000000509007',
  `languageName` varchar(255) NOT NULL DEFAULT 'US English',
  `snapshotTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deltaStartTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deltaEndTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- Release date is set here and end of the day of release
-- This avoids issues if effectTime contain a time element.
SET @RELDATE=TIMESTAMP(CONCAT('$RELDATE','235959'));

-- The row with id=0 is not used directly except as default values to refresh other rows
-- Row 0 set on database load: 
--			snapshotTime and deltaEndTime set to release date 
--          deltaStartTime set to 6 month earlier
-- Other values are reset by resetConfig() 6 and 12 months later than the row with id=0
-- and can be set to specific values using the setDeltaRange and setSnapshotTime procedures.

INSERT INTO `config_settings` (`id`,`languageId`,`languageName`,`snapshotTime`,`deltaStartTime`,`deltaEndTime`)
VALUES 
(0,900000000000509007,'US English', DATE_SUB(@RELDATE,INTERVAL 6 MONTH), DATE_SUB(@RELDATE,INTERVAL 6 MONTH),@RELDATE);


DROP PROCEDURE IF EXISTS `setLanguage`;
DROP PROCEDURE IF EXISTS `setSnapshotTime`;
DROP PROCEDURE IF EXISTS `setDeltaRange`;
DROP PROCEDURE IF EXISTS `showConfig`;
DROP PROCEDURE IF EXISTS `resetConfig`;

DELIMITER ;;

CREATE PROCEDURE `resetConfig` ()
BEGIN

-- This procedure reapplies the default values (from id=0 row) to the rows with id=1 and id=2
-- Row 0 set on database load: 
--			snapshotTime and deltaEndTime set to release date 
--          deltaStartTime set to 6 month earlier
-- resetConfig resets Row 1 and Row 2
-- 			Row 1 dates are set 6 is months earlier than Row 0
-- 			Row 2 dates are set 12 months earlier than Row 0.

DELETE FROM `config_settings` WHERE `id`>0;

INSERT INTO `config_settings` (`id`,`languageId`,`languageName`,`snapshotTime`,`deltaStartTime`,`deltaEndTime`)
SELECT 1,`languageId`,`languageName`,DATE_SUB(`snapshotTime`,INTERVAL 6 MONTH),DATE_SUB(`deltaStartTime`,INTERVAL 6 MONTH),DATE_SUB(`deltaEndTime`,INTERVAL 6 MONTH) FROM `config_settings` WHERE `id`=0
UNION
SELECT 2,`languageId`,`languageName`,DATE_SUB(`snapshotTime`,INTERVAL 12 MONTH),DATE_SUB(`deltaStartTime`,INTERVAL 12 MONTH),DATE_SUB(`deltaEndTime`,INTERVAL 12 MONTH) FROM `config_settings` WHERE `id`=0;
END;;

--

CREATE PROCEDURE `setLanguage` (IN `p_id` tinyint, IN `p_lang_code` varchar(5))
BEGIN
-- This procedure sets the language using the language-dialect code (e.g. en-GB etc)
-- There are two configurable rows id=1 and id=2 which affect different views with prefixes rsnap_ (and if used rsnap2_)
IF `p_id`<2 THEN
	SET `p_id`=1;
ELSEIF `p_id`>1 THEN
	SET `p_id`=2;
END IF;
UPDATE `config_settings` `s`, `config_language` `l`
	SET `s`.`languageId`=`l`.`id`,
	`s`.`languageName`=`l`.`name`
	WHERE `l`.`prefix`=`p_lang_code`
	AND `s`.`id`=`p_id`;
END;;

--

CREATE PROCEDURE `setSnapshotTime` (IN `p_id` tinyint, IN `p_snapshotTime` DATETIME)
BEGIN
-- This procedure sets the snapshotTime. Time gets adjusted to 23:59:59 on the chosen date.
-- There are two configurable rows id=1 and id=2 which affect different views with prefixes rsnap_ (and if used rsnap2_)
IF `p_id`<1 THEN
	SET `p_id`=2;
ELSEIF `p_id`>1 THEN
	SET `p_id`=2;
END IF;

UPDATE `config_settings` `s`
-- Adjusts time to end of day to ensure it is inclusive
	SET `snapshotTime`=DATE_ADD(DATE(TIMESTAMP(`p_snapshotTime`)),INTERVAL 86399 SECOND)
	WHERE `s`.`id`=`p_id`;
END;;

--

CREATE PROCEDURE `setDeltaRange` (IN `p_id` tinyint, IN `p_deltaStartTime` DATETIME,IN `p_deltaEndTime` DATETIME)
BEGIN
-- This procedure sets the snapshotTime. Time gets adjusted to 23:59:59 on the chosen date.
-- There are two configurable rows id=1 and id=2 which affect different views with prefixes rsnap_ (and if used rsnap2_)
IF `p_id`<1 THEN
	SET `p_id`=2;
ELSEIF `p_id`>1 THEN
	SET `p_id`=2;
END IF;
UPDATE `config_settings` `s`
-- Adjusts times to end of day to ensure it is inclusive
	SET `deltaStartTime`=DATE_ADD(DATE(TIMESTAMP(`p_deltaStartTime`)),INTERVAL 86399 SECOND),
		`deltaEndTime`=DATE_ADD(DATE(TIMESTAMP(`p_deltaEndTime`)),INTERVAL 86399 SECOND)
	WHERE `s`.`id`=`p_id`;
END;;

-- 

CREATE PROCEDURE `showConfig`()
BEGIN
-- This trivial procedure just shows the config_settings table content (included for completeness)
SELECT * FROM `config_settings`;
END;;

DELIMITER ;

CALL `resetConfig`();
-- START VIEWS --

-- Create Unoptimized Views --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Unoptimized Views";
USE `$DBNAME`;
-- VIEW SNAP CURRENT --
SELECT Now() '--','VIEW SNAP CURRENT' '--';
DROP VIEW IF EXISTS `snapAsView_concept`;
CREATE VIEW `snapAsView_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snapAsView_description`;
CREATE VIEW `snapAsView_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snapAsView_relationship`;
CREATE VIEW `snapAsView_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snapAsView_statedRelationship`;
CREATE VIEW `snapAsView_statedRelationship` AS select * from `full_statedRelationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_statedRelationship` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snapAsView_textDefinition`;
CREATE VIEW `snapAsView_textDefinition` AS select * from `full_textDefinition` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_textDefinition` `sub`) where ((`sub`.`id` = `tbl`.`id`))));
USE `$DBNAME`;
-- VIEW DELTA --
SELECT Now() '--','VIEW DELTA' '--';
DROP VIEW IF EXISTS `delta_refset_Simple`;
CREATE VIEW `delta_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_Association`;
CREATE VIEW `delta_refset_Association` AS select `tbl`.* from `full_refset_Association` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_AttributeValue`;
CREATE VIEW `delta_refset_AttributeValue` AS select `tbl`.* from `full_refset_AttributeValue` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_Language`;
CREATE VIEW `delta_refset_Language` AS select `tbl`.* from `full_refset_Language` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_ExtendedMap`;
CREATE VIEW `delta_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_SimpleMap`;
CREATE VIEW `delta_refset_SimpleMap` AS select `tbl`.* from `full_refset_SimpleMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_MRCMModuleScope`;
CREATE VIEW `delta_refset_MRCMModuleScope` AS select `tbl`.* from `full_refset_MRCMModuleScope` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_RefsetDescriptor`;
CREATE VIEW `delta_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_DescriptionType`;
CREATE VIEW `delta_refset_DescriptionType` AS select `tbl`.* from `full_refset_DescriptionType` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_MRCMAttributeDomain`;
CREATE VIEW `delta_refset_MRCMAttributeDomain` AS select `tbl`.* from `full_refset_MRCMAttributeDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_ModuleDependency`;
CREATE VIEW `delta_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_MRCMAttributeRange`;
CREATE VIEW `delta_refset_MRCMAttributeRange` AS select `tbl`.* from `full_refset_MRCMAttributeRange` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_MRCMDomain`;
CREATE VIEW `delta_refset_MRCMDomain` AS select `tbl`.* from `full_refset_MRCMDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_concept`;
CREATE VIEW `delta_concept` AS select `tbl`.* from `full_concept` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_description`;
CREATE VIEW `delta_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_relationship`;
CREATE VIEW `delta_relationship` AS select `tbl`.* from `full_relationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_statedRelationship`;
CREATE VIEW `delta_statedRelationship` AS select `tbl`.* from `full_statedRelationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_textDefinition`;
CREATE VIEW `delta_textDefinition` AS select `tbl`.* from `full_textDefinition` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta_refset_OWLExpression`;
CREATE VIEW `delta_refset_OWLExpression` AS select `tbl`.* from `full_refset_OWLExpression` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;

USE `$DBNAME`;
-- VIEW SNAP ALT --
SELECT Now() '--','VIEW SNAP ALT' '--';
DROP VIEW IF EXISTS `snap1_refset_Simple`;
CREATE VIEW `snap1_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_Association`;
CREATE VIEW `snap1_refset_Association` AS select * from `full_refset_Association` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Association` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_AttributeValue`;
CREATE VIEW `snap1_refset_AttributeValue` AS select * from `full_refset_AttributeValue` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_AttributeValue` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_Language`;
CREATE VIEW `snap1_refset_Language` AS select * from `full_refset_Language` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Language` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_ExtendedMap`;
CREATE VIEW `snap1_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_SimpleMap`;
CREATE VIEW `snap1_refset_SimpleMap` AS select * from `full_refset_SimpleMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_SimpleMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_MRCMModuleScope`;
CREATE VIEW `snap1_refset_MRCMModuleScope` AS select * from `full_refset_MRCMModuleScope` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMModuleScope` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_RefsetDescriptor`;
CREATE VIEW `snap1_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_DescriptionType`;
CREATE VIEW `snap1_refset_DescriptionType` AS select * from `full_refset_DescriptionType` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_DescriptionType` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_MRCMAttributeDomain`;
CREATE VIEW `snap1_refset_MRCMAttributeDomain` AS select * from `full_refset_MRCMAttributeDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_ModuleDependency`;
CREATE VIEW `snap1_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_MRCMAttributeRange`;
CREATE VIEW `snap1_refset_MRCMAttributeRange` AS select * from `full_refset_MRCMAttributeRange` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeRange` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_MRCMDomain`;
CREATE VIEW `snap1_refset_MRCMDomain` AS select * from `full_refset_MRCMDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_concept`;
CREATE VIEW `snap1_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_description`;
CREATE VIEW `snap1_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_relationship`;
CREATE VIEW `snap1_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_statedRelationship`;
CREATE VIEW `snap1_statedRelationship` AS select * from `full_statedRelationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_statedRelationship` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_textDefinition`;
CREATE VIEW `snap1_textDefinition` AS select * from `full_textDefinition` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_textDefinition` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap1_refset_OWLExpression`;
CREATE VIEW `snap1_refset_OWLExpression` AS select * from `full_refset_OWLExpression` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_OWLExpression` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));
USE `$DBNAME`;
-- VIEW DELTA --
SELECT Now() '--','VIEW DELTA' '--';
DROP VIEW IF EXISTS `delta1_refset_Simple`;
CREATE VIEW `delta1_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_Association`;
CREATE VIEW `delta1_refset_Association` AS select `tbl`.* from `full_refset_Association` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_AttributeValue`;
CREATE VIEW `delta1_refset_AttributeValue` AS select `tbl`.* from `full_refset_AttributeValue` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_Language`;
CREATE VIEW `delta1_refset_Language` AS select `tbl`.* from `full_refset_Language` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_ExtendedMap`;
CREATE VIEW `delta1_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_SimpleMap`;
CREATE VIEW `delta1_refset_SimpleMap` AS select `tbl`.* from `full_refset_SimpleMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_MRCMModuleScope`;
CREATE VIEW `delta1_refset_MRCMModuleScope` AS select `tbl`.* from `full_refset_MRCMModuleScope` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_RefsetDescriptor`;
CREATE VIEW `delta1_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_DescriptionType`;
CREATE VIEW `delta1_refset_DescriptionType` AS select `tbl`.* from `full_refset_DescriptionType` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_MRCMAttributeDomain`;
CREATE VIEW `delta1_refset_MRCMAttributeDomain` AS select `tbl`.* from `full_refset_MRCMAttributeDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_ModuleDependency`;
CREATE VIEW `delta1_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_MRCMAttributeRange`;
CREATE VIEW `delta1_refset_MRCMAttributeRange` AS select `tbl`.* from `full_refset_MRCMAttributeRange` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_MRCMDomain`;
CREATE VIEW `delta1_refset_MRCMDomain` AS select `tbl`.* from `full_refset_MRCMDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_concept`;
CREATE VIEW `delta1_concept` AS select `tbl`.* from `full_concept` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_description`;
CREATE VIEW `delta1_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_relationship`;
CREATE VIEW `delta1_relationship` AS select `tbl`.* from `full_relationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_statedRelationship`;
CREATE VIEW `delta1_statedRelationship` AS select `tbl`.* from `full_statedRelationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_textDefinition`;
CREATE VIEW `delta1_textDefinition` AS select `tbl`.* from `full_textDefinition` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta1_refset_OWLExpression`;
CREATE VIEW `delta1_refset_OWLExpression` AS select `tbl`.* from `full_refset_OWLExpression` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;

USE `$DBNAME`;
-- VIEW SNAP ALT --
SELECT Now() '--','VIEW SNAP ALT' '--';
DROP VIEW IF EXISTS `snap2_refset_Simple`;
CREATE VIEW `snap2_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_Association`;
CREATE VIEW `snap2_refset_Association` AS select * from `full_refset_Association` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Association` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_AttributeValue`;
CREATE VIEW `snap2_refset_AttributeValue` AS select * from `full_refset_AttributeValue` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_AttributeValue` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_Language`;
CREATE VIEW `snap2_refset_Language` AS select * from `full_refset_Language` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Language` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_ExtendedMap`;
CREATE VIEW `snap2_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_SimpleMap`;
CREATE VIEW `snap2_refset_SimpleMap` AS select * from `full_refset_SimpleMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_SimpleMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_MRCMModuleScope`;
CREATE VIEW `snap2_refset_MRCMModuleScope` AS select * from `full_refset_MRCMModuleScope` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMModuleScope` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_RefsetDescriptor`;
CREATE VIEW `snap2_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_DescriptionType`;
CREATE VIEW `snap2_refset_DescriptionType` AS select * from `full_refset_DescriptionType` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_DescriptionType` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_MRCMAttributeDomain`;
CREATE VIEW `snap2_refset_MRCMAttributeDomain` AS select * from `full_refset_MRCMAttributeDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_ModuleDependency`;
CREATE VIEW `snap2_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_MRCMAttributeRange`;
CREATE VIEW `snap2_refset_MRCMAttributeRange` AS select * from `full_refset_MRCMAttributeRange` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeRange` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_MRCMDomain`;
CREATE VIEW `snap2_refset_MRCMDomain` AS select * from `full_refset_MRCMDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_concept`;
CREATE VIEW `snap2_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_description`;
CREATE VIEW `snap2_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_relationship`;
CREATE VIEW `snap2_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_statedRelationship`;
CREATE VIEW `snap2_statedRelationship` AS select * from `full_statedRelationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_statedRelationship` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_textDefinition`;
CREATE VIEW `snap2_textDefinition` AS select * from `full_textDefinition` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_textDefinition` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));

DROP VIEW IF EXISTS `snap2_refset_OWLExpression`;
CREATE VIEW `snap2_refset_OWLExpression` AS select * from `full_refset_OWLExpression` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_OWLExpression` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));
USE `$DBNAME`;
-- VIEW DELTA --
SELECT Now() '--','VIEW DELTA' '--';
DROP VIEW IF EXISTS `delta2_refset_Simple`;
CREATE VIEW `delta2_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_Association`;
CREATE VIEW `delta2_refset_Association` AS select `tbl`.* from `full_refset_Association` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_AttributeValue`;
CREATE VIEW `delta2_refset_AttributeValue` AS select `tbl`.* from `full_refset_AttributeValue` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_Language`;
CREATE VIEW `delta2_refset_Language` AS select `tbl`.* from `full_refset_Language` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_ExtendedMap`;
CREATE VIEW `delta2_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_SimpleMap`;
CREATE VIEW `delta2_refset_SimpleMap` AS select `tbl`.* from `full_refset_SimpleMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_MRCMModuleScope`;
CREATE VIEW `delta2_refset_MRCMModuleScope` AS select `tbl`.* from `full_refset_MRCMModuleScope` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_RefsetDescriptor`;
CREATE VIEW `delta2_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_DescriptionType`;
CREATE VIEW `delta2_refset_DescriptionType` AS select `tbl`.* from `full_refset_DescriptionType` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_MRCMAttributeDomain`;
CREATE VIEW `delta2_refset_MRCMAttributeDomain` AS select `tbl`.* from `full_refset_MRCMAttributeDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_ModuleDependency`;
CREATE VIEW `delta2_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_MRCMAttributeRange`;
CREATE VIEW `delta2_refset_MRCMAttributeRange` AS select `tbl`.* from `full_refset_MRCMAttributeRange` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_MRCMDomain`;
CREATE VIEW `delta2_refset_MRCMDomain` AS select `tbl`.* from `full_refset_MRCMDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_concept`;
CREATE VIEW `delta2_concept` AS select `tbl`.* from `full_concept` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_description`;
CREATE VIEW `delta2_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_relationship`;
CREATE VIEW `delta2_relationship` AS select `tbl`.* from `full_relationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_statedRelationship`;
CREATE VIEW `delta2_statedRelationship` AS select `tbl`.* from `full_statedRelationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_textDefinition`;
CREATE VIEW `delta2_textDefinition` AS select `tbl`.* from `full_textDefinition` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DROP VIEW IF EXISTS `delta2_refset_OWLExpression`;
CREATE VIEW `delta2_refset_OWLExpression` AS select `tbl`.* from `full_refset_OWLExpression` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


-- END VIEWS --

-- START VIEWS --

-- Create Special Views --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Views";
-- Create View Special Snap views for 'snap'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Snap Views for 'snap'" '--';

DROP VIEW IF EXISTS `snap_fsn`;

CREATE VIEW `snap_fsn` AS
(SELECT `d`.* FROM `snap_description` `d`
	JOIN `snap_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000003001
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000548007
	AND `cfg`.`id`=0);

DROP VIEW IF EXISTS `snap_pref`;

CREATE VIEW `snap_pref` AS
(SELECT `d`.* FROM `snap_description` `d`
	JOIN `snap_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000548007
	AND `cfg`.`id`=0);

DROP VIEW IF EXISTS `snap_syn`;

CREATE VIEW `snap_syn` AS
(SELECT `d`.* FROM `snap_description` `d`
	JOIN `snap_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId` 
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000549004
	AND `cfg`.`id`=0);

DROP VIEW IF EXISTS `snap_synall`;

CREATE VIEW `snap_synall` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap_description` `d`
	JOIN `snap_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 
	AND `cfg`.`id`=0);

DROP VIEW IF EXISTS `snap_term_search_active`;

CREATE VIEW `snap_term_search_active` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap_description` `d`
	JOIN `snap_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `snap_concept` `c` ON `c`.`id` = `d`.`conceptId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 
	AND `rs`.`active` = 1
	AND `c`.`active` = 1
	AND `cfg`.`id`=0);

DROP VIEW IF EXISTS `snap_syn_search_active`;

CREATE VIEW `snap_syn_search_active` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap_description` `d`
	JOIN `snap_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `snap_concept` `c` ON `c`.`id` = `d`.`conceptId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009
	AND `rs`.`active` = 1
	AND `c`.`active` = 1
	AND `cfg`.`id`=0);

DROP VIEW IF EXISTS `snap_rel_pref`;

CREATE VIEW `snap_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap_relationship` `r`
	JOIN `snap_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `snap_rel_fsn`;

CREATE VIEW `snap_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap_relationship` `r`
	JOIN `snap_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `snap_rel_def_pref`;

CREATE VIEW `snap_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap_relationship` `r`
	JOIN `snap_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap_rel_def_fsn`;

CREATE VIEW `snap_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap_relationship` `r`
	JOIN `snap_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap_rel_child_fsn`;

CREATE VIEW `snap_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `snap_relationship` `r`
	JOIN `snap_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap_rel_parent_fsn`;

CREATE VIEW `snap_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `snap_relationship` `r`
	JOIN `snap_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap_rel_child_pref`;

CREATE VIEW `snap_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `snap_relationship` `r`
	JOIN `snap_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap_rel_parent_pref`;

CREATE VIEW `snap_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `snap_relationship` `r`
JOIN `snap_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DELIMITER ;
-- Create View Special All views for 'snap'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special All Views for 'snap'" '--';
DROP VIEW IF EXISTS snap_inactive_concepts;

CREATE VIEW snap_inactive_concepts AS 
select `c`.`id`,`c`.`effectiveTime`,`c`.`active`,`c`.`definitionStatusId`,`cf`.`term` 'FSN',`vp`.`term` 'reason',`arp`.`term` 'assoc_type',`atf`.`id` 'ref_conceptId',`atf`.`term` 'ref_concept_FSN' 
from `snap_concept` `c`
left join `snap_fsn` `cf` ON `cf`.`conceptid`=`c`.`id`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`c`.`id` and `v`.`refsetId`=900000000000489007 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
left outer join `snap_refset_association` `a` on `a`.`referencedComponentId`=`c`.`id` 
and `a`.`refsetId` IN (900000000000528000,900000000000523009,900000000000527005,900000000000526001,900000000000525002,900000000000531004,900000000000524003,900000000000530003) and `a`.`active`=1
left outer join `snap_pref` `arp` on `arp`.`conceptid`=`a`.`refsetId`
left outer join `snap_fsn` `atf` on `atf`.`conceptid`=`a`.`targetComponentId`
where `c`.`active`=0
order by `c`.`id`;

DROP VIEW IF EXISTS snap_inactive_descriptions;

CREATE VIEW snap_inactive_descriptions AS 
select `d`.`id`,`d`.`effectiveTime`,`d`.`active`,`d`.`conceptid`,`d`.`term` 'term',`df`.`term` 'concept_fsn',`c`.`active` 'concept_active',`vp`.`term` 'reason' 
from `snap_description` `d`
left outer join `snap_fsn` `df` ON `df`.`conceptid`=`d`.`conceptid`
join `snap_concept` `c` ON `c`.`id`=`d`.`conceptid`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`d`.`id` and `v`.`refsetId`=900000000000490003 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
where `d`.`active`=0
order by `d`.`id`;
-- Create View Special Delta views for 'delta'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Delta Views for 'delta'" '--';

-- No views specified at present

-- Create View Special All views for 'delta'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special All Views for 'delta'" '--';
DROP VIEW IF EXISTS delta_inactive_concepts;

CREATE VIEW delta_inactive_concepts AS 
select `c`.`id`,`c`.`effectiveTime`,`c`.`active`,`c`.`definitionStatusId`,`cf`.`term` 'FSN',`vp`.`term` 'reason',`arp`.`term` 'assoc_type',`atf`.`id` 'ref_conceptId',`atf`.`term` 'ref_concept_FSN' 
from `delta_concept` `c`
left join `snap_fsn` `cf` ON `cf`.`conceptid`=`c`.`id`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`c`.`id` and `v`.`refsetId`=900000000000489007 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
left outer join `snap_refset_association` `a` on `a`.`referencedComponentId`=`c`.`id` 
and `a`.`refsetId` IN (900000000000528000,900000000000523009,900000000000527005,900000000000526001,900000000000525002,900000000000531004,900000000000524003,900000000000530003) and `a`.`active`=1
left outer join `snap_pref` `arp` on `arp`.`conceptid`=`a`.`refsetId`
left outer join `snap_fsn` `atf` on `atf`.`conceptid`=`a`.`targetComponentId`
where `c`.`active`=0
order by `c`.`id`;

DROP VIEW IF EXISTS delta_inactive_descriptions;

CREATE VIEW delta_inactive_descriptions AS 
select `d`.`id`,`d`.`effectiveTime`,`d`.`active`,`d`.`conceptid`,`d`.`term` 'term',`df`.`term` 'concept_fsn',`c`.`active` 'concept_active',`vp`.`term` 'reason' 
from `delta_description` `d`
left outer join `snap_fsn` `df` ON `df`.`conceptid`=`d`.`conceptid`
join `snap_concept` `c` ON `c`.`id`=`d`.`conceptid`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`d`.`id` and `v`.`refsetId`=900000000000490003 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
where `d`.`active`=0
order by `d`.`id`;
-- Create View Special Snap views for 'snap1'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Snap Views for 'snap1'" '--';

DROP VIEW IF EXISTS `snap1_fsn`;

CREATE VIEW `snap1_fsn` AS
(SELECT `d`.* FROM `snap1_description` `d`
	JOIN `snap1_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000003001
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000548007
	AND `cfg`.`id`=1);

DROP VIEW IF EXISTS `snap1_pref`;

CREATE VIEW `snap1_pref` AS
(SELECT `d`.* FROM `snap1_description` `d`
	JOIN `snap1_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000548007
	AND `cfg`.`id`=1);

DROP VIEW IF EXISTS `snap1_syn`;

CREATE VIEW `snap1_syn` AS
(SELECT `d`.* FROM `snap1_description` `d`
	JOIN `snap1_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId` 
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000549004
	AND `cfg`.`id`=1);

DROP VIEW IF EXISTS `snap1_synall`;

CREATE VIEW `snap1_synall` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap1_description` `d`
	JOIN `snap1_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 
	AND `cfg`.`id`=1);

DROP VIEW IF EXISTS `snap1_term_search_active`;

CREATE VIEW `snap1_term_search_active` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap1_description` `d`
	JOIN `snap1_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `snap1_concept` `c` ON `c`.`id` = `d`.`conceptId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 
	AND `rs`.`active` = 1
	AND `c`.`active` = 1
	AND `cfg`.`id`=1);

DROP VIEW IF EXISTS `snap1_syn_search_active`;

CREATE VIEW `snap1_syn_search_active` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap1_description` `d`
	JOIN `snap1_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `snap1_concept` `c` ON `c`.`id` = `d`.`conceptId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009
	AND `rs`.`active` = 1
	AND `c`.`active` = 1
	AND `cfg`.`id`=1);

DROP VIEW IF EXISTS `snap1_rel_pref`;

CREATE VIEW `snap1_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap1_relationship` `r`
	JOIN `snap1_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap1_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap1_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `snap1_rel_fsn`;

CREATE VIEW `snap1_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap1_relationship` `r`
	JOIN `snap1_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap1_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap1_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `snap1_rel_def_pref`;

CREATE VIEW `snap1_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap1_relationship` `r`
	JOIN `snap1_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap1_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap1_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap1_rel_def_fsn`;

CREATE VIEW `snap1_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap1_relationship` `r`
	JOIN `snap1_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap1_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap1_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap1_rel_child_fsn`;

CREATE VIEW `snap1_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `snap1_relationship` `r`
	JOIN `snap1_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap1_rel_parent_fsn`;

CREATE VIEW `snap1_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `snap1_relationship` `r`
	JOIN `snap1_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap1_rel_child_pref`;

CREATE VIEW `snap1_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `snap1_relationship` `r`
	JOIN `snap1_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap1_rel_parent_pref`;

CREATE VIEW `snap1_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `snap1_relationship` `r`
JOIN `snap1_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DELIMITER ;
-- Create View Special All views for 'snap1'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special All Views for 'snap1'" '--';
DROP VIEW IF EXISTS snap1_inactive_concepts;

CREATE VIEW snap1_inactive_concepts AS 
select `c`.`id`,`c`.`effectiveTime`,`c`.`active`,`c`.`definitionStatusId`,`cf`.`term` 'FSN',`vp`.`term` 'reason',`arp`.`term` 'assoc_type',`atf`.`id` 'ref_conceptId',`atf`.`term` 'ref_concept_FSN' 
from `snap1_concept` `c`
left join `snap_fsn` `cf` ON `cf`.`conceptid`=`c`.`id`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`c`.`id` and `v`.`refsetId`=900000000000489007 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
left outer join `snap_refset_association` `a` on `a`.`referencedComponentId`=`c`.`id` 
and `a`.`refsetId` IN (900000000000528000,900000000000523009,900000000000527005,900000000000526001,900000000000525002,900000000000531004,900000000000524003,900000000000530003) and `a`.`active`=1
left outer join `snap_pref` `arp` on `arp`.`conceptid`=`a`.`refsetId`
left outer join `snap_fsn` `atf` on `atf`.`conceptid`=`a`.`targetComponentId`
where `c`.`active`=0
order by `c`.`id`;

DROP VIEW IF EXISTS snap1_inactive_descriptions;

CREATE VIEW snap1_inactive_descriptions AS 
select `d`.`id`,`d`.`effectiveTime`,`d`.`active`,`d`.`conceptid`,`d`.`term` 'term',`df`.`term` 'concept_fsn',`c`.`active` 'concept_active',`vp`.`term` 'reason' 
from `snap1_description` `d`
left outer join `snap_fsn` `df` ON `df`.`conceptid`=`d`.`conceptid`
join `snap_concept` `c` ON `c`.`id`=`d`.`conceptid`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`d`.`id` and `v`.`refsetId`=900000000000490003 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
where `d`.`active`=0
order by `d`.`id`;
-- Create View Special Delta views for 'delta1'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Delta Views for 'delta1'" '--';

-- No views specified at present

-- Create View Special All views for 'delta1'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special All Views for 'delta1'" '--';
DROP VIEW IF EXISTS delta1_inactive_concepts;

CREATE VIEW delta1_inactive_concepts AS 
select `c`.`id`,`c`.`effectiveTime`,`c`.`active`,`c`.`definitionStatusId`,`cf`.`term` 'FSN',`vp`.`term` 'reason',`arp`.`term` 'assoc_type',`atf`.`id` 'ref_conceptId',`atf`.`term` 'ref_concept_FSN' 
from `delta1_concept` `c`
left join `snap_fsn` `cf` ON `cf`.`conceptid`=`c`.`id`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`c`.`id` and `v`.`refsetId`=900000000000489007 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
left outer join `snap_refset_association` `a` on `a`.`referencedComponentId`=`c`.`id` 
and `a`.`refsetId` IN (900000000000528000,900000000000523009,900000000000527005,900000000000526001,900000000000525002,900000000000531004,900000000000524003,900000000000530003) and `a`.`active`=1
left outer join `snap_pref` `arp` on `arp`.`conceptid`=`a`.`refsetId`
left outer join `snap_fsn` `atf` on `atf`.`conceptid`=`a`.`targetComponentId`
where `c`.`active`=0
order by `c`.`id`;

DROP VIEW IF EXISTS delta1_inactive_descriptions;

CREATE VIEW delta1_inactive_descriptions AS 
select `d`.`id`,`d`.`effectiveTime`,`d`.`active`,`d`.`conceptid`,`d`.`term` 'term',`df`.`term` 'concept_fsn',`c`.`active` 'concept_active',`vp`.`term` 'reason' 
from `delta1_description` `d`
left outer join `snap_fsn` `df` ON `df`.`conceptid`=`d`.`conceptid`
join `snap_concept` `c` ON `c`.`id`=`d`.`conceptid`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`d`.`id` and `v`.`refsetId`=900000000000490003 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
where `d`.`active`=0
order by `d`.`id`;
-- Create View Special Snap views for 'snap2'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Snap Views for 'snap2'" '--';

DROP VIEW IF EXISTS `snap2_fsn`;

CREATE VIEW `snap2_fsn` AS
(SELECT `d`.* FROM `snap2_description` `d`
	JOIN `snap2_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000003001
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000548007
	AND `cfg`.`id`=2);

DROP VIEW IF EXISTS `snap2_pref`;

CREATE VIEW `snap2_pref` AS
(SELECT `d`.* FROM `snap2_description` `d`
	JOIN `snap2_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000548007
	AND `cfg`.`id`=2);

DROP VIEW IF EXISTS `snap2_syn`;

CREATE VIEW `snap2_syn` AS
(SELECT `d`.* FROM `snap2_description` `d`
	JOIN `snap2_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId` 
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 AND `rs`.`acceptabilityId` = 900000000000549004
	AND `cfg`.`id`=2);

DROP VIEW IF EXISTS `snap2_synall`;

CREATE VIEW `snap2_synall` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap2_description` `d`
	JOIN `snap2_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009 
	AND `rs`.`active` = 1 
	AND `cfg`.`id`=2);

DROP VIEW IF EXISTS `snap2_term_search_active`;

CREATE VIEW `snap2_term_search_active` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap2_description` `d`
	JOIN `snap2_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `snap2_concept` `c` ON `c`.`id` = `d`.`conceptId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 
	AND `rs`.`active` = 1
	AND `c`.`active` = 1
	AND `cfg`.`id`=2);

DROP VIEW IF EXISTS `snap2_syn_search_active`;

CREATE VIEW `snap2_syn_search_active` AS
(SELECT `d`.*,`rs`.`acceptabilityId` FROM `snap2_description` `d`
	JOIN `snap2_refset_Language` `rs` ON `d`.`id` = `rs`.`referencedComponentId`
	JOIN `snap2_concept` `c` ON `c`.`id` = `d`.`conceptId`
	JOIN `config_settings` `cfg` ON `rs`.`refSetId` = `cfg`.`languageId`
	WHERE `d`.`active` = 1 AND `d`.`typeId` = 900000000000013009
	AND `rs`.`active` = 1
	AND `c`.`active` = 1
	AND `cfg`.`id`=2);

DROP VIEW IF EXISTS `snap2_rel_pref`;

CREATE VIEW `snap2_rel_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap2_relationship` `r`
	JOIN `snap2_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap2_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap2_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `snap2_rel_fsn`;

CREATE VIEW `snap2_rel_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap2_relationship` `r`
	JOIN `snap2_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap2_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap2_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1)));

DROP VIEW IF EXISTS `snap2_rel_def_pref`;

CREATE VIEW `snap2_rel_def_pref` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap2_relationship` `r`
	JOIN `snap2_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap2_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap2_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap2_rel_def_fsn`;

CREATE VIEW `snap2_rel_def_fsn` AS
(SELECT `r`.`sourceId` `src_id`,`src`.`Term` `src_term`,`r`.`typeId` `type_id`,`typ`.`Term` `type_term`,`r`.`destinationId` `dest_id`,`dest`.`Term` `dest_term`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap2_relationship` `r`
	JOIN `snap2_fsn` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap2_fsn` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap2_fsn` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap2_rel_child_fsn`;

CREATE VIEW `snap2_rel_child_fsn` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `snap2_relationship` `r`
	JOIN `snap2_fsn` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap2_rel_parent_fsn`;

CREATE VIEW `snap2_rel_parent_fsn` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `snap2_relationship` `r`
	JOIN `snap2_fsn` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap2_rel_child_pref`;

CREATE VIEW `snap2_rel_child_pref` AS
(SELECT `r`.`sourceId` `id`,`d`.`term` `term`,`r`.`destinationId` `conceptId`
	FROM  `snap2_relationship` `r`
	JOIN `snap2_pref` `d` ON (`r`.`sourceId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DROP VIEW IF EXISTS `snap2_rel_parent_pref`;

CREATE VIEW `snap2_rel_parent_pref` AS
(SELECT `r`.`destinationId` `id`,`d`.`term` `term`,`r`.`sourceId` `conceptId`
	FROM  `snap2_relationship` `r`
JOIN `snap2_pref` `d` ON (`r`.`destinationId` = `d`.`conceptId`) WHERE (`r`.`active` = 1) AND (`r`.`typeId` = 116680003));

DELIMITER ;
-- Create View Special All views for 'snap2'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special All Views for 'snap2'" '--';
DROP VIEW IF EXISTS snap2_inactive_concepts;

CREATE VIEW snap2_inactive_concepts AS 
select `c`.`id`,`c`.`effectiveTime`,`c`.`active`,`c`.`definitionStatusId`,`cf`.`term` 'FSN',`vp`.`term` 'reason',`arp`.`term` 'assoc_type',`atf`.`id` 'ref_conceptId',`atf`.`term` 'ref_concept_FSN' 
from `snap2_concept` `c`
left join `snap_fsn` `cf` ON `cf`.`conceptid`=`c`.`id`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`c`.`id` and `v`.`refsetId`=900000000000489007 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
left outer join `snap_refset_association` `a` on `a`.`referencedComponentId`=`c`.`id` 
and `a`.`refsetId` IN (900000000000528000,900000000000523009,900000000000527005,900000000000526001,900000000000525002,900000000000531004,900000000000524003,900000000000530003) and `a`.`active`=1
left outer join `snap_pref` `arp` on `arp`.`conceptid`=`a`.`refsetId`
left outer join `snap_fsn` `atf` on `atf`.`conceptid`=`a`.`targetComponentId`
where `c`.`active`=0
order by `c`.`id`;

DROP VIEW IF EXISTS snap2_inactive_descriptions;

CREATE VIEW snap2_inactive_descriptions AS 
select `d`.`id`,`d`.`effectiveTime`,`d`.`active`,`d`.`conceptid`,`d`.`term` 'term',`df`.`term` 'concept_fsn',`c`.`active` 'concept_active',`vp`.`term` 'reason' 
from `snap2_description` `d`
left outer join `snap_fsn` `df` ON `df`.`conceptid`=`d`.`conceptid`
join `snap_concept` `c` ON `c`.`id`=`d`.`conceptid`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`d`.`id` and `v`.`refsetId`=900000000000490003 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
where `d`.`active`=0
order by `d`.`id`;
-- Create View Special Delta views for 'delta2'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special Delta Views for 'delta2'" '--';

-- No views specified at present

-- Create View Special All views for 'delta2'
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Special All Views for 'delta2'" '--';
DROP VIEW IF EXISTS delta2_inactive_concepts;

CREATE VIEW delta2_inactive_concepts AS 
select `c`.`id`,`c`.`effectiveTime`,`c`.`active`,`c`.`definitionStatusId`,`cf`.`term` 'FSN',`vp`.`term` 'reason',`arp`.`term` 'assoc_type',`atf`.`id` 'ref_conceptId',`atf`.`term` 'ref_concept_FSN' 
from `delta2_concept` `c`
left join `snap_fsn` `cf` ON `cf`.`conceptid`=`c`.`id`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`c`.`id` and `v`.`refsetId`=900000000000489007 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
left outer join `snap_refset_association` `a` on `a`.`referencedComponentId`=`c`.`id` 
and `a`.`refsetId` IN (900000000000528000,900000000000523009,900000000000527005,900000000000526001,900000000000525002,900000000000531004,900000000000524003,900000000000530003) and `a`.`active`=1
left outer join `snap_pref` `arp` on `arp`.`conceptid`=`a`.`refsetId`
left outer join `snap_fsn` `atf` on `atf`.`conceptid`=`a`.`targetComponentId`
where `c`.`active`=0
order by `c`.`id`;

DROP VIEW IF EXISTS delta2_inactive_descriptions;

CREATE VIEW delta2_inactive_descriptions AS 
select `d`.`id`,`d`.`effectiveTime`,`d`.`active`,`d`.`conceptid`,`d`.`term` 'term',`df`.`term` 'concept_fsn',`c`.`active` 'concept_active',`vp`.`term` 'reason' 
from `delta2_description` `d`
left outer join `snap_fsn` `df` ON `df`.`conceptid`=`d`.`conceptid`
join `snap_concept` `c` ON `c`.`id`=`d`.`conceptid`
left outer join `snap_refset_attributevalue` `v` on `v`.`referencedComponentId`=`d`.`id` and `v`.`refsetId`=900000000000490003 and `v`.`active`=1
left outer join `snap_pref` `vp` on `vp`.`conceptid`=`v`.`valueid` 
where `d`.`active`=0
order by `d`.`id`;

-- Create Transitive Closure Views --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Transitive Closure Views";

-- The SQL Script Generate a Snapshot View Table 
-- that links all concepts to all their Supertype Ancestors

-- STAGE: Create Transitive Closure and Proximal Primitive Views
DELIMITER ;

-- ================================
-- REQUIRES TRANSITIVE CLOSURE FILE
-- ================================
-- Next line replace by start block comment if no Transitive Closure
-- ifTC

USE `$DBNAME`;
SELECT Now() `--`,"Create Transitive Closure and Proximal Primitive Views" '--';

-- CREATE VIEWS

-- Create view of transclosure with preferred terms
CREATE  OR REPLACE VIEW `snap_transclose_pref` AS
SELECT `t`.`supertypeId`,`p2`.`term` `supertypeTerm`, `t`.`subtypeId`, `p`.`term` `subtypeTerm`
	FROM `snap_transclose` `t`
	JOIN `snap_pref` `p` ON `t`.`subtypeId`=`p`.`conceptId`
	JOIN `snap_pref` `p2` ON `t`.`supertypeId`=`p2`.`conceptId`;

-- Create view of proximal primitives with preferred terms	
CREATE  OR REPLACE VIEW `snap_proxprim_pref` AS
SELECT `t`.`supertypeId`,`p2`.`term` `supertypeTerm`, `t`.`subtypeId`, `p`.`term` `subtypeTerm`
	FROM `snap_proximal_primitives` `t`
	JOIN `snap_pref` `p` ON `t`.`subtypeId`=`p`.`conceptId`
	JOIN `snap_pref` `p2` ON `t`.`supertypeId`=`p2`.`conceptId`;

-- fiTC
-- Previous line replace by end block comment if no Transitive Closure

DELIMITER ;

-- END VIEWS --

-- START INDEX --

-- Add Additional Indexes --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add Additional Indexes";


-- addIndexes(full);

-- Index `full_refset_Simple` 

ALTER TABLE `full_refset_Simple`
ADD INDEX `Simple_c` (`referencedComponentId`),
ADD INDEX `Simple_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_Association` 

ALTER TABLE `full_refset_Association`
ADD INDEX `Association_c` (`referencedComponentId`),
ADD INDEX `Association_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_AttributeValue` 

ALTER TABLE `full_refset_AttributeValue`
ADD INDEX `AttributeValue_c` (`referencedComponentId`),
ADD INDEX `AttributeValue_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_Language` 

ALTER TABLE `full_refset_Language`
ADD INDEX `Language_c` (`referencedComponentId`),
ADD INDEX `Language_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_ExtendedMap` 

ALTER TABLE `full_refset_ExtendedMap`
ADD INDEX `ExtendedMap_c` (`referencedComponentId`),
ADD INDEX `ExtendedMap_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `ExtendedMap_map` (`mapTarget`);

-- Index `full_refset_SimpleMap` 

ALTER TABLE `full_refset_SimpleMap`
ADD INDEX `SimpleMap_c` (`referencedComponentId`),
ADD INDEX `SimpleMap_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `SimpleMap_map` (`mapTarget`);

-- Index `full_refset_MRCMModuleScope` 

ALTER TABLE `full_refset_MRCMModuleScope`
ADD INDEX `MRCMModuleScope_c` (`referencedComponentId`),
ADD INDEX `MRCMModuleScope_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_RefsetDescriptor` 

ALTER TABLE `full_refset_RefsetDescriptor`
ADD INDEX `RefsetDescriptor_c` (`referencedComponentId`),
ADD INDEX `RefsetDescriptor_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_DescriptionType` 

ALTER TABLE `full_refset_DescriptionType`;

-- Index `full_refset_MRCMAttributeDomain` 

ALTER TABLE `full_refset_MRCMAttributeDomain`
ADD INDEX `MRCMAttributeDomain_c` (`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_dom` (`domainId`);

-- Index `full_refset_ModuleDependency` 

ALTER TABLE `full_refset_ModuleDependency`
ADD INDEX `ModuleDependency_c` (`referencedComponentId`),
ADD INDEX `ModuleDependency_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_MRCMAttributeRange` 

ALTER TABLE `full_refset_MRCMAttributeRange`
ADD INDEX `MRCMAttributeRange_c` (`referencedComponentId`),
ADD INDEX `MRCMAttributeRange_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_refset_MRCMDomain` 

ALTER TABLE `full_refset_MRCMDomain`
ADD INDEX `MRCMDomain_c` (`referencedComponentId`),
ADD INDEX `MRCMDomain_rc` (`refsetId`,`referencedComponentId`);

-- Index `full_concept` 

ALTER TABLE `full_concept`;

-- Index `full_description` 

ALTER TABLE `full_description`
ADD INDEX `description_concept` (`conceptId`),
ADD INDEX `description_lang` (`conceptId`,`languageCode`);


ALTER TABLE `full_description`ADD FULLTEXT INDEX `description_term` (`term`);

-- Index `full_relationship` 

ALTER TABLE `full_relationship`
ADD INDEX `relationship_source` (`sourceId`,`typeId`,`destinationId`),
ADD INDEX `relationship_dest` (`destinationId`,`typeId`,`sourceId`);

-- Index `full_statedRelationship` 

ALTER TABLE `full_statedRelationship`
ADD INDEX `statedRelationship_source` (`sourceId`,`typeId`,`destinationId`),
ADD INDEX `statedRelationship_dest` (`destinationId`,`typeId`,`sourceId`);

-- Index `full_textDefinition` 

ALTER TABLE `full_textDefinition`
ADD INDEX `textDefinition_concept` (`conceptId`),
ADD INDEX `textDefinition_lang` (`conceptId`,`languageCode`);


ALTER TABLE `full_textDefinition`ADD FULLTEXT INDEX `textDefinition_term` (`term`);

-- Index `full_refset_OWLExpression` 

ALTER TABLE `full_refset_OWLExpression`
ADD INDEX `OWLExpression_c` (`referencedComponentId`),
ADD INDEX `OWLExpression_rc` (`refsetId`,`referencedComponentId`);



-- addIndexes(snap);

-- Index `snap_refset_Simple` 

ALTER TABLE `snap_refset_Simple`
ADD INDEX `Simple_c` (`referencedComponentId`),
ADD INDEX `Simple_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_Association` 

ALTER TABLE `snap_refset_Association`
ADD INDEX `Association_c` (`referencedComponentId`),
ADD INDEX `Association_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_AttributeValue` 

ALTER TABLE `snap_refset_AttributeValue`
ADD INDEX `AttributeValue_c` (`referencedComponentId`),
ADD INDEX `AttributeValue_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_Language` 

ALTER TABLE `snap_refset_Language`
ADD INDEX `Language_c` (`referencedComponentId`),
ADD INDEX `Language_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_ExtendedMap` 

ALTER TABLE `snap_refset_ExtendedMap`
ADD INDEX `ExtendedMap_c` (`referencedComponentId`),
ADD INDEX `ExtendedMap_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `ExtendedMap_map` (`mapTarget`);

-- Index `snap_refset_SimpleMap` 

ALTER TABLE `snap_refset_SimpleMap`
ADD INDEX `SimpleMap_c` (`referencedComponentId`),
ADD INDEX `SimpleMap_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `SimpleMap_map` (`mapTarget`);

-- Index `snap_refset_MRCMModuleScope` 

ALTER TABLE `snap_refset_MRCMModuleScope`
ADD INDEX `MRCMModuleScope_c` (`referencedComponentId`),
ADD INDEX `MRCMModuleScope_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_RefsetDescriptor` 

ALTER TABLE `snap_refset_RefsetDescriptor`
ADD INDEX `RefsetDescriptor_c` (`referencedComponentId`),
ADD INDEX `RefsetDescriptor_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_DescriptionType` 

ALTER TABLE `snap_refset_DescriptionType`;

-- Index `snap_refset_MRCMAttributeDomain` 

ALTER TABLE `snap_refset_MRCMAttributeDomain`
ADD INDEX `MRCMAttributeDomain_c` (`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_rc` (`refsetId`,`referencedComponentId`),
ADD INDEX `MRCMAttributeDomain_dom` (`domainId`);

-- Index `snap_refset_ModuleDependency` 

ALTER TABLE `snap_refset_ModuleDependency`
ADD INDEX `ModuleDependency_c` (`referencedComponentId`),
ADD INDEX `ModuleDependency_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_MRCMAttributeRange` 

ALTER TABLE `snap_refset_MRCMAttributeRange`
ADD INDEX `MRCMAttributeRange_c` (`referencedComponentId`),
ADD INDEX `MRCMAttributeRange_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_refset_MRCMDomain` 

ALTER TABLE `snap_refset_MRCMDomain`
ADD INDEX `MRCMDomain_c` (`referencedComponentId`),
ADD INDEX `MRCMDomain_rc` (`refsetId`,`referencedComponentId`);

-- Index `snap_concept` 

ALTER TABLE `snap_concept`;

-- Index `snap_description` 

ALTER TABLE `snap_description`
ADD INDEX `description_concept` (`conceptId`),
ADD INDEX `description_lang` (`conceptId`,`languageCode`);


ALTER TABLE `snap_description`ADD FULLTEXT INDEX `description_term` (`term`);

-- Index `snap_relationship` 

ALTER TABLE `snap_relationship`
ADD INDEX `relationship_source` (`sourceId`,`typeId`,`destinationId`),
ADD INDEX `relationship_dest` (`destinationId`,`typeId`,`sourceId`);

-- Index `snap_statedRelationship` 

ALTER TABLE `snap_statedRelationship`
ADD INDEX `statedRelationship_source` (`sourceId`,`typeId`,`destinationId`),
ADD INDEX `statedRelationship_dest` (`destinationId`,`typeId`,`sourceId`);

-- Index `snap_textDefinition` 

ALTER TABLE `snap_textDefinition`
ADD INDEX `textDefinition_concept` (`conceptId`),
ADD INDEX `textDefinition_lang` (`conceptId`,`languageCode`);


ALTER TABLE `snap_textDefinition`ADD FULLTEXT INDEX `textDefinition_term` (`term`);

-- Index `snap_refset_OWLExpression` 

ALTER TABLE `snap_refset_OWLExpression`
ADD INDEX `OWLExpression_c` (`referencedComponentId`),
ADD INDEX `OWLExpression_rc` (`refsetId`,`referencedComponentId`);


-- END INDEX --

-- START TC --

-- This SQL Script Generates a Snapshot View Table 
-- that links all concepts to all their Supertype Ancestors

-- STAGE: Load Transitive Closure Data and Generate Proximal Primitives
DELIMITER ;

-- ================================
-- REQUIRES TRANSITIVE CLOSURE FILE
-- ================================
-- Next line replace by start block comment if no Transitive Closure
-- ifTC

USE `$DBNAME`;
SELECT Now() `--`,"Load Transitive Closure Data and Create Proximal Primitives" '--';

LOAD DATA LOCAL INFILE '$RELPATH/xder_TransitiveClosure_Snapshot_INT_$RELDATE.txt'
	INTO TABLE `snap_transclose`
	LINES TERMINATED BY '\n'
	(`subtypeId`,`supertypeId`);

-- Create proximal primitive supertypes table
	
DROP TABLE IF EXISTS `snap_supertypes_defprim`;
DROP TABLE IF EXISTS `snap_supertypes_primprim`;
DROP TABLE IF EXISTS `snap_supertypes_prim_nonprox`;

CREATE TEMPORARY TABLE `snap_supertypes_defprim` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `p_rev` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE `snap_supertypes_primprim` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `pp_rev` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE `snap_supertypes_prim_nonprox` (
  `subtypeId` bigint(20) NOT NULL DEFAULT '0',
  `supertypeId` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`subtypeId`,`supertypeId`),
  KEY `p_rev` (`supertypeId`,`subtypeId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- Create table with Primitive Supertypes only and ignore rows where subtypes is primitive
INSERT INTO `snap_supertypes_defprim`
SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
	FROM snap_transclose `tc`
	JOIN `snap_concept` `c` on `c`.`id`=`tc`.`supertypeId` 
		AND `c`.`definitionStatusId`=900000000000074008
    JOIN `snap_concept` `c2` on `c2`.`id`=`tc`.`subtypeId`
		AND `c2`.`definitionStatusId`<>900000000000074008
WHERE `tc`.`supertypeId`<>138875005;

-- For all concepts that are primitive supertypes get their primitive supertypes
INSERT INTO `snap_supertypes_primprim`
SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
	FROM snap_transclose `tc`
	JOIN `snap_concept` `c` on `c`.`id`=`tc`.`supertypeId` 
		AND `c`.`definitionStatusId`=900000000000074008
    WHERE `tc`.`subtypeId` IN (SELECT `supertypeId`
			FROM `snap_supertypes_defprim`)
		AND `tc`.`supertypeId`<>138875005;

-- Identify the non-promixal relationships
INSERT INTO `snap_supertypes_prim_nonprox`
SELECT DISTINCT `tc`.`subtypeId`,`tp`.`supertypeId`
	FROM `snap_supertypes_defprim` `tc`
	JOIN `snap_supertypes_primprim` `tp` ON `tp`.`subtypeId`=`tc`.`supertypeId`;

-- Insert the proximal primitives into the table
INSERT INTO `snap_proximal_primitives` 
SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
	FROM `snap_supertypes_defprim` `tc`
	WHERE NOT EXISTS(SELECT * FROM `snap_supertypes_prim_nonprox` `tp`
	WHERE `tp`.`subtypeId`=`tc`.`subtypeId` 
		AND `tp`.`supertypeId`=`tc`.`supertypeId`);

-- fiTC
-- Previous line replace by end block comment if no Transitive Closure

DELIMITER ;

-- END TC --

-- START EXTRAS --
-- Create eclSimple() Procedure
-- This procedure only works with current snapshot
DELIMITER ;

-- Next line replace by start block comment if no Transitive Closure
-- ifTC

USE `$DBNAME`;
SELECT Now() `--`,"Create eclSimple() Procedure" '--';
DROP PROCEDURE IF EXISTS `eclSimple`;
DELIMITER ;;
CREATE PROCEDURE eclSimple(`p_ecl` text)
BEGIN
-- SNOMED SQL QUERY FOR SIMPLE EXPRESSION CONSTRAINTS
-- Lists the id and preferred terms for all matching concepts

-- Requires a SIMPLE ECL expression constraint.
-- Call this procedure as follows:
--   CALL eclSimple("ecl_expression");
-- Examples:
--   CALL eclSimple('<404684003:363698007=<<39057004,116676008=<<415582006');
-- 	 CALL eclSimple('<404684003:363698007=<39057004,116676008=<415582006');
--   CALL eclSimple('<404684003:363698007=<<39057004');
--   CALL eclSimple('< 404684003 |clinical finding|:363698007 |finding site| = << 39057004 |pulmonary `valve|,116676008 |associated morphology| = << 415582006 |stenosis|')
 
-- Currently permits:
--    1) Just a focus concept constraint,
--    2) A focus concept constraint and one attribute value constraint
--    3) A focus concept constraint and two attribute value constraint
-- General format:
--    <<focus_id[:attr1=<<attr1_value[,attr2=<<attr2_value]]
-- In all cases
--    a) The << can be replaced by < (subtypes only) or omitted (self only)
--    b) Each identifier can be followed by pipe-delimited term which is removed before computing the matching concepts
--    c) Spaces can be included in constraints and are removed before computing the matching concepts

-- NOTE: MORE COMPLEX ECL CONSTRAINTS ARE NOT CURRENTLY SUPPORTED BY THIS DEMONSTRATOR PROCEDURE

DECLARE `v_text` text;
DECLARE `v_ecl` text;
DECLARE `v_focus_id` bigint;
DECLARE `v_focus_symbol` text;
DECLARE `v_refine1` text;
DECLARE `v_refine2` text;
DECLARE `v_ref2` text;
DECLARE `v_value1_id` bigint(18);
DECLARE `v_value2_id` bigint(18);
DECLARE `v_attr1_id` bigint(18);
DECLARE `v_attr2_id` bigint(18);
DECLARE `v_value1_symbol` text;
DECLARE `v_value2_symbol` text;
DECLARE `v_pos` int;
DECLARE `v_count` int DEFAULT 0;

SET `v_ecl`='';

-- Copy the input parameter with a trailing pipe appended (support last iteration of pipe loop)
SET `v_text`=CONCAT(`p_ecl`,'|');

-- Loop to remove any pipe delimited terms and return a simplified constraint
pipe:WHILE `v_text` regexp '\|' DO
	SET `v_count`=`v_count`+1;
	SET `v_ecl`=CONCAT(`v_ecl`,SUBSTRING_INDEX(`v_text`,'|',1));
    SET `v_pos`=LENGTH(SUBSTRING_INDEX(`v_text`,'|',2))+2;
    IF `v_pos`<3 OR `v_pos`>LENGTH(`v_text`) THEN
        LEAVE pipe;
	ELSE
		SET `v_text`=MID(`v_text`,`v_pos`);
	END IF;
    IF `v_count`>10 THEN LEAVE pipe; END IF;
END WHILE pipe;

-- Remove all spaces in the ECL
SET `v_ecl`=REPLACE(`v_ecl`,' ','');

-- Split the focus concept constraint from any refinements
SET `v_focus_symbol`=SUBSTRING_INDEX(`v_ecl`,':',1);
IF `v_focus_symbol` != `v_ecl` THEN
	SET `v_refine1`=SUBSTRING_INDEX(`v_ecl`,':',-1);
	SET `v_refine2`=SUBSTRING_INDEX(`v_refine1`,',',-1);
ELSE
	SET `v_refine1`='';
END IF;

-- separate symbols from the focus concept id
IF LEFT(`v_focus_symbol`,2)='<<' THEN
	SET `v_focus_id`=MID(v_focus_symbol,3);
    SET `v_focus_symbol`='<<';
ELSEIF LEFT(`v_focus_symbol`,1)='<' THEN
	SET `v_focus_id`=MID(`v_focus_symbol`,2);
    SET `v_focus_symbol`='<';
ELSE
	SET `v_focus_id`=`v_focus_symbol`;
    SET `v_focus_symbol`='';
END IF;

-- check if there are 1 or two refinements
-- if there are two split them 
IF `v_refine2` != `v_refine1` THEN
	SET `v_refine1`=SUBSTRING_INDEX(`v_refine1`,',',1);
    -- Split the attribute name, symbol and value for refinement 2
    SET `v_attr2_id`=SUBSTRING_INDEX(`v_refine2`,'=',1);
    SET `v_value2_symbol`=SUBSTRING_INDEX(`v_refine2`,'=',-1);
	IF LEFT(`v_value2_symbol`,2)='<<' THEN
		SET `v_value2_id`=MID(`v_value2_symbol`,3);
		SET `v_value2_symbol`='<<';
	ELSEIF LEFT(`v_value2_symbol`,1)='<' THEN
		SET `v_value1_id`=MID(`v_value2_symbol`,2);
		SET `v_value2_symbol`='<';
	ELSE
		SET `v_value2_id`=`v_value2_symbol`;
		SET `v_value2_symbol`='';
	END IF;    
ELSE
    SET `v_refine2`='';
END IF;
-- If there is at least 1 refinement split the attribute name, symbol and value for refinement 1
IF `v_refine1` != '' THEN
    SET `v_attr1_id`=SUBSTRING_INDEX(`v_refine1`,'=',1);
    SET `v_value1_symbol`=SUBSTRING_INDEX(`v_refine1`,'=',-1);
	IF LEFT(`v_value1_symbol`,2)='<<' THEN
		SET `v_value1_id`=MID(`v_value1_symbol`,3);
		SET `v_value1_symbol`='<<';
	ELSEIF LEFT(`v_value1_symbol`,1)='<' THEN
		SET `v_value1_id`=MID(`v_value1_symbol`,2);
		SET `v_value1_symbol`='<';
	ELSE
		SET `v_value1_id`=`v_value1_symbol`;
		SET `v_value1_symbol`='';
	END IF;
END IF;

-- drop then create temporary tables for results focus and 1 or 2 refinements
DROP TABLE IF EXISTS tmp_focus;
DROP TABLE IF EXISTS tmp_ref1;
DROP TABLE IF EXISTS tmp_ref2;

-- Create temporary tables
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_focus (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_ref1 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_ref2 (
  `id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;
-- END OF PREPARATION STEPS

-- Get the results of the focus concept constraint
-- IF SUBTYPES INCLUDED ADD ALL CONCEPTS PASSING THE SUBSUMPTION TEST TO A TEMPORARY TABLE tmp_focus
IF `v_focus_symbol` = '<' OR `v_focus_symbol` = '<<' THEN
	INSERT IGNORE INTO `tmp_focus` SELECT `subtypeId` FROM `snap_transclose` as `tc` WHERE `tc`.`supertypeId` = `v_focus_id`;
END IF;

-- IF SELF INCLUDED ADD FOCUS CONCEPT TO TEMPORARY TABLE tmp_focus
IF `v_focus_symbol` = '' OR `v_focus_symbol` = '<<' THEN
	INSERT IGNORE INTO `tmp_focus` VALUES (`v_focus_id`);
END IF;


-- Get the results of the first refinement constraint
-- ADD ALL CONCEPTS PASSING THE FIRST ATTRIBUTE VALUE TEST TO TEMPORARY TABLE tmp_ref1
IF `v_refine1` != '' THEN
	IF `v_value1_symbol` = '<' OR `v_value1_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref1` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr1_id` 
		AND `r`.`destinationId` IN (SELECT `tc`.`subTypeId` FROM `snap_transclose` as `tc`
		WHERE `tc`.`supertypeId` = `v_value1_id` );
	END IF;
    IF `v_value1_symbol` = '' OR `v_value1_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref1` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr1_id` 
		AND `r`.`destinationId` = `v_value1_id`;
    END IF;
END IF;

-- Get the results of the second refinement constraint
-- ADD ALL CONCEPTS PASSING THE SECOND ATTRIBUTE VALUE TEST TO TEMPORARY TABLE tmp_ref2
IF `v_refine2` != '' THEN
	IF `v_value2_symbol` = '<' OR `v_value2_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref2` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr2_id` 
		AND `r`.`destinationId` IN (SELECT `tc`.`subTypeId` FROM `snap_transclose` as `tc`
		WHERE `tc`.`supertypeId` = `v_value2_id` );
	END IF;
    IF `v_value2_symbol` = '' OR `v_value2_symbol` = '<<' THEN
		INSERT IGNORE INTO `tmp_ref2` SELECT DISTINCT `sourceId` FROM `snap_relationship` as `r` WHERE `r`.`active` = 1 AND `r`.`typeId` = `v_attr2_id` 
		AND `r`.`destinationId` = `v_value2_id`;
    END IF;
END IF;

-- LIST ALL THE CONCEPT THAT ARE IN ALL THREE TEMPORARY TABLES

IF `v_refine1` = '' THEN
-- If no refinements this is simply the concepts in tmp_focus
	SELECT `pt`.`conceptId`,`pt`.`term`
	FROM `tmp_focus`, `snap_pref` as `pt`
		WHERE  `pt`.`conceptId` = `tmp_focus`.`id` 
		ORDER BY `pt`.`term`;

ELSEIF `v_refine2` = '' THEN
-- If there is only one refinement constraint only list concepts found BOTH in tmp_focus AND in tmp_ref1
	SELECT `pt`.`conceptId`,`pt`.`term`
	FROM `tmp_focus`, `snap_pref` as `pt`
		WHERE  `pt`.`conceptId` = `tmp_focus`.`id` 
		AND `tmp_focus`.`id` IN (SELECT `id` FROM `tmp_ref1`)
		ORDER BY `pt`.`term`;

ELSE
-- If there are two refinement constraints only list concepts found in ALL three table tmp_focus AND tmp_ref1 AND tmp_ref2
	SELECT `pt`.`conceptId`,`pt`.`term` `prefTerm`
	FROM `tmp_focus`, `snap_pref` as `pt`
		WHERE  `pt`.`conceptId` = `tmp_focus`.`id` 
		AND `pt`.`conceptId` IN (SELECT `id` FROM `tmp_ref1`)
		AND `pt`.`conceptId` IN (SELECT `id` FROM `tmp_ref2`)
		ORDER BY `pt`.`term`;

END IF;

-- Remove the temporary tables
DROP TABLE IF EXISTS `tmp_focus`;
DROP TABLE IF EXISTS `tmp_ref1`;
DROP TABLE IF EXISTS `tmp_ref2`;

END;;

-- fiTC
-- Previous line replace by end block comment if no Transitive Closure

DELIMITER ;
DROP PROCEDURE IF EXISTS `snap_SearchPlus`;
DELIMITER ;;
CREATE PROCEDURE `snap_SearchPlus`(`p_search` text,`p_filter` text)
BEGIN
-- 
-- snap_SearchPlus(p_search,p_filter)
--   p_search: string for fulltext search 
--    (if it includes + or - the uses boolean mode otherwise natural language mode).
--   p_filter: string for either
--          Regular expression filtering (Starting '!' negates the search) or
--          Subsumption filtering if starts with '<' followed by id or a shortcut term.
--          See config_shortcuts table (created and populated in this part of the script)
-- Specify using one of the following options:
-- FULL TEXT SEARCH
-- p_search (with empty p_filter string)
-- Examples:
--     CALL snap_SearchPlus('fundus stomach', '');
--     CALL snap_SearchPlus('+fundus +stomach','');
--     CALL snap_SearchPlus('+lung +disease -chronic','');
-- REGULAR EXPRESSION SEARCH
-- p_filter (with empty p_filter string)
-- Examples: (These queries can be very slow)
--     CALL snap_SearchPlus('', '^[Ff]undus.*ch');
--     CALL snap_SearchPlus('', '.+fundus.+');
-- FULLTEXT SEARCH FILTERED BY REGULAR EXPRESSION
-- p_search and p_filter string. 
--   Examples:
--     CALL snap_SearchPlus('+fundus', 'ch');
--     CALL snap_SearchPlus('stomach','!(eye|oculi|uter)');
--     CALL snap_SearchPlus('+lung +disease +chronic','oe?dema');
--     CALL snap_SearchPlus('appendix','<proc');
--     CALL snap_SearchPlus('hemoglobin','<lab');
--     CALL snap_SearchPlus('infection','<19829001');
-- SORT ORDER:
--    Natural language mode sorted by fulltext relevance.
--    Other modes sorted by shortest term
--
-- OPTION to use short cuts in subsumption tests

IF LEFT(`p_filter`,1)='<' AND 'snap'!='snap' THEN
	SELECT 0,'Subtype tests are only supported for current snapshot view.';
ELSE

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' THEN
			SELECT `id`,`term` FROM `snap_rel_child_pref` `p` WHERE `p`.`conceptId`=SUBSTRING_INDEX(`p_filter`,'<',-1) ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE `term` regexp `p_filter` ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF `p_filter`='' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='<' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='!' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) LIMIT 200;
		END IF;
    ELSE
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` regexp `p_filter` ORDER BY length(`term`)  LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` regexp `p_filter`  LIMIT 200;
		END IF;
	END IF;
END IF;
END;;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap1_SearchPlus`;
DELIMITER ;;
CREATE PROCEDURE `snap1_SearchPlus`(`p_search` text,`p_filter` text)
BEGIN
-- 
-- snap_SearchPlus(p_search,p_filter)
--   p_search: string for fulltext search 
--    (if it includes + or - the uses boolean mode otherwise natural language mode).
--   p_filter: string for either
--          Regular expression filtering (Starting '!' negates the search) or
--          Subsumption filtering if starts with '<' followed by id or a shortcut term.
--          See config_shortcuts table (created and populated in this part of the script)
-- Specify using one of the following options:
-- FULL TEXT SEARCH
-- p_search (with empty p_filter string)
-- Examples:
--     CALL snap_SearchPlus('fundus stomach', '');
--     CALL snap_SearchPlus('+fundus +stomach','');
--     CALL snap_SearchPlus('+lung +disease -chronic','');
-- REGULAR EXPRESSION SEARCH
-- p_filter (with empty p_filter string)
-- Examples: (These queries can be very slow)
--     CALL snap_SearchPlus('', '^[Ff]undus.*ch');
--     CALL snap_SearchPlus('', '.+fundus.+');
-- FULLTEXT SEARCH FILTERED BY REGULAR EXPRESSION
-- p_search and p_filter string. 
--   Examples:
--     CALL snap_SearchPlus('+fundus', 'ch');
--     CALL snap_SearchPlus('stomach','!(eye|oculi|uter)');
--     CALL snap_SearchPlus('+lung +disease +chronic','oe?dema');
--     CALL snap_SearchPlus('appendix','<proc');
--     CALL snap_SearchPlus('hemoglobin','<lab');
--     CALL snap_SearchPlus('infection','<19829001');
-- SORT ORDER:
--    Natural language mode sorted by fulltext relevance.
--    Other modes sorted by shortest term
--
-- OPTION to use short cuts in subsumption tests

IF LEFT(`p_filter`,1)='<' AND 'snap1'!='snap' THEN
	SELECT 0,'Subtype tests are only supported for current snapshot view.';
ELSE

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' THEN
			SELECT `id`,`term` FROM `snap_rel_child_pref` `p` WHERE `p`.`conceptId`=SUBSTRING_INDEX(`p_filter`,'<',-1) ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE `term` regexp `p_filter` ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF `p_filter`='' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='<' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='!' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) LIMIT 200;
		END IF;
    ELSE
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` regexp `p_filter` ORDER BY length(`term`)  LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap1_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` regexp `p_filter`  LIMIT 200;
		END IF;
	END IF;
END IF;
END;;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap2_SearchPlus`;
DELIMITER ;;
CREATE PROCEDURE `snap2_SearchPlus`(`p_search` text,`p_filter` text)
BEGIN
-- 
-- snap_SearchPlus(p_search,p_filter)
--   p_search: string for fulltext search 
--    (if it includes + or - the uses boolean mode otherwise natural language mode).
--   p_filter: string for either
--          Regular expression filtering (Starting '!' negates the search) or
--          Subsumption filtering if starts with '<' followed by id or a shortcut term.
--          See config_shortcuts table (created and populated in this part of the script)
-- Specify using one of the following options:
-- FULL TEXT SEARCH
-- p_search (with empty p_filter string)
-- Examples:
--     CALL snap_SearchPlus('fundus stomach', '');
--     CALL snap_SearchPlus('+fundus +stomach','');
--     CALL snap_SearchPlus('+lung +disease -chronic','');
-- REGULAR EXPRESSION SEARCH
-- p_filter (with empty p_filter string)
-- Examples: (These queries can be very slow)
--     CALL snap_SearchPlus('', '^[Ff]undus.*ch');
--     CALL snap_SearchPlus('', '.+fundus.+');
-- FULLTEXT SEARCH FILTERED BY REGULAR EXPRESSION
-- p_search and p_filter string. 
--   Examples:
--     CALL snap_SearchPlus('+fundus', 'ch');
--     CALL snap_SearchPlus('stomach','!(eye|oculi|uter)');
--     CALL snap_SearchPlus('+lung +disease +chronic','oe?dema');
--     CALL snap_SearchPlus('appendix','<proc');
--     CALL snap_SearchPlus('hemoglobin','<lab');
--     CALL snap_SearchPlus('infection','<19829001');
-- SORT ORDER:
--    Natural language mode sorted by fulltext relevance.
--    Other modes sorted by shortest term
--
-- OPTION to use short cuts in subsumption tests

IF LEFT(`p_filter`,1)='<' AND 'snap2'!='snap' THEN
	SELECT 0,'Subtype tests are only supported for current snapshot view.';
ELSE

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `config_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' THEN
			SELECT `id`,`term` FROM `snap_rel_child_pref` `p` WHERE `p`.`conceptId`=SUBSTRING_INDEX(`p_filter`,'<',-1) ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE `term` regexp `p_filter` ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF `p_filter`='' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='<' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) ORDER BY length(`term`) LIMIT 200;
		END IF;
    ELSEIF LEFT(`p_filter`,1)='!' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` not regexp MID(`p_filter`,2) LIMIT 200;
		END IF;
    ELSE
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` regexp `p_filter` ORDER BY length(`term`)  LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap2_term_search_active` WHERE MATCH (`term`)
			AGAINST (`p_search` IN NATURAL LANGUAGE MODE) AND `term` regexp `p_filter`  LIMIT 200;
		END IF;
	END IF;
END IF;
END;;
DELIMITER ;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap_ShowLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap_ShowLanguages`(`p_conceptId` BIGINT,`p_langCodeA` text,`p_langCodeB` text)
BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms
-- in two languages or dialects. Only works for languages/dialects in the release files.
-- So with International Release can be tested with following call.
--   CALL snap_ShowLanguages(80146002,'en-GB','en-US');
--
DECLARE `v_defaultLanguage` text;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=0);
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` BIGINT,`type_and_lang` text,`term` text);
CALL setLanguage(0,`p_langCodeA`);
INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
SELECT `conceptid`,CONCAT('FSN',' ',`p_langCodeA`) `type and lang`,`term` FROM `snap_fsn` 
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Preferred',' ', `p_langCodeA`) `type and lang`,`term` FROM `snap_pref`
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Synonyms',' ',`p_langCodeA`) `type and lang`,`term` FROM `snap_syn` 
    WHERE `conceptid`=`p_conceptId`;
CALL setLanguage(0,`p_langCodeB`);
INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
SELECT `conceptid`,CONCAT('FSN',' ',`p_langCodeB`) `type and lang`,`term` FROM `snap_fsn` 
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Preferred',' ', `p_langCodeB`) `type and lang`,`term` FROM `snap_pref`
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Synonyms',' ', `p_langCodeB`) `type and lang`,`term` FROM `snap_syn`
    WHERE `conceptid`=`p_conceptId`;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(0,`v_defaultLanguage`);
END;;
DELIMITER ;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap1_ShowLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap1_ShowLanguages`(`p_conceptId` BIGINT,`p_langCodeA` text,`p_langCodeB` text)
BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms
-- in two languages or dialects. Only works for languages/dialects in the release files.
-- So with International Release can be tested with following call.
--   CALL snap_ShowLanguages(80146002,'en-GB','en-US');
--
DECLARE `v_defaultLanguage` text;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=1);
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` BIGINT,`type_and_lang` text,`term` text);
CALL setLanguage(1,`p_langCodeA`);
INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
SELECT `conceptid`,CONCAT('FSN',' ',`p_langCodeA`) `type and lang`,`term` FROM `snap1_fsn` 
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Preferred',' ', `p_langCodeA`) `type and lang`,`term` FROM `snap1_pref`
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Synonyms',' ',`p_langCodeA`) `type and lang`,`term` FROM `snap1_syn` 
    WHERE `conceptid`=`p_conceptId`;
CALL setLanguage(1,`p_langCodeB`);
INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
SELECT `conceptid`,CONCAT('FSN',' ',`p_langCodeB`) `type and lang`,`term` FROM `snap1_fsn` 
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Preferred',' ', `p_langCodeB`) `type and lang`,`term` FROM `snap1_pref`
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Synonyms',' ', `p_langCodeB`) `type and lang`,`term` FROM `snap1_syn`
    WHERE `conceptid`=`p_conceptId`;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(1,`v_defaultLanguage`);
END;;
DELIMITER ;
DELIMITER ;
DROP PROCEDURE IF EXISTS `snap2_ShowLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap2_ShowLanguages`(`p_conceptId` BIGINT,`p_langCodeA` text,`p_langCodeB` text)
BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms
-- in two languages or dialects. Only works for languages/dialects in the release files.
-- So with International Release can be tested with following call.
--   CALL snap_ShowLanguages(80146002,'en-GB','en-US');
--
DECLARE `v_defaultLanguage` text;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=2);
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` BIGINT,`type_and_lang` text,`term` text);
CALL setLanguage(2,`p_langCodeA`);
INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
SELECT `conceptid`,CONCAT('FSN',' ',`p_langCodeA`) `type and lang`,`term` FROM `snap2_fsn` 
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Preferred',' ', `p_langCodeA`) `type and lang`,`term` FROM `snap2_pref`
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Synonyms',' ',`p_langCodeA`) `type and lang`,`term` FROM `snap2_syn` 
    WHERE `conceptid`=`p_conceptId`;
CALL setLanguage(2,`p_langCodeB`);
INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
SELECT `conceptid`,CONCAT('FSN',' ',`p_langCodeB`) `type and lang`,`term` FROM `snap2_fsn` 
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Preferred',' ', `p_langCodeB`) `type and lang`,`term` FROM `snap2_pref`
    WHERE `conceptid`=`p_conceptId`
UNION
SELECT `conceptid`,CONCAT('Synonyms',' ', `p_langCodeB`) `type and lang`,`term` FROM `snap2_syn`
    WHERE `conceptid`=`p_conceptId`;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(2,`v_defaultLanguage`);
END;;
DELIMITER ;


-- Now Create and Populate Shortcuts Table
-- Useful for quick use of subsumption limits.
DROP TABLE IF EXISTS `config_shortcuts`;
CREATE TABLE `config_shortcuts` (
  `abbrev` varchar(5) NOT NULL,
  `conceptId` bigint(10) NOT NULL,
  PRIMARY KEY (`abbrev`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `config_shortcuts` (`abbrev`,`conceptId`) 
VALUES ('anat',91723000),
('attr',246061005),
('body',123037004),
('clin',404684003),
('dise',64572001),
('envi',308916002),
('eval',386053000),
('even',272379006),
('find',404684003),
('forc',78621006),
('lab',108252007),
('meas',122869004),
('meta',900000000000441003),
('morph',118956008),
('obje',260787004),
('obse',363787002),
('orga',410607006),
('phar',373873005),
('proc',71388002),
('qual',362981000),
('qval',362981000),
('reco',419891008),
('refs',900000000000455006),
('situ',243796009),
('soci',48176007),
('spec',123038009),
('stag',254291000),
('subs',105590001),
('swec',243796009);


-- END EXTRAS --

-- SNOMED CT MySQL Loader Processing Completed (DB=$DBNAME) --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"SNOMED CT MySQL Loader Processing Completed (DB=$DBNAME)";
