-- START VIEWS --

-- Create Unoptimized Views --
DELIMITER ;
USE `$DBNAME`;
SELECT Now() `--`,"Create Unoptimized Views";
USE `$DBNAME`;
-- VIEW SNAP CURRENT --
SELECT Now() '--','VIEW SNAP CURRENT' '--';
DROP VIEW IF EXISTS `snap0_refset_Simple`;
CREATE VIEW `snap0_refset_Simple` AS select * from `full_refset_Simple` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Simple` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_Association`;
CREATE VIEW `snap0_refset_Association` AS select * from `full_refset_Association` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Association` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_AttributeValue`;
CREATE VIEW `snap0_refset_AttributeValue` AS select * from `full_refset_AttributeValue` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_AttributeValue` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_Language`;
CREATE VIEW `snap0_refset_Language` AS select * from `full_refset_Language` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_Language` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_ExtendedMap`;
CREATE VIEW `snap0_refset_ExtendedMap` AS select * from `full_refset_ExtendedMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ExtendedMap` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_SimpleMap`;
CREATE VIEW `snap0_refset_SimpleMap` AS select * from `full_refset_SimpleMap` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_SimpleMap` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_MRCMModuleScope`;
CREATE VIEW `snap0_refset_MRCMModuleScope` AS select * from `full_refset_MRCMModuleScope` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMModuleScope` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_RefsetDescriptor`;
CREATE VIEW `snap0_refset_RefsetDescriptor` AS select * from `full_refset_RefsetDescriptor` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_RefsetDescriptor` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_DescriptionType`;
CREATE VIEW `snap0_refset_DescriptionType` AS select * from `full_refset_DescriptionType` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_DescriptionType` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_MRCMAttributeDomain`;
CREATE VIEW `snap0_refset_MRCMAttributeDomain` AS select * from `full_refset_MRCMAttributeDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeDomain` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_ModuleDependency`;
CREATE VIEW `snap0_refset_ModuleDependency` AS select * from `full_refset_ModuleDependency` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_ModuleDependency` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_MRCMAttributeRange`;
CREATE VIEW `snap0_refset_MRCMAttributeRange` AS select * from `full_refset_MRCMAttributeRange` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMAttributeRange` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_MRCMDomain`;
CREATE VIEW `snap0_refset_MRCMDomain` AS select * from `full_refset_MRCMDomain` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_MRCMDomain` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_concept`;
CREATE VIEW `snap0_concept` AS select * from `full_concept` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_concept` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_description`;
CREATE VIEW `snap0_description` AS select * from `full_description` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_description` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_relationship`;
CREATE VIEW `snap0_relationship` AS select * from `full_relationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_relationship` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_statedRelationship`;
CREATE VIEW `snap0_statedRelationship` AS select * from `full_statedRelationship` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_statedRelationship` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_textDefinition`;
CREATE VIEW `snap0_textDefinition` AS select * from `full_textDefinition` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_textDefinition` `sub`) where ((`sub`.`id` = `tbl`.`id`))));

DROP VIEW IF EXISTS `snap0_refset_OWLExpression`;
CREATE VIEW `snap0_refset_OWLExpression` AS select * from `full_refset_OWLExpression` `tbl` where (`tbl`.`effectiveTime` = (select max(`sub`.`effectiveTime`) from (`full_refset_OWLExpression` `sub`) where ((`sub`.`id` = `tbl`.`id`))));
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
--          See sct_shortcuts table (created and populated in this part of the script)
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

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `sct_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `sct_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' AND 'snap'='snap' THEN
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
    ELSEIF LEFT(`p_filter`,1)='<'  AND 'snap'='snap' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_syn` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_syn` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
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
--          See sct_shortcuts table (created and populated in this part of the script)
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

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `sct_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `sct_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' AND 'snap1'='snap' THEN
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
    ELSEIF LEFT(`p_filter`,1)='<'  AND 'snap1'='snap' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_syn` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_syn` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
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
--          See sct_shortcuts table (created and populated in this part of the script)
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

	IF `p_filter` regexp '^<[a-z]{2,5}' THEN
		SET @key=CONCAT(TRIM(MID(`p_filter`,2)),'%');
		SET @matches=(SELECT COUNT(`conceptId`) FROM `sct_shortcuts` WHERE `abbrev` like @key);
		IF @matches = 1 THEN
			SET `p_filter`=(SELECT CONCAT('<',`conceptId`) FROM `sct_shortcuts` WHERE `abbrev` like @key);
        END IF;
    END IF;

	IF `p_search`='' THEN
		IF p_filter=LEFT(`p_filter`,1)='<' AND 'snap2'='snap' THEN
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
    ELSEIF LEFT(`p_filter`,1)='<'  AND 'snap2'='snap' THEN
		IF `p_search` regexp '[+-]' THEN
			SELECT `conceptId`,`term` FROM `snap_syn` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
			AGAINST (`p_search` IN BOOLEAN MODE) AND `term` not regexp MID(`p_filter`,2)  ORDER BY length(`term`) LIMIT 200;
		ELSE
			SELECT `conceptId`,`term` FROM `snap_syn` `s` JOIN `snap_transclose` `t` ON `t`.`subtypeId`=`s`.`conceptId` WHERE `t`.`supertypeId`=SUBSTRING_INDEX(`p_filter`,'<',-1) AND MATCH (`term`)
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
CALL setLanguage(0,'en-US');
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
CALL setLanguage(1,'en-US');
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
CALL setLanguage(2,'en-US');
END;;
DELIMITER ;


-- Now Create and Populate Shortcuts Table
-- Useful for quick use of subsumption limits.
DROP TABLE IF EXISTS `sct_shortcuts`;
CREATE TABLE `sct_shortcuts` (
  `abbrev` varchar(5) NOT NULL,
  `conceptId` bigint(10) NOT NULL,
  PRIMARY KEY (`abbrev`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `sct_shortcuts` (`abbrev`,`conceptId`) 
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


