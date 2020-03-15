

-- ===========================================
-- Load Extension into Database
-- ===========================================

-- IMPORTS SNOMED CT RF2 FULL RELEASE INTO MYSQL DATA BASE

-- MySQL Script for Loading and Optimizing SNOMED CT Release Files
-- Apache 2.0 license applies
-- 
-- =======================================================
-- Copyright of this version 2019: SNOMED International www.snomed.org
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
-- Release Package: $PACKAGE 
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

-- 
-- PACKAGE AND OPTION SETTINGS USED TO PRODUCING THIS SCRIPT
-- 
-- Release Package: SnomedCT_GPFP_PRODUCTION_20191030T120000
-- Package Code: GPFP
-- Release Date: 20191030
-- Extension not including root concept
-- RFS Specification Creation: 20200117121735
-- 
-- CHECK MySQL Server Settings

-- INITIALIZE SETTINGS
SET GLOBAL net_write_timeout = 60;
SET GLOBAL net_read_timeout=120;
SET GLOBAL sql_mode ='';
SET SESSION sql_mode ='';

-- CREATE THE CHECK SETTINGS PROCEDURE
DELIMITER ;;
DROP PROCEDURE IF EXISTS CheckMySqlSettings;;
CREATE PROCEDURE CheckMySqlSettings()
BEGIN
DECLARE specialty CONDITION FOR SQLSTATE '45000';
DECLARE `msg` text;
SELECT "CHECKING MySQL CONFIGURATION SETTINGS";
SET @req_len=2;
SET @req_stop='';
SET @req_infile=1;

SELECT * FROM (
SELECT IF(@@GLOBAL.ft_min_word_len=@req_len,'MySQL Fulltext minimum word length OK',CONCAT('WARNING! Fulltext minimum word length (ft_min_word_len) must be ',@req_len,' but has value: ', @@GLOBAL.ft_min_word_len)) 'Message'
UNION
SELECT IF(@@GLOBAL.ft_min_word_len=@req_len,'','* This will cause short words and abbreviations to omitted from search results.') 'MySQL Config Check'
UNION
SELECT IF(@@GLOBAL.ft_stopword_file=@req_stop,'MySQL Fulltext stopword file OK',CONCAT('WARNING! Fulltext stopword file (ft_stopword_file) must be empty string but has value: ', @@GLOBAL.ft_stopword_file))
UNION
SELECT IF(@@GLOBAL.ft_stopword_file=@req_stop,'','* This will cause some significant clinical words to be omitted from search results!')
UNION
SELECT IF(@@GLOBAL.local_infile=@req_infile,'MySQL Local Infile setting OK',CONCAT('ERROR! Local file load (local_infile) must be 1 but has value: ', @@GLOBAL.local_infile))
UNION
SELECT IF(@@GLOBAL.local_infile=@req_infile,'','* This will prevent SNOMED CT release files being loaded into the database!')
UNION
SELECT IF(@@GLOBAL.ft_min_word_len=@req_len AND @@GLOBAL.ft_stopword_file=@req_stop AND @@GLOBAL.local_infile=@req_infile,'','1. See instructions on setting required configuration.')
UNION
SELECT IF(@@GLOBAL.ft_min_word_len=@req_len AND @@GLOBAL.ft_stopword_file=@req_stop AND @@GLOBAL.local_infile=@req_infile,'','2. Restart MySQL Server after setting the required configuration.')
UNION
SELECT IF(@@GLOBAL.ft_min_word_len=@req_len AND @@GLOBAL.ft_stopword_file=@req_stop AND @@GLOBAL.local_infile=@req_infile,'','3. Then rerun the snomed_load_mysql script.')
) data
WHERE Message!='';
IF @@GLOBAL.ft_min_word_len!=@req_len OR @@GLOBAL.ft_stopword_file!=@req_stop OR @@GLOBAL.local_infile!=@req_infile THEN
	SET `msg`='MySQL Configuration Error! See messages above for details. Script Terminated.';
	SELECT `msg`;
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;
END;;

-- CALL THE CHECK SETTINGS PROCEDURE
DELIMITER ;
CALL CheckMySqlSettings();
SELECT 'MySQL Settings - OK.';

-- Create Tables --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Tables";


-- Create Tables with Prefix: full --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Tables with Prefix: full";


-- CREATE TABLE: full_refset_Simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: full_refset_Simple";

CREATE TABLE IF NOT EXISTS `full_refset_Simple` (
	`id` CHAR(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- CREATE TABLE: full_refset_ExtendedMap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: full_refset_ExtendedMap";

CREATE TABLE IF NOT EXISTS `full_refset_ExtendedMap` (
	`id` CHAR(36) NOT NULL DEFAULT '',
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


-- CREATE TABLE: full_refset_RefsetDescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: full_refset_RefsetDescriptor";

CREATE TABLE IF NOT EXISTS `full_refset_RefsetDescriptor` (
	`id` CHAR(36) NOT NULL DEFAULT '',
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


-- CREATE TABLE: full_refset_ModuleDependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: full_refset_ModuleDependency";

CREATE TABLE IF NOT EXISTS `full_refset_ModuleDependency` (
	`id` CHAR(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`sourceEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`targetEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- Create Tables with Prefix: snap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Tables with Prefix: snap";


-- CREATE TABLE: snap_refset_Simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: snap_refset_Simple";

CREATE TABLE IF NOT EXISTS `snap_refset_Simple` (
	`id` CHAR(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- CREATE TABLE: snap_refset_ExtendedMap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: snap_refset_ExtendedMap";

CREATE TABLE IF NOT EXISTS `snap_refset_ExtendedMap` (
	`id` CHAR(36) NOT NULL DEFAULT '',
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


-- CREATE TABLE: snap_refset_RefsetDescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: snap_refset_RefsetDescriptor";

CREATE TABLE IF NOT EXISTS `snap_refset_RefsetDescriptor` (
	`id` CHAR(36) NOT NULL DEFAULT '',
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


-- CREATE TABLE: snap_refset_ModuleDependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CREATE TABLE: snap_refset_ModuleDependency";

CREATE TABLE IF NOT EXISTS `snap_refset_ModuleDependency` (
	`id` CHAR(36) NOT NULL DEFAULT '',
	`effectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`active` TINYINT NOT NULL DEFAULT  0,
	`moduleId` BIGINT NOT NULL DEFAULT  0,
	`refsetId` BIGINT NOT NULL DEFAULT  0,
	`referencedComponentId` BIGINT NOT NULL DEFAULT  0,
	`sourceEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	`targetEffectiveTime` DATETIME NOT NULL DEFAULT  '2000-01-31 00:00:00',
	PRIMARY KEY (`id`,`effectiveTime`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;


-- Create Transitive Tables --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Transitive Tables";

-- CREATE TABLE `snap_transclose` 

CREATE TABLE IF NOT EXISTS `snap_transclose` (
	`subtypeId` BIGINT NOT NULL DEFAULT  0,
	`supertypeId` BIGINT NOT NULL DEFAULT  0,
	        PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `t_rev` (`supertypeId`,`subtypeId`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- CREATE TABLE snap_proximal_primitives 

CREATE TABLE IF NOT EXISTS snap_proximal_primitives (
	`subtypeId` BIGINT NOT NULL DEFAULT  0,
	`supertypeId` BIGINT NOT NULL DEFAULT  0,
	        PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `t_rev` (`supertypeId`,`subtypeId`))
	ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;



-- ===========================================
-- START LOAD DATA
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START LOAD DATA";


-- Load Tables with Prefix: full --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Tables with Prefix: full";


-- Load Table Data: full_refset_Simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: full_refset_Simple";

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Content/der2_Refset_GPFPSimpleFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_Simple`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`);


-- Load Table Data: full_refset_ExtendedMap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: full_refset_ExtendedMap";

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Map/der2_iisssccRefset_GPFPExtendedMapFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_ExtendedMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`);


-- Load Table Data: full_refset_RefsetDescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: full_refset_RefsetDescriptor";

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_cciRefset_GPFPRefsetDescriptorFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_RefsetDescriptor`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`);


-- Load Table Data: full_refset_ModuleDependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: full_refset_ModuleDependency";

LOAD DATA LOCAL INFILE '$RELPATH/Full/Refset/Metadata/der2_ssRefset_GPFPModuleDependencyFull_INT_$RELDATE.txt'
INTO TABLE `full_refset_ModuleDependency`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`);


-- Load Tables with Prefix: snap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Tables with Prefix: snap";


-- Load Table Data: snap_refset_Simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: snap_refset_Simple";

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Content/der2_Refset_GPFPSimpleSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_Simple`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`);


-- Load Table Data: snap_refset_ExtendedMap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: snap_refset_ExtendedMap";

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Map/der2_iisssccRefset_GPFPExtendedMapSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_ExtendedMap`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`);


-- Load Table Data: snap_refset_RefsetDescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: snap_refset_RefsetDescriptor";

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_cciRefset_GPFPRefsetDescriptorSnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_RefsetDescriptor`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`);


-- Load Table Data: snap_refset_ModuleDependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Load Table Data: snap_refset_ModuleDependency";

LOAD DATA LOCAL INFILE '$RELPATH/Snapshot/Refset/Metadata/der2_ssRefset_GPFPModuleDependencySnapshot_INT_$RELDATE.txt'
INTO TABLE `snap_refset_ModuleDependency`
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`id`,`effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`);


-- END LOAD DATA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END LOAD DATA";



-- ===========================================
-- START CONFIGURATION
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START CONFIGURATION";

USE `$DBNAME`;
-- Create Configuration Tables and Initial Settings
DELIMITER ;

CREATE TABLE IF NOT EXISTS `config_language` (
 `id` bigint,
 `prefix` varchar(5),
 `name` VARCHAR (255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  INDEX pfx (`prefix`)
) ENGINE=MyISAM CHARSET=utf8mb4;

INSERT IGNORE INTO `config_language` (`prefix`,`id`,`name`)
VALUES
('en-US', 900000000000509007, 'US English'),
('en-GB', 900000000000508004, 'GB English'),
('es', 448879004, 'Spanish'),
('xx-GM', 608771002, 'GMDN'),
('xh', 722128001, 'Chinese'),
('ja', 722129009, 'Japanese'),
('de', 722130004, 'German'),
('fr', 722131000, 'French'),
('en', 900000000000507009, 'English'),
('en-AU', 32570271000036106, 'Australian English'),
('es-XL', 450828004, 'Latin American Spanish'),
('nl-BE', 31000172101, 'Belgian Dutch'),
('fr-CA', 20581000087109, 'Canadian French'),
('en-CA', 19491000087109, 'Canadian English'),
('dk', 554461000005103, 'Danish'),
('sv', 999991, 'Swedish'),
('no', 999992, 'Norwegian'),
('nl', 999993, 'Dutch');

CREATE TABLE IF NOT EXISTS `config_settings` (
  `id` tinyint(1) NOT NULL DEFAULT '1',
  `languageId` bigint DEFAULT '900000000000509007',
  `languageName` varchar(255) NOT NULL DEFAULT 'US English',
  `snapshotTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deltaStartTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deltaEndTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- Release date is set here and end of the day of release
-- This avoids issues if effectiveTime contain a time element.
SET @RELDATE=TIMESTAMP(CONCAT('$RELDATE','235959'));

-- The row with id=0 is not used directly except as default values to refresh other rows
-- Row 0 set on database load: 
--			snapshotTime and deltaEndTime set to release date 
--          deltaStartTime set to 6 month earlier
-- Other values are reset by resetConfig() 6 and 12 months later than the row with id=0
-- and can be set to specific values using the setDeltaRange and setSnapshotTime procedures.

DELETE FROM `config_settings` WHERE `id`=0;

INSERT IGNORE INTO `config_settings` (`id`,`languageId`,`languageName`,`snapshotTime`,`deltaStartTime`,`deltaEndTime`)
VALUES 
(0,900000000000509007,'US English', @RELDATE, DATE_SUB(@RELDATE,INTERVAL 6 MONTH),@RELDATE);
USE `$DBNAME`;
-- Create Configuration Procedures

DELIMITER ;;
DROP PROCEDURE IF EXISTS `resetConfig`;;
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

DELIMITER ;;
DROP PROCEDURE IF EXISTS `setLanguage`;;
CREATE PROCEDURE `setLanguage`(IN `p_id` tinyint, IN `p_lang_code` varchar(5))
proc:BEGIN
-- This procedure sets the language using the language-dialect code (e.g. en-GB etc)
-- This can be applied to any of the numbered views.
DECLARE `languageId` BIGINT;
DECLARE `langRefsetName` text;
DECLARE `msg` text;
DECLARE specialty CONDITION FOR SQLSTATE '45000';

-- DEFAULT TO en-US
IF `p_lang_code`='' THEN 
	SET `p_lang_code`='en-US';
END IF;

-- GET Language refsetId from config_language for the Language Code
SET `languageId`=(SELECT `id` FROM `config_language` WHERE `prefix`=`p_lang_code`);
IF ISNULL(`languageId`) THEN
    -- Error if no record for this lang_code in config_language
	SET `msg`=CONCAT('Language Code Not Found: ',`p_lang_code`);
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;

-- GET Preferred Synonym for the refsetId from snap_pref
SET `langRefsetName`=(SELECT `term` FROM `snap_pref` WHERE `conceptId`=`languageId`);
IF ISNULL(`langRefsetName`) THEN
    -- Error if no preferred synonym in snap_pref
    set `msg`=CONCAT('ERR: Language Refset Name Not Found for : ',`p_lang_code`,' RefsetId: ',`languageId`);
 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;

-- CHECK if any members in the snap_refset_language for this refsetId
SET @test=(SELECT `id` FROM `snap_refset_language` WHERE `refsetId`=`languageId` LIMIT 1);
IF ISNULL(@test) THEN
    -- Error if no members
	set `msg`= CONCAT('ERR: No Language Refset Members Found for : ',`p_lang_code`,' RefsetId: ',`languageId`,'Name: ',`langRefsetName`);
 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;

UPDATE `config_settings` `s`, `config_language` `l`
	SET `s`.`languageId`=`l`.`id`,
	`s`.`languageName`=`l`.`name`
	WHERE `l`.`prefix`=`p_lang_code`
	AND `s`.`id`=`p_id`;
END;;

--
DELIMITER ;;
DROP PROCEDURE IF EXISTS `setSnapshotTime`;;
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
DROP PROCEDURE IF EXISTS `setDeltaRange`;;
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

DELIMITER ;;
DROP PROCEDURE IF EXISTS `showConfig`;;
CREATE PROCEDURE `showConfig`()
BEGIN
-- This trivial procedure just shows the config_settings table content (included for completeness)
SELECT `c`.`id`,`languageId`,`languageName`, `term` `refsetName`,DATE(TIMESTAMP(`snapshotTime`)) `snapshotTime`,DATE(TIMESTAMP(`deltaStartTime`)) `deltaStartTime`,DATE(TIMESTAMP(`deltaEndTime`)) `deltaEndTime` FROM `config_settings` `c` JOIN `snap_fsn` on `c`.`languageId`=`conceptId` ORDER BY `c`.`id`;
END;;

-- 

DELIMITER ;;
DROP PROCEDURE IF EXISTS `resetConfigOpt`;;
CREATE PROCEDURE `resetConfigOpt` ()
BEGIN
	SET @cfgLines=(SELECT count(`id`) FROM `config_settings`);
	IF @cfgLines=1 THEN
		CALL `resetConfig`();
	END IF;
END;;
DELIMITER ;

CALL resetConfigOpt();
DROP PROCEDURE IF EXISTS `resetConfigOpt`;


DELIMITER ;


-- END CONFIGURATION --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END CONFIGURATION";



-- ===========================================
-- START VERSIONED VIEWS
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START VERSIONED VIEWS";


-- VIEW SNAP CURRENT --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW SNAP CURRENT";


-- VIEW DELTA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW DELTA";


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_Simple`;
CREATE VIEW `delta_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_ExtendedMap`;
CREATE VIEW `delta_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_RefsetDescriptor`;
CREATE VIEW `delta_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_ModuleDependency`;
CREATE VIEW `delta_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


-- VIEW SNAP ALT --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW SNAP ALT";


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_Simple`;
CREATE VIEW `snap1_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_ExtendedMap`;
CREATE VIEW `snap1_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_RefsetDescriptor`;
CREATE VIEW `snap1_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_ModuleDependency`;
CREATE VIEW `snap1_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


-- VIEW DELTA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW DELTA";


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_Simple`;
CREATE VIEW `delta1_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_ExtendedMap`;
CREATE VIEW `delta1_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_RefsetDescriptor`;
CREATE VIEW `delta1_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_ModuleDependency`;
CREATE VIEW `delta1_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


-- VIEW SNAP ALT --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW SNAP ALT";


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_Simple`;
CREATE VIEW `snap2_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_ExtendedMap`;
CREATE VIEW `snap2_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_RefsetDescriptor`;
CREATE VIEW `snap2_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_ModuleDependency`;
CREATE VIEW `snap2_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


-- VIEW DELTA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW DELTA";


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_Simple`;
CREATE VIEW `delta2_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_ExtendedMap`;
CREATE VIEW `delta2_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_RefsetDescriptor`;
CREATE VIEW `delta2_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_ModuleDependency`;
CREATE VIEW `delta2_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


-- END VERSIONED VIEWS --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END VERSIONED VIEWS";



-- ===========================================
-- START COMPOSITE VIEWS
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START COMPOSITE VIEWS";

-- Create View Special Snap views for 'snap'
DELIMITER ;
USE `$DBNAME`;

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

DROP VIEW IF EXISTS `snap_rel_def_pref`;

CREATE VIEW `snap_rel_def_pref` AS
(SELECT `r`.`sourceId` `sourceId`,`src`.`Term` `sourceTerm`,`r`.`typeId` `typeId`,`typ`.`Term` `typeTerm`,`r`.`destinationId` `destinationId`,`dest`.`Term` `destinationTerm`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap_relationship` `r`
	JOIN `snap_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap_rel_def_fsn`;

CREATE VIEW `snap_rel_def_fsn` AS
(SELECT `r`.`sourceId` `sourceId`,`src`.`Term` `sourceTerm`,`r`.`typeId` `typeId`,`typ`.`Term` `typeTerm`,`r`.`destinationId` `destinationId`,`dest`.`Term` `destinationTerm`,`r`.`relationshipGroup` `relationshipGroup`
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

DELIMITER ;
-- Create View Special Delta views for 'delta'
DELIMITER ;
USE `$DBNAME`;

-- No views specified at present

DELIMITER ;
-- Create View Special All views for 'delta'
DELIMITER ;
USE `$DBNAME`;
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

DELIMITER ;
-- Create View Special Snap views for 'snap1'
DELIMITER ;
USE `$DBNAME`;

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

DROP VIEW IF EXISTS `snap1_rel_def_pref`;

CREATE VIEW `snap1_rel_def_pref` AS
(SELECT `r`.`sourceId` `sourceId`,`src`.`Term` `sourceTerm`,`r`.`typeId` `typeId`,`typ`.`Term` `typeTerm`,`r`.`destinationId` `destinationId`,`dest`.`Term` `destinationTerm`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap1_relationship` `r`
	JOIN `snap1_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap1_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap1_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap1_rel_def_fsn`;

CREATE VIEW `snap1_rel_def_fsn` AS
(SELECT `r`.`sourceId` `sourceId`,`src`.`Term` `sourceTerm`,`r`.`typeId` `typeId`,`typ`.`Term` `typeTerm`,`r`.`destinationId` `destinationId`,`dest`.`Term` `destinationTerm`,`r`.`relationshipGroup` `relationshipGroup`
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

DELIMITER ;
-- Create View Special Delta views for 'delta1'
DELIMITER ;
USE `$DBNAME`;

-- No views specified at present

DELIMITER ;
-- Create View Special All views for 'delta1'
DELIMITER ;
USE `$DBNAME`;
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

DELIMITER ;
-- Create View Special Snap views for 'snap2'
DELIMITER ;
USE `$DBNAME`;

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

DROP VIEW IF EXISTS `snap2_rel_def_pref`;

CREATE VIEW `snap2_rel_def_pref` AS
(SELECT `r`.`sourceId` `sourceId`,`src`.`Term` `sourceTerm`,`r`.`typeId` `typeId`,`typ`.`Term` `typeTerm`,`r`.`destinationId` `destinationId`,`dest`.`Term` `destinationTerm`,`r`.`relationshipGroup` `relationshipGroup`
	FROM (((`snap2_relationship` `r`
	JOIN `snap2_pref` `src` ON ((`r`.`sourceId` = `src`.`conceptId`))) JOIN `snap2_pref` `typ` ON ((`r`.`typeId` = `typ`.`conceptId`))) JOIN `snap2_pref` `dest` ON ((`r`.`destinationId` = `dest`.`conceptId`))) WHERE ((`r`.`active` = 1) AND (`r`.`characteristicTypeId` = 900000000000011006)));

DROP VIEW IF EXISTS `snap2_rel_def_fsn`;

CREATE VIEW `snap2_rel_def_fsn` AS
(SELECT `r`.`sourceId` `sourceId`,`src`.`Term` `sourceTerm`,`r`.`typeId` `typeId`,`typ`.`Term` `typeTerm`,`r`.`destinationId` `destinationId`,`dest`.`Term` `destinationTerm`,`r`.`relationshipGroup` `relationshipGroup`
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

DELIMITER ;
-- Create View Special Delta views for 'delta2'
DELIMITER ;
USE `$DBNAME`;

-- No views specified at present

DELIMITER ;
-- Create View Special All views for 'delta2'
DELIMITER ;
USE `$DBNAME`;
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

DELIMITER ;

-- END COMPOSITE VIEWS --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END COMPOSITE VIEWS";



-- ===========================================
-- START TRANSITIVE CLOSURE VIEWS
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START TRANSITIVE CLOSURE VIEWS";


-- The SQL Script Generate a Snapshot View Transitive Closure Table 
-- that links all concepts to all their Supertype Ancestors

DELIMITER ;

USE `$DBNAME`;

DELIMITER ;;

-- Create a procedure that create builds Transitive Closure Views
-- A procedure is created and called because a procedure can determine
-- where the snap_transclose table contains any rows.
-- If not the views are not created.

DROP PROCEDURE IF EXISTS CreateTransCloseViews;;
CREATE PROCEDURE CreateTransCloseViews()
CRCV:BEGIN

SET @tccount=(SELECT count(supertypeId) FROM `snap_transclose` LIMIT 10);

-- IF THE Transitive Closure Table includes less than 10 rows exit procedure
IF @tccount<10 THEN
	SELECT CONCAT('** Transitive Closure Table contains ',@tccount,' rows **');
	SELECT '** Transitive Closure Views Not Created! **';
	LEAVE CRCV;
END IF;

SET @ppcount=(SELECT count(supertypeId) FROM `snap_proximal_primitives` LIMIT 1);
IF @ppcount=0 THEN
-- Create proximal primitive supertypes table
	DROP TABLE IF EXISTS `snap_supertypes_defprim`;
	DROP TABLE IF EXISTS `snap_supertypes_primprim`;
	DROP TABLE IF EXISTS `snap_supertypes_prim_nonprox`;

	CREATE TEMPORARY TABLE `snap_supertypes_defprim` (
	`subtypeId` bigint NOT NULL DEFAULT '0',
	`supertypeId` bigint NOT NULL DEFAULT '0',
	PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `p_rev` (`supertypeId`,`subtypeId`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

	CREATE TEMPORARY TABLE `snap_supertypes_primprim` (
	`subtypeId` bigint NOT NULL DEFAULT '0',
	`supertypeId` bigint NOT NULL DEFAULT '0',
	PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `pp_rev` (`supertypeId`,`subtypeId`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

	CREATE TEMPORARY TABLE `snap_supertypes_prim_nonprox` (
	`subtypeId` bigint NOT NULL DEFAULT '0',
	`supertypeId` bigint NOT NULL DEFAULT '0',
	PRIMARY KEY (`subtypeId`,`supertypeId`),
	KEY `p_rev` (`supertypeId`,`subtypeId`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- Create table with Primitive Supertypes only and ignore rows where subtypes is primitive
	INSERT INTO `snap_supertypes_defprim`
	SELECT `tc`.`subtypeId`,`tc`.`supertypeId`
		FROM `snap_transclose` `tc`
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
END IF;

SELECT Now() `--`,"Create Transitive Closure and Proximal Primitive Views" '--';

-- CREATE TRANSITIVE CLOSURE VIEWS

DROP VIEW IF EXISTS `snap_tc_descendant_fsn`;

CREATE VIEW `snap_tc_descendant_fsn` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_transclose` `r`
	JOIN `snap_fsn` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_tc_descendant_pref`;

CREATE VIEW `snap_tc_descendant_pref` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_transclose` `r`
	JOIN `snap_pref` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_tc_ancestor_fsn`;

CREATE VIEW `snap_tc_ancestor_fsn` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_transclose` `r`
	JOIN `snap_fsn` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_tc_ancestor_pref`;

CREATE VIEW `snap_tc_ancestor_pref` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_transclose` `r`
JOIN `snap_pref` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

-- PROXIMAL PRIMITIVE VIEWS

DROP VIEW IF EXISTS `snap_pp_child_fsn`;

CREATE VIEW `snap_pp_child_fsn` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
	JOIN `snap_fsn` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_pp_child_pref`;

CREATE VIEW `snap_pp_child_pref` AS
(SELECT `r`.`subtypeId` `id`,`d`.`term` `term`,`r`.`supertypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
	JOIN `snap_pref` `d` ON (`r`.`subtypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_pp_parent_fsn`;

CREATE VIEW `snap_pp_parent_fsn` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
	JOIN `snap_fsn` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

DROP VIEW IF EXISTS `snap_pp_parent_pref`;

CREATE VIEW `snap_pp_parent_pref` AS
(SELECT `r`.`supertypeId` `id`,`d`.`term` `term`,`r`.`subtypeId` `conceptId`
	FROM  `snap_proximal_primitives` `r`
JOIN `snap_pref` `d` ON (`r`.`supertypeId` = `d`.`conceptId`));

END;;

DELIMITER ;

CALL CreateTransCloseViews();
DROP PROCEDURE IF EXISTS  CreateTransCloseViews;
-- END TRANSITIVE CLOSURE VIEWS --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END TRANSITIVE CLOSURE VIEWS";



-- ===========================================
-- START EXTRAS
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START EXTRAS";



-- ===========================================
-- Add extra (no prefix): proc_ecl
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add extra (no prefix): proc_ecl";

-- CONTAINS eclQuery and the Older version eclSimple
USE `$DBNAME`;

DELIMITER ;;
DROP PROCEDURE IF EXISTS eclQuery;;
CREATE PROCEDURE eclQuery(p_ecl text)
proc:BEGIN

DECLARE `v_ecltrim` text DEFAULT '';
DECLARE `v_eclClause` text DEFAULT '';
DECLARE `v_focus` text DEFAULT '';
DECLARE `v_refine` text DEFAULT '';
DECLARE `v_item` text DEFAULT '';
DECLARE `v_clauseNum` int DEFAULT 1;
DECLARE `v_testNum` int DEFAULT 1;
DECLARE `v_refineCount` int DEFAULT 1;
DECLARE `v_clauseCount` int DEFAULT 1;
DECLARE `v_clauseRule`  char(1) DEFAULT '';
DECLARE `v_valSymbol` char(4) DEFAULT '';
DECLARE `v_attSymbol` char(4) DEFAULT '';
DECLARE `v_attId` BIGINT DEFAULT 0;
DECLARE `v_valId` BIGINT DEFAULT 0;
DECLARE `v_value` text DEFAULT '';
DECLARE `v_attrib` text DEFAULT '';
DECLARE `v_prevSetRule` char(1) DEFAULT '';
DECLARE `v_id` int DEFAULT 0;
DECLARE `v_ClauseTable` text DEFAULT '';
DECLARE `v_InSource` text DEFAULT '';
DECLARE `v_targetTable` text DEFAULT '';
DECLARE `v_diagnostic` BOOLEAN DEFAULT FALSE;
DECLARE `done` BOOLEAN DEFAULT FALSE;
DECLARE specialty CONDITION FOR SQLSTATE '45000';
DECLARE `msg` text;

DECLARE `curClause` CURSOR FOR SELECT `clauseNum`,max(`clauseRule`), count(`id`) FROM `tmpEcl` GROUP BY `clauseNum` ORDER BY `clauseNum`;
DECLARE `curRefine` CURSOR FOR SELECT `id`,`testNum`, `attId`,`attSymbol`,`valId`,`valSymbol` FROM `tmpEcl` WHERE `clauseNum`=`v_clauseNum` ORDER BY `testNum`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` := TRUE;

SET @ver=(SELECT VERSION());
IF @ver<8 THEN
	SET `msg`='The eclQuery procedure requires MySQL 8.0+. Please use eclSimple() with earlier versions.';
	SELECT `msg`;
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;

-- IF p_ecl STARTS WITH ? outputs diagnostics from parsing into tmpEcl table
IF LEFT(`p_ecl`,1)='?' THEN
    SET `v_diagnostic`=TRUE;
    SET `p_ecl`=TRIM(MID(`p_ecl`,2));
END IF;

DROP TABLE IF EXISTS `tmpEcl`;
CREATE TEMPORARY TABLE `tmpEcl` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `clauseNum` INT NOT NULL DEFAULT 0,
  `testNum` INT NOT NULL DEFAULT 0,
  `clauseRule` CHAR(1) DEFAULT '',
  `attId` BIGINT NOT NULL DEFAULT 0,
  `attSymbol` CHAR(4) NOT NULL DEFAULT '',
  `valId` BIGINT NOT NULL DEFAULT 0,
  `valSymbol` CHAR(4) NOT NULL DEFAULT '',
  `count` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`));

DROP TABLE IF EXISTS `tmpSourceIds`;
DROP TABLE IF EXISTS `tmpIds`;
CREATE TEMPORARY TABLE tmpIds (
    `id` bigint NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- NESTED REPLACEMENTS DO THE FOLLOWING
-- 1. Remove text between paired pipes
-- 2. Replace alternative representations of AND with ',a'
-- 3. Replace alternative representations of OR with ',o'
-- 4. Replace alternative representations or MINUS with ',m'
-- 5. Remove all spaces (this must be done after 2,3,4 as these rely on spaces around words/symbols)
SET `v_ecltrim`=regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(`p_ecl`,'[|][^|]*[|]',''),' +(AND|[Aa]nd|&+) +',',a'),' +([oO][rR]|\\|+) +',',o'),' +(minus|[Mm]inus|-) +',',m'),' *','');

-- IF NOT ENCLOSED IN BRACKETS ADD OUTER BRACKETS FOR CONSISTENT SUBSEQUENT PROCESSING
IF `v_ecltrim` not regexp '^\\(.*\\)$' THEN
	SET `v_ecltrim`=CONCAT('(',`v_ecltrim`,')');
END IF;

-- CHECK THAT BRACKETS ARE BALANCED AND NOT MISPLACED
IF `v_ecltrim` not regexp '^\\([^\\(\\)]*(\\),[aom]?\\([^\\(\\)]*)*\\)$' THEN
	SELECT "ERR: Unbalanced or Misplaced Brackets";
    LEAVE proc;
END IF;
-- TRIMMED SYMBOLIC VERSION CREATED AND ALL OK

-- Loop to extract ECL clauses enclosed in brackets (allows multiply constraint with AND / OR / MINUS)
getClause: LOOP
    -- Each iteration get the next ECL clause
    SET `v_eclClause`=regexp_substr(`v_ecltrim`,'[aom]?\\([^\\(\\)]*\\),?',1,`v_clauseNum`);
    IF ISNULL(`v_eclClause`) OR `v_clauseNum`>20 THEN
        LEAVE getClause;
    END IF;
    -- Get the rule letter a=and o=or m=minus between this and ECL clause (if any)
    IF `v_eclClause` regexp '^[aom]' THEN 
        SET `v_clauseRule`= LEFT(`v_eclClause`,1);
        -- remove rule letter and leading bracket
        SET `v_eclClause`=MID(`v_eclClause`,3);
    ELSE
        -- Just remove leading bracket
        SET `v_eclClause`=MID(`v_eclClause`,2);
    END IF;
    -- Trim ECL clause to contents of brackets
    SET `v_eclClause`=substring_index(`v_eclClause`,')',1);
    -- Check the ECL clause is processable (no nesting or grouping present in ECL Clause)
    IF `v_eclClause` regexp '\\(' THEN
        SELECT 'ERR: Nesting constraint not supported. Character "(" in an ECL Clause',`v_eclClause`;
        LEAVE proc;
    END IF;
    IF `v_eclClause` regexp ':.*:' THEN
        SELECT 'ERR: Nesting constraint not supported. More than one ":" in an ECL Clause',`v_eclClause`;
        LEAVE proc;
    END IF;
    IF `v_eclClause` regexp '[\\{\\}]' THEN
        SELECT 'ERR: Grouping constraints not supported. Characters "{" or "}" in an ECL Clause',`v_eclClause`;
        LEAVE proc;
    END IF;
    -- If the ECL clause contains a : split the focus and refinement at that point. Otherwise it is just a focus constraint
    IF `v_eclClause` regexp ':' THEN
        SET `v_focus`=substring_index(`v_eclClause`,':',1);
        SET `v_refine`=substring_index(`v_eclClause`,':',-1);
    ELSE
        SET `v_focus`=`v_eclClause`;
        SET `v_refine`='';
    END IF;
    SET `v_testNum`=1;
    -- Get the symbol and id for the focus concept and add this as a record in a temporary ECL table (tmpEcl)
    SET `v_valSymbol`=IFNULL(regexp_substr(`v_focus`,'(\\*|\\^|<[<!]?|>[>!]?)'),'=');
    SET `v_valId`=IFNULL(regexp_substr(`v_focus`,'[1-9][0-9]{5,17}'),0);
    INSERT INTO `tmpEcl` (`clauseNum`,`clauseRule`,`testNum`,`attId`,`attSymbol`,`valId`,`valSymbol`) values (`v_clauseNum`,`v_clauseRule`,`v_testNum`,0,'',`v_valId`,`v_valSymbol`);
    
    IF `v_refine`!='' THEN
        -- to simplify iteration add a comma before the refinement (this allows simple regexp pattern iteration)
        SET `v_refine`=CONCAT(',',`v_refine`);
        getRefine: LOOP
            -- Iterate through the refinement constraints spliting a the commas
            SET `v_item`=regexp_substr(`v_refine`,',[^,]+',1,`v_testNum`);
            SET `v_testNum`=`v_testNum`+1;
            IF ISNULL(`v_item`) OR `v_testNum`>20 THEN
                -- exit here when no more refinements (or after a maximum number of iterations as an error catcher)
                LEAVE getRefine;
            END IF;
            SET `v_item`=mid(`v_item`,2);
            -- SELECT `v_testNum`,`v_item`;
            SET `v_attrib`=substring_index(`v_item`,'=',1);
            SET `v_value`=substring_index(`v_item`,'=',-1);
            -- SELECT `v_attrib`,`v_value`;
            SET `v_valSymbol`=IFNULL(regexp_substr(`v_value`,'(\\*|\\^|<<?)'),'=');
            SET `v_valId`=IFNULL(regexp_substr(`v_value`,'[1-9][0-9]{5,17}'),0);
            SET `v_attSymbol`=IFNULL(regexp_substr(`v_attrib`,'(\\*\\^|<<?)'),'=');
            SET `v_attId`=IFNULL(regexp_substr(`v_attrib`,'[1-9][0-9]{5,17}'),0);
            -- SELECT `v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`;
            INSERT INTO `tmpEcl` (`clauseNum`,`testNum`,`clauseRule`,`attId`,`attSymbol`,`valId`,`valSymbol`) values (`v_clauseNum`,`v_testNum`,`v_clauseRule`,`v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`);
        END LOOP getRefine;
    END IF;
    SET `v_clauseNum`=`v_clauseNum`+1;
END LOOP getClause;

SET `v_clauseCount`=(SELECT max(`clauseNum`) FROM `tmpEcl`);

OPEN `curClause`;
SET `done`=FALSE;

clauseLoop: LOOP
    FETCH `curClause` INTO `v_clauseNum`,`v_clauseRule`,`v_refineCount`;
    IF `done` then
        LEAVE clauseLoop;
    END IF;
    -- SELECT `v_clauseNum`;
    SET `v_ClauseTable`=IF(`v_clauseNum`=1,'tmpResultIds','tmpClauseIds');
    SET `v_inSource`='';
    OPEN `curRefine`;
    refineLoop: LOOP
        FETCH `curRefine` INTO `v_id`,`v_testNum`,`v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`;
        IF `done` then
            SET `done`=FALSE;
            CLOSE `curRefine`;
            LEAVE refineLoop;
        END IF;
        IF `v_testNum`=`v_refineCount` THEN
            SET `v_targetTable`=`v_ClauseTable`;
        ELSE
            SET `v_targetTable`=CONCAT('tmpRefineIds_',`v_testNum`);
        END IF;

        SET @dropTable=CONCAT('DROP TABLE IF EXISTS ',`v_targetTable`);
        PREPARE s_dropTable FROM @dropTable;
        EXECUTE s_dropTable;
        DEALLOCATE PREPARE s_dropTable;

        SET @createTable=CONCAT('CREATE TEMPORARY TABLE `',`v_targetTable`,'` LIKE `tmpIds`');
        PREPARE s_createTable FROM @createTable;
        EXECUTE s_createTable;
        DEALLOCATE PREPARE s_createTable;
        SET @insertIds=CONCAT('INSERT IGNORE INTO `',`v_targetTable`,'` (`id`) ');

        IF `v_attId`=0 THEN
            -- Focus concept test
            CASE `v_valSymbol`
                WHEN '=' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_concept` WHERE `id`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
                WHEN '^' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `referencedComponentId` FROM `snap_refset_simple` WHERE `refsetId`=',`v_valId`,' AND `active`=1',IF(`v_inSource`!='',CONCAT(' AND `referencedComponentId`',`v_inSource`),''));
                WHEN '<' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `subtypeId`',`v_inSource`),''));
                WHEN '<<' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005))',IF(`v_inSource`!='',CONCAT(' AND `subtypeId`',`v_inSource`),''));
                WHEN '<!' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
                WHEN '>' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `supertypeId`',`v_inSource`),''));
                WHEN '>>' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005))',IF(`v_inSource`!='',CONCAT(' AND `supertypeId`',`v_inSource`),''));
                WHEN '>!' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_valId`,IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
                WHEN '*' THEN
                    SET @insertIds=CONCAT(@insertIds,'SELECT `id` FROM `snap_concept` WHERE `active`=1',IF(`v_inSource`!='',CONCAT(' AND `id`',`v_inSource`),''));
                ELSE
                    SELECT CONCAT('ERR: Invalid focus concept symbol: ',`v_valSymbol`);
                    LEAVE proc;
            END CASE;
        -- Check that the attribute specified is a valid attribute or * for any attribute
        -- Valid attributes are subtypes of 410662002 | Concept model attribute |              
        ELSEIF `v_attSymbol`='*' OR `v_attId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=410662002) THEN
            -- General Source for Inserting Ids is same for refinements the other settings only add conditions
            SET @insertIds=CONCAT(@insertIds,'SELECT `sourceId` FROM `snap_relationship` WHERE active=1',IF(`v_inSource`!='',CONCAT(' AND `sourceId`',`v_inSource`),''));

            -- ADD CONDITIONS FOR typeId
            CASE `v_attSymbol`
                WHEN '=' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId`=',`v_attId`);
                WHEN '<' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_attId`,')');
                WHEN '<<' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_attId`,' or (`subtypeId`=',`v_attId`,' and `supertypeId`=410662002)))');
                WHEN '<!' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_attId`,')');
                WHEN '>' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_attId`,')');
                WHEN '>>' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_attId`,' or (`subtypeId`=',`v_attId`,' and `supertypeId`=138875005))',')');
                WHEN '>!' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `typeId` IN (SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_attId`,')');
                ELSE
                    -- Symbol * implies any attribute type. Other symbols are errors
                    IF `v_attSymbol`!='*' THEN
                        SELECT CONCAT('ERR: Invalid attribute type symbol: ',`v_attSymbol`);
                        LEAVE proc;
                    END IF;
            END CASE;
            -- ADD CONDITIONS FOR destinationId
            CASE `v_valSymbol`
                WHEN '=' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId`=',`v_valId`);
                WHEN '<' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_valId`,')');
                WHEN '<<' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005)))');
                WHEN '<!' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_valId`,')');
                WHEN '>' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_valId`,')');
                WHEN '>>' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005)))');
                WHEN '>!' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_valId`,')');
                WHEN '^' THEN
                    SET @insertIds=CONCAT(@insertIds,' AND `destinationId` IN (SELECT `referencedComponentId` FROM `snap_refset_simple` WHERE `refsetId`=',`v_valId`,' AND `active`=1');
                ELSE
                    IF `v_valSymbol`!='*' THEN
                        -- Symbol * implies any value. Other symbols are errors
                        SELECT CONCAT('ERR: Invalid attribute value symbol: ',`v_valSymbol`);
                        LEAVE proc;
                    END IF;
            END CASE;
        ELSE
            SELECT CONCAT('ERR: Invalid attributeId Specified: ',`v_attid`);
            LEAVE proc;
        END IF;
        PREPARE s_insertIds FROM @insertIds;
        EXECUTE s_insertIds;
        UPDATE `tmpEcl` SET `count`=ROW_COUNT() where `id`=`v_id`;
        DEALLOCATE PREPARE s_insertIds;

        -- v_inSource is '' for first loop then becomes v_targetTable from previous iteration
        SET `v_inSource`=CONCAT(' IN (SELECT `id` FROM ',`v_targetTable`,')');

    END LOOP refineLoop;
    IF `v_clauseNum`>1 THEN
        CASE `v_clauseRule`
            WHEN 'o' THEN -- OR
                INSERT IGNORE INTO `tmpResultIds` (`id`) SELECT `id` FROM `tmpClauseIds`;
            WHEN 'a' THEN -- AND
				ALTER TABLE `tmpResultIds` RENAME TO  `tmpSourceIds` ;
                CREATE TEMPORARY TABLE `tmpResultIds` LIKE `tmpIds`;
                INSERT IGNORE INTO `tmpResultIds` (`id`) SELECT `c`.`id` FROM `tmpClauseIds` `c` JOIN `tmpSourceIds` `s` ON `s`.`id`=`c`.`id` ;
                DROP TABLE `tmpSourceIds`;
            WHEN 'm' THEN -- MINUS
				ALTER TABLE `tmpResultIds` RENAME TO  `tmpSourceIds` ;
                CREATE TEMPORARY TABLE `tmpResultIds` LIKE `tmpIds`;
                INSERT IGNORE INTO `tmpResultIds` (`id`) SELECT `s`.`id` FROM `tmpSourceIds` `s` LEFT OUTER JOIN `tmpClauseIds` `c` ON `s`.`id`=`c`.`id` 
					WHERE ISNULL(`c`.`id`);
                DROP TABLE `tmpSourceIds`;
            ELSE
                SELECT CONCAT("ERR: Invalid Clause Rule: ",`v_clauseRule`);
                LEAVE proc;
        END CASE;
    END IF;
END LOOP clauseLoop;
IF `v_diagnostic` THEN
    SELECT * FROM `tmpEcl`;
END IF;
SET @output=CONCAT('SELECT `t`.`conceptId`,`t`.`term` FROM `snap_pref` `t` JOIN `tmpResultIds` `r` ON `r`.`id`=`t`.`conceptId`');
-- SELECT @output;
PREPARE s_output FROM @output;
EXECUTE s_output;
DEALLOCATE PREPARE s_output;
END;;

-- Create eclSimple() Procedure
-- This procedure only works with current snapshot
-- Next line replace by start block comment if no Transitive Closure
-- ifTC

DROP PROCEDURE IF EXISTS `eclSimple`;;
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
DECLARE `v_value1_id` bigint;
DECLARE `v_value2_id` bigint;
DECLARE `v_attr1_id` bigint;
DECLARE `v_attr2_id` bigint;
DECLARE `v_value1_symbol` text;
DECLARE `v_value2_symbol` text;
DECLARE `v_pos` int;
DECLARE `v_count` int DEFAULT 0;
DECLARE specialty CONDITION FOR SQLSTATE '45000';
DECLARE `msg` text;

SET @ver=(SELECT VERSION());
IF @ver>=8 THEN
	SET `msg`='With MySQL 8.0+. Please use the more powerful eclQuery() procedure.';
	SELECT `msg`;
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = `msg`;
END IF;

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
  `id` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_ref1 (
  `id` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

CREATE TEMPORARY TABLE IF NOT EXISTS tmp_ref2 (
  `id` bigint NOT NULL DEFAULT '0',
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

DELIMITER ;


-- ===========================================
-- Add extra (with prefix): proc_search
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add extra (with prefix): proc_search";

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


-- ===========================================
-- Add extra (with prefix): proc_languages
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add extra (with prefix): proc_languages";

DROP PROCEDURE IF EXISTS `snap_termsInLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap_termsInLanguages`(`p_conceptIds` text,`p_langCodes` text)
proc:BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms for
-- Concepts in a comma separated list of ids
-- In languages or dialects in a comma separated list of language codes.
-- Only works for languages/dialects in the release files.
-- So with International Release can be tested with calls like the following.
--   CALL snap_termsInLanguages('80146002,49438003','en-GB,en-US');
-- However, if other language description files and language refsets are imported those can also be included.
--
-- SAVE CURRENT LANGUAGE SETTING - so it can be restored later.
DECLARE `v_conceptId` text;
DECLARE `v_langCode` text;
DECLARE `v_defaultLanguage` text;
DECLARE `v_cptcount` INT DEFAULT 1;
DECLARE `v_langcount` INT DEFAULT 1;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=0);

-- CREATE TEMPORARY TABLE - for terms from the two languages
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` bigint,`type_and_lang` text,`term` text);

SET `p_conceptIds`=CONCAT(`p_conceptIds`,',');
SET `p_langCodes`=CONCAT(`p_langCodes`,',');

-- LOOP FOR CONCEPTS
    SET `v_cptcount`=1;
conceptIds:LOOP
    SET `v_conceptId`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_conceptIds`,',',`v_cptcount`),',',-1);
    IF `v_conceptId` not regexp '[1-9][0-9]{5,17}' THEN
        LEAVE conceptIds;
    END IF;
    SET `v_cptcount`=`v_cptcount`+1;

    -- LOOP FOR LANGUAGES
    SET `v_langcount`=1;
    langCodes:LOOP
        SET `v_langCode`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_langCodes`,',',`v_langcount`),',',-1);
        IF `v_langCode` not regexp '^[a-z]{2}' THEN
            LEAVE langCodes;
        END IF;
        SET `v_langcount`=`v_langcount`+1;

        CALL setLanguage(0,`v_langCode`);
        INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
        SELECT `conceptid`,CONCAT('FSN',' ',`v_langCode`) `type and lang`,`term` FROM `snap_fsn` 
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Preferred',' ', `v_langCode`) `type and lang`,`term` FROM `snap_pref`
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Synonyms',' ',`v_langCode`) `type and lang`,`term` FROM `snap_syn` 
            WHERE `conceptId`=`v_conceptId`;
    END LOOP;
END LOOP;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(0,`v_defaultLanguage`);
END;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `snap1_termsInLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap1_termsInLanguages`(`p_conceptIds` text,`p_langCodes` text)
proc:BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms for
-- Concepts in a comma separated list of ids
-- In languages or dialects in a comma separated list of language codes.
-- Only works for languages/dialects in the release files.
-- So with International Release can be tested with calls like the following.
--   CALL snap_termsInLanguages('80146002,49438003','en-GB,en-US');
-- However, if other language description files and language refsets are imported those can also be included.
--
-- SAVE CURRENT LANGUAGE SETTING - so it can be restored later.
DECLARE `v_conceptId` text;
DECLARE `v_langCode` text;
DECLARE `v_defaultLanguage` text;
DECLARE `v_cptcount` INT DEFAULT 1;
DECLARE `v_langcount` INT DEFAULT 1;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=1);

-- CREATE TEMPORARY TABLE - for terms from the two languages
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` bigint,`type_and_lang` text,`term` text);

SET `p_conceptIds`=CONCAT(`p_conceptIds`,',');
SET `p_langCodes`=CONCAT(`p_langCodes`,',');

-- LOOP FOR CONCEPTS
    SET `v_cptcount`=1;
conceptIds:LOOP
    SET `v_conceptId`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_conceptIds`,',',`v_cptcount`),',',-1);
    IF `v_conceptId` not regexp '[1-9][0-9]{5,17}' THEN
        LEAVE conceptIds;
    END IF;
    SET `v_cptcount`=`v_cptcount`+1;

    -- LOOP FOR LANGUAGES
    SET `v_langcount`=1;
    langCodes:LOOP
        SET `v_langCode`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_langCodes`,',',`v_langcount`),',',-1);
        IF `v_langCode` not regexp '^[a-z]{2}' THEN
            LEAVE langCodes;
        END IF;
        SET `v_langcount`=`v_langcount`+1;

        CALL setLanguage(1,`v_langCode`);
        INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
        SELECT `conceptid`,CONCAT('FSN',' ',`v_langCode`) `type and lang`,`term` FROM `snap_fsn` 
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Preferred',' ', `v_langCode`) `type and lang`,`term` FROM `snap_pref`
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Synonyms',' ',`v_langCode`) `type and lang`,`term` FROM `snap_syn` 
            WHERE `conceptId`=`v_conceptId`;
    END LOOP;
END LOOP;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(1,`v_defaultLanguage`);
END;;

DELIMITER ;
DROP PROCEDURE IF EXISTS `snap2_termsInLanguages`;
DELIMITER ;;
CREATE PROCEDURE `snap2_termsInLanguages`(`p_conceptIds` text,`p_langCodes` text)
proc:BEGIN
-- Procedure that generates a query showing the FSN, preferred and acceptable synonyms for
-- Concepts in a comma separated list of ids
-- In languages or dialects in a comma separated list of language codes.
-- Only works for languages/dialects in the release files.
-- So with International Release can be tested with calls like the following.
--   CALL snap_termsInLanguages('80146002,49438003','en-GB,en-US');
-- However, if other language description files and language refsets are imported those can also be included.
--
-- SAVE CURRENT LANGUAGE SETTING - so it can be restored later.
DECLARE `v_conceptId` text;
DECLARE `v_langCode` text;
DECLARE `v_defaultLanguage` text;
DECLARE `v_cptcount` INT DEFAULT 1;
DECLARE `v_langcount` INT DEFAULT 1;
SET `v_defaultLanguage`=(SELECT `prefix` FROM `config_language` `cl` JOIN `config_settings` `cs` ON `cl`.`id`=`cs`.`languageId` WHERE `cs`.`id`=2);

-- CREATE TEMPORARY TABLE - for terms from the two languages
DROP TABLE IF EXISTS `tmp_concept_terms`;
CREATE TEMPORARY TABLE `tmp_concept_terms` (`conceptId` bigint,`type_and_lang` text,`term` text);

SET `p_conceptIds`=CONCAT(`p_conceptIds`,',');
SET `p_langCodes`=CONCAT(`p_langCodes`,',');

-- LOOP FOR CONCEPTS
    SET `v_cptcount`=1;
conceptIds:LOOP
    SET `v_conceptId`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_conceptIds`,',',`v_cptcount`),',',-1);
    IF `v_conceptId` not regexp '[1-9][0-9]{5,17}' THEN
        LEAVE conceptIds;
    END IF;
    SET `v_cptcount`=`v_cptcount`+1;

    -- LOOP FOR LANGUAGES
    SET `v_langcount`=1;
    langCodes:LOOP
        SET `v_langCode`=SUBSTRING_INDEX(SUBSTRING_INDEX(`p_langCodes`,',',`v_langcount`),',',-1);
        IF `v_langCode` not regexp '^[a-z]{2}' THEN
            LEAVE langCodes;
        END IF;
        SET `v_langcount`=`v_langcount`+1;

        CALL setLanguage(2,`v_langCode`);
        INSERT INTO `tmp_concept_terms` (`conceptId`,`type_and_lang`,`term`)
        SELECT `conceptid`,CONCAT('FSN',' ',`v_langCode`) `type and lang`,`term` FROM `snap_fsn` 
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Preferred',' ', `v_langCode`) `type and lang`,`term` FROM `snap_pref`
            WHERE `conceptId`=`v_conceptId`
        UNION
        SELECT `conceptid`,CONCAT('Synonyms',' ',`v_langCode`) `type and lang`,`term` FROM `snap_syn` 
            WHERE `conceptId`=`v_conceptId`;
    END LOOP;
END LOOP;
SELECT * FROM `tmp_concept_terms`;
CALL setLanguage(2,`v_defaultLanguage`);
END;;

DELIMITER ;


-- ===========================================
-- Add extra (no prefix): func_refsetnames
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add extra (no prefix): func_refsetnames";

DELIMITER ;;
DROP FUNCTION IF EXISTS `snap_RefsetNames`;;
CREATE FUNCTION `snap_RefsetNames`() RETURNS text
BEGIN
--
-- Return a JSON representation of the refset names (as preferred terms);
-- Refset name concepts are by definition concepts that are subtype descendants of concept 900000000000455006
-- that do NOT have any subtype children (those with subtype children represent either refset type or groups of
-- refsets linked in some way.)
--
DECLARE done INT DEFAULT FALSE;

DECLARE namedata TEXT;
DECLARE sep VARCHAR(1) DEFAULT '';
DECLARE alldata TEXT DEFAULT '{';
DECLARE rsname CURSOR FOR SELECT CONCAT('"',`conceptId`,'":{"term":"',`term`,'","rows":0,"table":"-","files":{}}') FROM `snap_pref` WHERE `conceptId` IN (SELECT 
			`tc1`.`subtypeId` FROM (`snap_transclose` `tc1` LEFT JOIN `snap_transclose` `tc2` ON ((`tc1`.`subtypeId` = `tc2`.`supertypeId`))) WHERE ((`tc1`.`supertypeId` = 900000000000455006)
                    AND ISNULL(`tc2`.`subtypeId`)));
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN rsname;
GETRSNAMES: LOOP
	FETCH rsname INTO namedata;
	IF done THEN
		LEAVE GETRSNAMES;
	END IF;
	SET alldata=CONCAT(alldata,sep,namedata);
	SET sep=',';
END LOOP;
close rsname;
RETURN CONCAT(alldata,'}');

END;;
DELIMITER ;

-- END EXTRAS --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END EXTRAS";



-- ===========================================
-- START INDEX
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"START INDEX";


-- CreateIndexUpdater Procedure --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"CreateIndexUpdater Procedure";


DELIMITER ;;

-- This procedure is use to add indexes to created tables
-- it first checks if the named index is already present.
-- This allows this procedure to be used to add indexes without causing errors
-- or duplicate index data.

DROP PROCEDURE IF EXISTS `CreateIndexIfNotExists` ;;
CREATE PROCEDURE `CreateIndexIfNotExists` (`p_table` VARCHAR(64), `p_name` VARCHAR(64), `p_columns`  VARCHAR(128))
BEGIN
    -- p_table is name of table to be indexed.
    -- p_name is name of the index.
    --      The name (not the column names) are used to determine if index already exists.
    --      If p_name ends in _ft$ then full text index is created.
    -- p_columns is comma separated list of column names.
    --      Long string columns in a non-FT index must be followed with a number in brackets
    --      to limit indexed length. E.g. ...,textcol (200),... 
    -- 
	DECLARE `v_db` VARCHAR(64);
    DECLARE `v_exists` INTEGER;
    SET `v_db`=(SELECT database());

    SET `v_exists`=(SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE `table_schema` = `v_db` AND `table_name` = `p_table` AND `index_name` = `p_name` LIMIT 1);

    IF ISNULL(`v_exists`) THEN
        if `p_name` regexp '_ft$' THEN
            SET @sqlstmt = CONCAT('CREATE FULLTEXT INDEX ',`p_name`,' ON ',
            `p_table`,' (',`p_columns`,')');
        ELSE
            SET @sqlstmt = CONCAT('CREATE INDEX ',`p_name`,' ON ',
            `p_table`,' (',`p_columns`,')');
        END IF;
        PREPARE st FROM @sqlstmt;
        EXECUTE st;
        DEALLOCATE PREPARE st;
    END IF;
END ;;
DELIMITER ;

-- Add Additional Indexes --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Add Additional Indexes";


-- Create Indexes for Prefix: full --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Indexes for Prefix: full";


-- Index full_refset_Simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_Simple";

CALL CreateIndexIfNotExists('full_refset_Simple','sct_refset_Simple_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_Simple','sct_refset_Simple_rc','refsetId,referencedComponentId');

-- Index full_refset_ExtendedMap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_ExtendedMap";

CALL CreateIndexIfNotExists('full_refset_ExtendedMap','sct_refset_ExtendedMap_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_ExtendedMap','sct_refset_ExtendedMap_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_ExtendedMap','sct_refset_ExtendedMap_map','mapTarget');

-- Index full_refset_RefsetDescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_RefsetDescriptor";

CALL CreateIndexIfNotExists('full_refset_RefsetDescriptor','sct_refset_RefsetDescriptor_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_RefsetDescriptor','sct_refset_RefsetDescriptor_rc','refsetId,referencedComponentId');

-- Index full_refset_ModuleDependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index full_refset_ModuleDependency";

CALL CreateIndexIfNotExists('full_refset_ModuleDependency','sct_refset_ModuleDependency_c','referencedComponentId');
CALL CreateIndexIfNotExists('full_refset_ModuleDependency','sct_refset_ModuleDependency_rc','refsetId,referencedComponentId');
;


-- Create Indexes for Prefix: snap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Indexes for Prefix: snap";


-- Index snap_refset_Simple --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_Simple";

CALL CreateIndexIfNotExists('snap_refset_Simple','sct_refset_Simple_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_Simple','sct_refset_Simple_rc','refsetId,referencedComponentId');

-- Index snap_refset_ExtendedMap --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_ExtendedMap";

CALL CreateIndexIfNotExists('snap_refset_ExtendedMap','sct_refset_ExtendedMap_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_ExtendedMap','sct_refset_ExtendedMap_rc','refsetId,referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_ExtendedMap','sct_refset_ExtendedMap_map','mapTarget');

-- Index snap_refset_RefsetDescriptor --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_RefsetDescriptor";

CALL CreateIndexIfNotExists('snap_refset_RefsetDescriptor','sct_refset_RefsetDescriptor_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_RefsetDescriptor','sct_refset_RefsetDescriptor_rc','refsetId,referencedComponentId');

-- Index snap_refset_ModuleDependency --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Index snap_refset_ModuleDependency";

CALL CreateIndexIfNotExists('snap_refset_ModuleDependency','sct_refset_ModuleDependency_c','referencedComponentId');
CALL CreateIndexIfNotExists('snap_refset_ModuleDependency','sct_refset_ModuleDependency_rc','refsetId,referencedComponentId');
;


-- END INDEX --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END INDEX";



-- ===========================================
-- SNOMED CT MySQL Processing Completed (DB=$DBNAME)
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"SNOMED CT MySQL Processing Completed (DB=$DBNAME)";

