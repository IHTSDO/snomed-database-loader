-- Refset SELECT lines for tables matching:^sct_refset_(.*)$

-- sct_refset_Association
SELECT showUid(`id`) `{Association Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`targetComponentId`,`supersededTime` FROM `sct_refset_Association`
		LIMIT 50;


-- sct_refset_AttributeValue
SELECT showUid(`id`) `{AttributeValue Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`valueId`,`supersededTime` FROM `sct_refset_AttributeValue`
		LIMIT 50;


-- sct_refset_DescriptionType
SELECT showUid(`id`) `{DescriptionType Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`descriptionFormat`,`descriptionLength`,`supersededTime` FROM `sct_refset_DescriptionType`
		LIMIT 50;


-- sct_refset_ExtendedMap
SELECT showUid(`id`) `{ExtendedMap Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapGroup`,`mapPriority`,`mapRule`,`mapAdvice`,`mapTarget`,`correlationId`,`mapCategoryId`,`supersededTime` FROM `sct_refset_ExtendedMap`
		LIMIT 50;


-- sct_refset_Language
SELECT showUid(`id`) `{Language Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`acceptabilityId`,`supersededTime` FROM `sct_refset_Language`
		LIMIT 50;


-- sct_refset_MRCMAttributeDomain
SELECT showUid(`id`) `{MRCMAttributeDomain Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainId`,`grouped`,`attributeCardinality`,`attributeInGroupCardinality`,`ruleStrengthId`,`contentTypeId`,`supersededTime` FROM `sct_refset_MRCMAttributeDomain`
		LIMIT 50;


-- sct_refset_MRCMAttributeRange
SELECT showUid(`id`) `{MRCMAttributeRange Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`rangeConstraint`,`attributeRule`,`ruleStrengthId`,`contentTypeId`,`supersededTime` FROM `sct_refset_MRCMAttributeRange`
		LIMIT 50;


-- sct_refset_MRCMDomain
SELECT showUid(`id`) `{MRCMDomain Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`domainConstraint`,`parentDomain`,`proximalPrimitiveConstraint`,`proximalPrimitiveRefinement`,`domainTemplateForPrecoordination`,`domainTemplateForPostcoordination`,`guideURL`,`supersededTime` FROM `sct_refset_MRCMDomain`
		LIMIT 50;


-- sct_refset_MRCMModuleScope
SELECT showUid(`id`) `{MRCMModuleScope Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mrcmRuleRefsetId`,`supersededTime` FROM `sct_refset_MRCMModuleScope`
		LIMIT 50;


-- sct_refset_ModuleDependency
SELECT showUid(`id`) `{ModuleDependency Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`sourceEffectiveTime`,`targetEffectiveTime`,`supersededTime` FROM `sct_refset_ModuleDependency`
		LIMIT 50;


-- sct_refset_OWLExpression
SELECT showUid(`id`) `{OWLExpression Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`owlExpression`,`supersededTime` FROM `sct_refset_OWLExpression`
		LIMIT 50;


-- sct_refset_RefsetDescriptor
SELECT showUid(`id`) `{RefsetDescriptor Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`attributeDescription`,`attributeType`,`attributeOrder`,`supersededTime` FROM `sct_refset_RefsetDescriptor`
		LIMIT 50;


-- sct_refset_Simple
SELECT showUid(`id`) `{Simple Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`supersededTime` FROM `sct_refset_Simple`
		LIMIT 50;


-- sct_refset_SimpleMap
SELECT showUid(`id`) `{SimpleMap Refsets} id`, `effectiveTime`,`active`,`moduleId`,`refsetId`,`referencedComponentId`,`mapTarget`,`supersededTime` FROM `sct_refset_SimpleMap`
		LIMIT 50;

		