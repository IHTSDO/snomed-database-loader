-- SNOMED SQL QUERY EXAMPLE : COUNT THE ROWS IN ALL TABLE - FULL AND SNAPSHOT VIEWS

SELECT `data`.`Table` `Table`,MAX(`data`.`Full_Row_Count`) `Full_Row_Count`, MAX(`data`.`Snapshot_Row_Count`) `Snapshot_Row_Count`
FROM
(SELECT 'Concept' `Table`,count(`id`) `Full_Row_Count`,0 `Snapshot_Row_Count` FROM `sct_concept`
UNION
SELECT 'Description',count(`id`),0 FROM `sct_description`
UNION
SELECT 'Relationship',count(`id`),0 FROM `sct_relationship`
UNION
SELECT 'Association Refsets',count(`id`),0 FROM `sct_refset_Association`
UNION
SELECT 'AttributeValue Refsets',count(`id`),0 FROM `sct_refset_AttributeValue`
UNION
SELECT 'DescriptionType Refsets',count(`id`),0 FROM `sct_refset_DescriptionType`
UNION
SELECT 'ExtendedMap Refsets',count(`id`),0 FROM `sct_refset_ExtendedMap`
UNION
SELECT 'Language Refsets',count(`id`),0 FROM `sct_refset_Language`
UNION
SELECT 'MRCMAttributeDomain Refsets',count(`id`),0 FROM `sct_refset_MRCMAttributeDomain`
UNION
SELECT 'MRCMAttributeRange Refsets',count(`id`),0 FROM `sct_refset_MRCMAttributeRange`
UNION
SELECT 'MRCMDomain Refsets',count(`id`),0 FROM `sct_refset_MRCMDomain`
UNION
SELECT 'MRCMModuleScope Refsets',count(`id`),0 FROM `sct_refset_MRCMModuleScope`
UNION
SELECT 'ModuleDependency Refsets',count(`id`),0 FROM `sct_refset_ModuleDependency`
UNION
SELECT 'OWLExpression Refsets',count(`id`),0 FROM `sct_refset_OWLExpression`
UNION
SELECT 'RefsetDescriptor Refsets',count(`id`),0 FROM `sct_refset_RefsetDescriptor`
UNION
SELECT 'Simple Refsets',count(`id`),0 FROM `sct_refset_Simple`
UNION
SELECT 'SimpleMap Refsets',count(`id`),0 FROM `sct_refset_SimpleMap`
UNION
SELECT 'Concept',0,count(`id`) FROM `soa_concept`
UNION
SELECT 'Description',0,count(`id`) FROM `soa_description`
UNION
SELECT 'Relationship',0,count(`id`) FROM `soa_relationship`
UNION
SELECT 'Association Refsets',0,count(`id`) FROM `soa_refset_Association`
UNION
SELECT 'AttributeValue Refsets',0,count(`id`) FROM `soa_refset_AttributeValue`
UNION
SELECT 'DescriptionType Refsets',0,count(`id`) FROM `soa_refset_DescriptionType`
UNION
SELECT 'ExtendedMap Refsets',0,count(`id`) FROM `soa_refset_ExtendedMap`
UNION
SELECT 'Language Refsets',0,count(`id`) FROM `soa_refset_Language`
UNION
SELECT 'MRCMAttributeDomain Refsets',0,count(`id`) FROM `soa_refset_MRCMAttributeDomain`
UNION
SELECT 'MRCMAttributeRange Refsets',0,count(`id`) FROM `soa_refset_MRCMAttributeRange`
UNION
SELECT 'MRCMDomain Refsets',0,count(`id`) FROM `soa_refset_MRCMDomain`
UNION
SELECT 'MRCMModuleScope Refsets',0,count(`id`) FROM `soa_refset_MRCMModuleScope`
UNION
SELECT 'ModuleDependency Refsets',0,count(`id`) FROM `soa_refset_ModuleDependency`
UNION
SELECT 'OWLExpression Refsets',0,count(`id`) FROM `soa_refset_OWLExpression`
UNION
SELECT 'RefsetDescriptor Refsets',0,count(`id`) FROM `soa_refset_RefsetDescriptor`
UNION
SELECT 'Simple Refsets',0,count(`id`) FROM `soa_refset_Simple`
UNION
SELECT 'SimpleMap Refsets',0,count(`id`) FROM `soa_refset_SimpleMap`
UNION
SELECT 'Transitive Closure',0,count(`subtypeid`) FROM `ss_transclose`
) `data`
GROUP BY `data`.`Table`
ORDER BY `data`.`Table`;