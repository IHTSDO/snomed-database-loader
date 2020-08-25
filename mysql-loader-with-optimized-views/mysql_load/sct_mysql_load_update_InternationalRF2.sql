

-- ===========================================
-- Update Views and Procedures
-- ===========================================



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
USE `$DBNAME`;
-- Create Configuration Procedures

DELIMITER ;;
DROP PROCEDURE IF EXISTS `initConfig`;;
CREATE PROCEDURE `initConfig` (`p_releaseDate` text)
BEGIN
  DECLARE `v_releaseDate` DATETIME;
  if `p_releaseDate` regexp '2[-0-9]{7,9}$' THEN
	SET `v_releaseDate`=DATE(`p_releaseDate`);
  ELSE
	SET `v_releaseDate`=DATE(NOW());
  END IF;
  SET `p_releaseDate`=CONCAT(DATE_FORMAT(v_releaseDate,'%Y%m%d'),'235959');
  DELETE FROM `config_settings` WHERE `id`=0;
	INSERT IGNORE INTO `config_settings` (`id`,`languageId`,`languageName`,`snapshotTime`,`deltaStartTime`,`deltaEndTime`)
	VALUES  (0,900000000000509007,'US English', `p_releaseDate`, DATE_SUB(`p_releaseDate`,INTERVAL 6 MONTH),`p_releaseDate`);
    CALL resetConfig();
END;;

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

DELIMITER ;

-- NOW SET THE DATE 
CALL initConfig('$RELDATE');




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

-- CREATES AND POPULATES config_refsets
-- TABLE config_refsets identifies the table used to access a particular reference set.
--
DROP TABLE IF EXISTS `config_refsets`;
CREATE TABLE `config_refsets` (
  `refsetId` bigint(20) NOT NULL,
  `refsetType` varchar(60) NOT NULL,
  PRIMARY KEY (`refsetId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `config_refsets` (`refsetId`,`refsetType`)
SELECT DISTINCT `refsetId`, 'association' `refsetType` FROM `snap_refset_association`
UNION
SELECT DISTINCT `refsetId`, 'attributevalue' FROM `snap_refset_attributevalue`
UNION
SELECT DISTINCT `refsetId`, 'descriptiontype' FROM `snap_refset_DescriptionType`
UNION
SELECT DISTINCT `refsetId`, 'extendedmap' FROM `snap_refset_extendedmap`
UNION
SELECT DISTINCT `refsetId`, 'language' FROM `snap_refset_language`
UNION
SELECT DISTINCT `refsetId`, 'moduledependency' FROM `snap_refset_moduledependency`
UNION
SELECT DISTINCT `refsetId`, 'mrcmattributedomain' FROM `snap_refset_mrcmattributedomain`
UNION
SELECT DISTINCT `refsetId`, 'mrcmattributerange' FROM `snap_refset_mrcmattributerange`
UNION
SELECT DISTINCT `refsetId`, 'mrcmdomain' FROM `snap_refset_mrcmdomain`
UNION
SELECT DISTINCT `refsetId`, 'mrcmmodulescope' FROM `snap_refset_mrcmmodulescope`
UNION
SELECT DISTINCT `refsetId`, 'owlexpression' FROM `snap_refset_owlexpression`
UNION
SELECT DISTINCT `refsetId`, 'refsetdescriptor' FROM `snap_refset_refsetdescriptor`
UNION
SELECT DISTINCT `refsetId`, 'simple' FROM `snap_refset_simple`
UNION
SELECT DISTINCT `refsetId`, 'simplemap' FROM `snap_refset_simplemap`;
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


DELIMITER ;

DROP VIEW IF EXISTS `snapAsView_concept`;
CREATE VIEW `snapAsView_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub`) where ((`sub`.`id` = `tbl`.`id`))));


DELIMITER ;

DROP VIEW IF EXISTS `snapAsView_description`;
CREATE VIEW `snapAsView_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub`) where ((`sub`.`id` = `tbl`.`id`))));


DELIMITER ;

DROP VIEW IF EXISTS `snapAsView_relationship`;
CREATE VIEW `snapAsView_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub`) where ((`sub`.`id` = `tbl`.`id`))));


DELIMITER ;

DROP VIEW IF EXISTS `snapAsView_description`;
CREATE VIEW `snapAsView_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub`) where ((`sub`.`id` = `tbl`.`id`))));


-- VIEW DELTA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW DELTA";


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_Simple`;
CREATE VIEW `delta_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_Association`;
CREATE VIEW `delta_refset_Association` AS select `tbl`.* from `full_refset_Association` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_AttributeValue`;
CREATE VIEW `delta_refset_AttributeValue` AS select `tbl`.* from `full_refset_AttributeValue` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_Language`;
CREATE VIEW `delta_refset_Language` AS select `tbl`.* from `full_refset_Language` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_ExtendedMap`;
CREATE VIEW `delta_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_SimpleMap`;
CREATE VIEW `delta_refset_SimpleMap` AS select `tbl`.* from `full_refset_SimpleMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_MRCMModuleScope`;
CREATE VIEW `delta_refset_MRCMModuleScope` AS select `tbl`.* from `full_refset_MRCMModuleScope` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_RefsetDescriptor`;
CREATE VIEW `delta_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_DescriptionType`;
CREATE VIEW `delta_refset_DescriptionType` AS select `tbl`.* from `full_refset_DescriptionType` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_MRCMAttributeDomain`;
CREATE VIEW `delta_refset_MRCMAttributeDomain` AS select `tbl`.* from `full_refset_MRCMAttributeDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_ModuleDependency`;
CREATE VIEW `delta_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_MRCMAttributeRange`;
CREATE VIEW `delta_refset_MRCMAttributeRange` AS select `tbl`.* from `full_refset_MRCMAttributeRange` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_MRCMDomain`;
CREATE VIEW `delta_refset_MRCMDomain` AS select `tbl`.* from `full_refset_MRCMDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_concept`;
CREATE VIEW `delta_concept` AS select `tbl`.* from `full_concept` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_description`;
CREATE VIEW `delta_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_relationship`;
CREATE VIEW `delta_relationship` AS select `tbl`.* from `full_relationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_description`;
CREATE VIEW `delta_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta_refset_OWLExpression`;
CREATE VIEW `delta_refset_OWLExpression` AS select `tbl`.* from `full_refset_OWLExpression` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 0 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


-- VIEW SNAP ALT --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW SNAP ALT";


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_Simple`;
CREATE VIEW `snap1_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_Association`;
CREATE VIEW `snap1_refset_Association` AS select * from `full_refset_Association` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Association` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_AttributeValue`;
CREATE VIEW `snap1_refset_AttributeValue` AS select * from `full_refset_AttributeValue` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_AttributeValue` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_Language`;
CREATE VIEW `snap1_refset_Language` AS select * from `full_refset_Language` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Language` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_ExtendedMap`;
CREATE VIEW `snap1_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_SimpleMap`;
CREATE VIEW `snap1_refset_SimpleMap` AS select * from `full_refset_SimpleMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_SimpleMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_MRCMModuleScope`;
CREATE VIEW `snap1_refset_MRCMModuleScope` AS select * from `full_refset_MRCMModuleScope` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMModuleScope` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_RefsetDescriptor`;
CREATE VIEW `snap1_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_DescriptionType`;
CREATE VIEW `snap1_refset_DescriptionType` AS select * from `full_refset_DescriptionType` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_DescriptionType` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_MRCMAttributeDomain`;
CREATE VIEW `snap1_refset_MRCMAttributeDomain` AS select * from `full_refset_MRCMAttributeDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_ModuleDependency`;
CREATE VIEW `snap1_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_MRCMAttributeRange`;
CREATE VIEW `snap1_refset_MRCMAttributeRange` AS select * from `full_refset_MRCMAttributeRange` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeRange` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_MRCMDomain`;
CREATE VIEW `snap1_refset_MRCMDomain` AS select * from `full_refset_MRCMDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_concept`;
CREATE VIEW `snap1_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_description`;
CREATE VIEW `snap1_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_relationship`;
CREATE VIEW `snap1_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_description`;
CREATE VIEW `snap1_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap1_refset_OWLExpression`;
CREATE VIEW `snap1_refset_OWLExpression` AS select * from `full_refset_OWLExpression` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_OWLExpression` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 1) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


-- VIEW DELTA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW DELTA";


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_Simple`;
CREATE VIEW `delta1_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_Association`;
CREATE VIEW `delta1_refset_Association` AS select `tbl`.* from `full_refset_Association` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_AttributeValue`;
CREATE VIEW `delta1_refset_AttributeValue` AS select `tbl`.* from `full_refset_AttributeValue` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_Language`;
CREATE VIEW `delta1_refset_Language` AS select `tbl`.* from `full_refset_Language` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_ExtendedMap`;
CREATE VIEW `delta1_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_SimpleMap`;
CREATE VIEW `delta1_refset_SimpleMap` AS select `tbl`.* from `full_refset_SimpleMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_MRCMModuleScope`;
CREATE VIEW `delta1_refset_MRCMModuleScope` AS select `tbl`.* from `full_refset_MRCMModuleScope` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_RefsetDescriptor`;
CREATE VIEW `delta1_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_DescriptionType`;
CREATE VIEW `delta1_refset_DescriptionType` AS select `tbl`.* from `full_refset_DescriptionType` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_MRCMAttributeDomain`;
CREATE VIEW `delta1_refset_MRCMAttributeDomain` AS select `tbl`.* from `full_refset_MRCMAttributeDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_ModuleDependency`;
CREATE VIEW `delta1_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_MRCMAttributeRange`;
CREATE VIEW `delta1_refset_MRCMAttributeRange` AS select `tbl`.* from `full_refset_MRCMAttributeRange` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_MRCMDomain`;
CREATE VIEW `delta1_refset_MRCMDomain` AS select `tbl`.* from `full_refset_MRCMDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_concept`;
CREATE VIEW `delta1_concept` AS select `tbl`.* from `full_concept` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_description`;
CREATE VIEW `delta1_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_relationship`;
CREATE VIEW `delta1_relationship` AS select `tbl`.* from `full_relationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_description`;
CREATE VIEW `delta1_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta1_refset_OWLExpression`;
CREATE VIEW `delta1_refset_OWLExpression` AS select `tbl`.* from `full_refset_OWLExpression` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 1 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


-- VIEW SNAP ALT --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW SNAP ALT";


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_Simple`;
CREATE VIEW `snap2_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_Association`;
CREATE VIEW `snap2_refset_Association` AS select * from `full_refset_Association` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Association` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_AttributeValue`;
CREATE VIEW `snap2_refset_AttributeValue` AS select * from `full_refset_AttributeValue` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_AttributeValue` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_Language`;
CREATE VIEW `snap2_refset_Language` AS select * from `full_refset_Language` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Language` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_ExtendedMap`;
CREATE VIEW `snap2_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_SimpleMap`;
CREATE VIEW `snap2_refset_SimpleMap` AS select * from `full_refset_SimpleMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_SimpleMap` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_MRCMModuleScope`;
CREATE VIEW `snap2_refset_MRCMModuleScope` AS select * from `full_refset_MRCMModuleScope` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMModuleScope` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_RefsetDescriptor`;
CREATE VIEW `snap2_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_DescriptionType`;
CREATE VIEW `snap2_refset_DescriptionType` AS select * from `full_refset_DescriptionType` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_DescriptionType` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_MRCMAttributeDomain`;
CREATE VIEW `snap2_refset_MRCMAttributeDomain` AS select * from `full_refset_MRCMAttributeDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_ModuleDependency`;
CREATE VIEW `snap2_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_MRCMAttributeRange`;
CREATE VIEW `snap2_refset_MRCMAttributeRange` AS select * from `full_refset_MRCMAttributeRange` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeRange` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_MRCMDomain`;
CREATE VIEW `snap2_refset_MRCMDomain` AS select * from `full_refset_MRCMDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMDomain` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_concept`;
CREATE VIEW `snap2_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_description`;
CREATE VIEW `snap2_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_relationship`;
CREATE VIEW `snap2_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_description`;
CREATE VIEW `snap2_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


DELIMITER ;

DROP VIEW IF EXISTS `snap2_refset_OWLExpression`;
CREATE VIEW `snap2_refset_OWLExpression` AS select * from `full_refset_OWLExpression` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_OWLExpression` `sub` join `config_settings` `cfg`) where ((`sub`.`id` = `tbl`.`id`) and (`cfg`.`id` = 2) and (`sub`.`effectiveTime` <= `cfg`.`snapshotTime`))));


-- VIEW DELTA --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"VIEW DELTA";


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_Simple`;
CREATE VIEW `delta2_refset_Simple` AS select `tbl`.* from `full_refset_Simple` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_Association`;
CREATE VIEW `delta2_refset_Association` AS select `tbl`.* from `full_refset_Association` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_AttributeValue`;
CREATE VIEW `delta2_refset_AttributeValue` AS select `tbl`.* from `full_refset_AttributeValue` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_Language`;
CREATE VIEW `delta2_refset_Language` AS select `tbl`.* from `full_refset_Language` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_ExtendedMap`;
CREATE VIEW `delta2_refset_ExtendedMap` AS select `tbl`.* from `full_refset_ExtendedMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_SimpleMap`;
CREATE VIEW `delta2_refset_SimpleMap` AS select `tbl`.* from `full_refset_SimpleMap` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_MRCMModuleScope`;
CREATE VIEW `delta2_refset_MRCMModuleScope` AS select `tbl`.* from `full_refset_MRCMModuleScope` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_RefsetDescriptor`;
CREATE VIEW `delta2_refset_RefsetDescriptor` AS select `tbl`.* from `full_refset_RefsetDescriptor` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_DescriptionType`;
CREATE VIEW `delta2_refset_DescriptionType` AS select `tbl`.* from `full_refset_DescriptionType` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_MRCMAttributeDomain`;
CREATE VIEW `delta2_refset_MRCMAttributeDomain` AS select `tbl`.* from `full_refset_MRCMAttributeDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_ModuleDependency`;
CREATE VIEW `delta2_refset_ModuleDependency` AS select `tbl`.* from `full_refset_ModuleDependency` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_MRCMAttributeRange`;
CREATE VIEW `delta2_refset_MRCMAttributeRange` AS select `tbl`.* from `full_refset_MRCMAttributeRange` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_MRCMDomain`;
CREATE VIEW `delta2_refset_MRCMDomain` AS select `tbl`.* from `full_refset_MRCMDomain` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_concept`;
CREATE VIEW `delta2_concept` AS select `tbl`.* from `full_concept` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_description`;
CREATE VIEW `delta2_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_relationship`;
CREATE VIEW `delta2_relationship` AS select `tbl`.* from `full_relationship` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_description`;
CREATE VIEW `delta2_description` AS select `tbl`.* from `full_description` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


DELIMITER ;

DROP VIEW IF EXISTS `delta2_refset_OWLExpression`;
CREATE VIEW `delta2_refset_OWLExpression` AS select `tbl`.* from `full_refset_OWLExpression` `tbl`,`config_settings` `cfg` where `cfg`.`id` = 2 and `tbl`.`effectiveTime` <= `cfg`.`deltaEndTime` AND `tbl`.`effectiveTime`>`cfg`.`deltaStartTime`;


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

CREATE TABLE IF NOT EXISTS `config_resultsets` (
  `setId` varchar(12) NOT NULL,
  `conceptId` bigint(20) NOT NULL,
  PRIMARY KEY (`conceptId`,`setId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DELIMITER ;;
DROP PROCEDURE IF EXISTS `eclQuery`;;
CREATE PROCEDURE `eclQuery`(`p_ecl` text)
proc:BEGIN
	 CALL eclQuerySelect(`p_ecl`,'fsn');
END;;

DROP PROCEDURE IF EXISTS `eclQuerySelect`;;
CREATE PROCEDURE `eclQuerySelect`(`p_ecl` text,`style` text)
proc:BEGIN
	CALL eclQueryGetIds(`p_ecl`,'temp~get');
	CASE `style`
		WHEN 'exp' THEN
			SELECT CONCAT(`t`.`conceptId`,'|',`t`.`term`,'|') FROM `config_resultsets` `r` JOIN `snap_pref` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'expfsn' THEN
			SELECT CONCAT(`t`.`conceptId`,'|',`t`.`term`,'|') FROM `config_resultsets` `r` JOIN `snap_fsn` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'pref' THEN
			SELECT `t`.`conceptId`,`t`.`term` FROM `config_resultsets` `r` JOIN `snap_pref` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'fsn' THEN
			SELECT `t`.`conceptId`,`t`.`term` FROM `config_resultsets` `r` JOIN `snap_fsn` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'allsyn' THEN
			SELECT `t`.`conceptId`,`t`.`term` FROM `config_resultsets` `r` JOIN `snap_allsyn` `t` ON `t`.`conceptId`=`r`.`conceptId` WHERE `setId`='temp~get';
		WHEN 'count' THEN
			SELECT count(`conceptId`) FROM `config_resultsets` WHERE `setId`='temp~get';
		ELSE
			SELECT `conceptId` FROM `config_resultsets` WHERE `setId`='temp~get';
		END CASE;
END;;

DROP PROCEDURE IF EXISTS `eclQueryCount`;;
CREATE PROCEDURE `eclQueryCount`(`p_ecl` text,OUT `p_count` INT)
proc:BEGIN
	CALL eclQueryGetIds(`p_ecl`,'temp~count');
	SET `p_count`=(SELECT count(`conceptId`) From `config_resultsets` WHERE `setId`="temp~count");
END;;

DROP PROCEDURE IF EXISTS `eclQueryGetIds`;;
CREATE PROCEDURE `eclQueryGetIds`(`p_ecl` text, `p_setId` text)
--
-- Specify the ECL and a setId to be used store the resulting list of conceptIds.
-- This adds rows for matching items a two column table called config_resultsets
-- First column has the p_setId (allowing multiple sets to be saved with different keys)
-- Second column is the conceptId of a matching concept.
-- The data is retained in config_resultsets for use outside the procedure.
-- E.g. SELECT conceptId FROM config_resultsets WHERE setId="someset"
-- Length of setId is limited to 12 characters (after removing and prefixing symbols +,-,?,!)
-- Added feature is that starting the key with (+) adds matches to the set, minus (-) removes matches from the table.
-- Also a question mark or exclamation mark (? or !) before the key outputs diagnostics on the constraint
-- With no specified set the procedure will output the id and preferred term (in this case the result is not saved)
--
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
	DECLARE `v_valTestIn` char(6) DEFAULT 'IN';
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
	DECLARE `curRefine` CURSOR FOR SELECT `id`,`testNum`, `attId`,`attSymbol`,`valId`,`valSymbol`,`valTestIn` FROM `tmpEcl` WHERE `clauseNum`=`v_clauseNum` ORDER BY `testNum`;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET `done` := TRUE;
	-- SELECT CONCAT("MODE: ",`p_mode`);
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
		`valTestIn` CHAR(6) NOT NULL DEFAULT 'IN',
		`count` BIGINT NOT NULL DEFAULT 0,
		PRIMARY KEY (`id`));

	DROP TABLE IF EXISTS `tmpSourceIds`;
	DROP TABLE IF EXISTS `tmpIds`;
	CREATE TEMPORARY TABLE `tmpIds` (
			`id` bigint NOT NULL DEFAULT '0',
			PRIMARY KEY (`id`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

	DROP TABLE IF EXISTS `ResultTable`;

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
			INSERT INTO `tmpEcl` (`clauseNum`,`clauseRule`,`testNum`,`attId`,`attSymbol`,`valId`,`valSymbol`,`valTestIn`) values (`v_clauseNum`,`v_clauseRule`,`v_testNum`,0,'',`v_valId`,`v_valSymbol`,0);
			
			IF `v_refine`!='' THEN
					-- to simplify iteration add a comma before the refinement (this allows simple regexp pattern iteration)
					SET `v_refine`=CONCAT(',',`v_refine`);
					getRefine: LOOP
							-- Iterate through the refinement constraints spliting at the commas
							SET `v_item`=regexp_substr(`v_refine`,',[^,]+',1,`v_testNum`);
							SET `v_testNum`=`v_testNum`+1;
							IF ISNULL(`v_item`) OR `v_testNum`>20 THEN
									-- exit here when no more refinements (or after a maximum number of iterations as an error catcher)
									LEAVE getRefine;
							END IF;
							SET `v_item`=mid(`v_item`,2);
							-- SELECT `v_testNum`,`v_item`;
							SET `v_attrib`=substring_index(`v_item`,'=',1);
							-- Check for negated attribute value != (so ! as last char of v_attrib)
							SET `v_valTestIn`=IF(`v_attrib` regexp '!$',"NOT IN","IN");
							SET `v_value`=substring_index(`v_item`,'=',-1);
							-- SELECT `v_attrib`,`v_value`;
							SET `v_valSymbol`=IFNULL(regexp_substr(`v_value`,'(\\*|\\^|<<?)'),'=');
							SET `v_valId`=IFNULL(regexp_substr(`v_value`,'[1-9][0-9]{5,17}'),0);
							SET `v_attSymbol`=IFNULL(regexp_substr(`v_attrib`,'(\\*\\^|<<?)'),'=');
							SET `v_attId`=IFNULL(regexp_substr(`v_attrib`,'[1-9][0-9]{5,17}'),0);
							-- SELECT `v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`;
							INSERT INTO `tmpEcl` (`clauseNum`,`testNum`,`clauseRule`,`attId`,`attSymbol`,`valId`,`valSymbol`,`valTestIn`) values (`v_clauseNum`,`v_testNum`,`v_clauseRule`,`v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`,`v_valTestIn`);
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
		SET `v_ClauseTable`=IF(`v_clauseNum`=1,'ResultTable','tmpClauseIds');
		SET `v_inSource`='';
		OPEN `curRefine`;
		refineLoop: LOOP
			FETCH `curRefine` INTO `v_id`,`v_testNum`,`v_attId`,`v_attSymbol`,`v_valId`,`v_valSymbol`,`v_valTestIn`;
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
									IF `v_valTestIn`='IN' THEN
										SET @insertIds=CONCAT(@insertIds,' AND `destinationId`=',`v_valId`);
									ELSE
										SET @insertIds=CONCAT(@insertIds,' AND `destinationId`!=',`v_valId`);
									END IF;
							WHEN '<' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `subtypeId` FROM `snap_transclose` WHERE `supertypeId`=',`v_valId`,')');
							WHEN '<<' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `subtypeId` FROM `snap_transclose` WHERE (`supertypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005)))');
							WHEN '<!' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `id` FROM `snap_rel_child_fsn` WHERE `conceptId`=',`v_valId`,')');
							WHEN '>' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `supertypeId` FROM `snap_transclose` WHERE `subtypeId`=',`v_valId`,')');
							WHEN '>>' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `supertypeId` FROM `snap_transclose` WHERE (`subtypeId`=',`v_valId`,' or (`subtypeId`=',`v_valId`,' and `supertypeId`=138875005)))');
							WHEN '>!' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `id` FROM `snap_rel_parent_fsn` WHERE `conceptId`=',`v_valId`,')');
							WHEN '^' THEN
									SET @insertIds=CONCAT(@insertIds,' AND `destinationId` ',`v_valTestIn`,' (SELECT `referencedComponentId` FROM `snap_refset_simple` WHERE `refsetId`=',`v_valId`,' AND `active`=1',')');
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

			-- v_inSource is for first loop then becomes v_targetTable from previous iteration
			SET `v_inSource`=CONCAT(' IN (SELECT `id` FROM ',`v_targetTable`,')');
		END LOOP refineLoop;
		IF `v_clauseNum`>1 THEN
			CASE `v_clauseRule`
				WHEN 'o' THEN -- OR
					INSERT IGNORE INTO `ResultTable` (`id`) SELECT `id` FROM `tmpClauseIds`;
				WHEN 'a' THEN -- AND
					ALTER TABLE `ResultTable` RENAME TO  `tmpSourceIds` ;
					CREATE TABLE `ResultTable` LIKE `tmpIds`;
					INSERT IGNORE INTO `ResultTable` (`id`) SELECT `c`.`id` FROM `tmpClauseIds` `c` JOIN `tmpSourceIds` `s` ON `s`.`id`=`c`.`id` ;
					DROP TABLE `tmpSourceIds`;
				WHEN 'm' THEN -- MINUS
					ALTER TABLE `ResultTable` RENAME TO  `tmpSourceIds` ;
					CREATE TABLE `ResultTable` LIKE `tmpIds`;
					INSERT IGNORE INTO `ResultTable` (`id`) SELECT `s`.`id` FROM `tmpSourceIds` `s` LEFT OUTER JOIN `tmpClauseIds` `c` ON `s`.`id`=`c`.`id` 
				WHERE ISNULL(`c`.`id`);
					DROP TABLE `tmpSourceIds`;
				ELSE
					SELECT CONCAT("ERR: Invalid Clause Rule: ",`v_clauseRule`);
					LEAVE proc;
			END CASE;
		END IF;
	END LOOP clauseLoop;
	SET SQL_SAFE_UPDATES=0;
	IF LEFT(`p_setId`,1)='!' OR LEFT(`p_setId`,1)='?' THEN 
		-- Diagnostics
		SELECT * FROM `tmpEcl`;
		SET `p_setId`=MID(`p_setId`,2);
	END IF;
	IF LEFT(`p_setId`,1)="-" THEN
		SET `p_setId`=MID(`p_setId`,2);
		IF LENGTH(`p_setId`)>0 THEN
			DELETE FROM `config_resultsets` WHERE `setId`=`p_setId` AND `conceptId` IN (SELECT `id` FROM `ResultTable`);
		END IF;
	ELSEIF LEFT(`p_setId`,1)="+" THEN
		SET `p_setId`=MID(`p_setId`,2);
		IF LENGTH(`p_setId`)>0 THEN
			INSERT IGNORE INTO `config_resultsets` (`setId`,`conceptId`) SELECT `p_setId`,`id` FROM `ResultTable`;
		END IF;
	ELSE
		IF `p_setId`="" THEN 
			SET `p_setId`='temp';
		END IF;
		DELETE FROM `config_resultsets` WHERE `setId`=`p_setId`;
		INSERT IGNORE INTO `config_resultsets` (`setId`,`conceptId`) SELECT `p_setId`,`id` FROM `ResultTable`;
	END IF;
	SET SQL_SAFE_UPDATES=1;
	DROP TABLE IF EXISTS `tmpSourceIds`;
	DROP TABLE IF EXISTS `tmpIds`;
	DROP TABLE IF EXISTS `ResultTable`;
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

DELIMITER ;;
DROP FUNCTION IF EXISTS `getMrcmRefsetId`;;
CREATE FUNCTION `getMrcmRefsetId`(`p_moduleId` BIGINT,`p_refsetType` TEXT) RETURNS BIGINT
BEGIN

-- Return refsetId of a specified type MRCM refset for a specified module
-- First parameter is a module Id 
-- Second parameter is string representing the MRCM set type:
-- Either "d" or "mrcmdomain" returns the id of the MRCM Domain Refset
-- Either "a" or "mrcmattributedomain" returns the id of the MRCM Attribute Domain Refset
-- Either "r" or "mrcmattributerange" returns the id of the MRCM Attribute Range Refset

	DECLARE `v_refsetType` TEXT;
	CASE LOWER(LEFT(`p_refsetType`,1))
		WHEN 'd' THEN
			SET `v_refsetType`='mrcmdomain';
			WHEN 'a' THEN
			SET `v_refsetType`='mrcmattributedomain';
			WHEN 'r' THEN
			SET `v_refsetType`='mrcmattributerange';
		ELSE
			SET `v_refsetType`=LOWER(`p_refsetType`);
	END CASE;
	RETURN (SELECT `mrcmRuleRefsetId` 
		FROM `snap_refset_mrcmmodulescope` `m`
			JOIN `config_refsets` `r` ON `r`.`refsetId`=`m`.`mrcmRuleRefsetId`
			WHERE `active`=1 AND `m`.`refsetId`=723563008
			AND `r`.`refsetType`=`v_refsetType`
			AND referencedComponentId=`p_moduleId`);
END;;
DELIMITER ;

-- END EXTRAS --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"END EXTRAS";


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


-- ===========================================
-- SNOMED CT MySQL Processing Completed (DB=$DBNAME)
-- ===========================================

DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"SNOMED CT MySQL Processing Completed (DB=$DBNAME)";

