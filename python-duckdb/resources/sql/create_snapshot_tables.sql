/* create the Snapshot S-CT data tables */
drop table if exists concept_s;
create table concept_s(
    id varchar(18) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    definitionstatusid varchar(18) not null
);
drop table if exists description_s;
create table description_s(
    id varchar(18) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    conceptid varchar(18) not null,
    languagecode varchar(2) not null,
    typeid varchar(18) not null,
    term varchar(4096) not null,
    casesignificanceid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (conceptid) references concept_s (id),
    foreign key (typeid) references concept_s (id),
    foreign key (casesignificanceid) references concept_s (id)
);
drop table if exists textdefinition_s;
create table textdefinition_s(
    id varchar(18) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    conceptid varchar(18) not null,
    languagecode varchar(2) not null,
    typeid varchar(18) not null,
    term varchar(4096) not null,
    casesignificanceid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (conceptid) references concept_s (id),
    foreign key (typeid) references concept_s (id),
    foreign key (casesignificanceid) references concept_s (id)
);
drop table if exists relationship_s;
create table relationship_s(
    id varchar(18) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    destinationid varchar(18) not null,
    relationshipgroup int not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (sourceid) references concept_s (id),
    foreign key (destinationid) references concept_s (id),
    foreign key (typeid) references concept_s (id),
    foreign key (characteristictypeid) references concept_s (id),
    foreign key (modifierid) references concept_s (id)
);
drop table if exists stated_relationship_s;
create table stated_relationship_s(
    id varchar(18) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    destinationid varchar(18) not null,
    relationshipgroup int not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (sourceid) references concept_s (id),
    foreign key (destinationid) references concept_s (id),
    foreign key (typeid) references concept_s (id),
    foreign key (characteristictypeid) references concept_s (id),
    foreign key (modifierid) references concept_s (id)
);
drop table if exists relationship_concrete_values_s;
create table relationship_concrete_values_s(
    id varchar(18) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    value varchar(4096) not null,
    relationshipgroup int not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (sourceid) references concept_s (id),
    foreign key (typeid) references concept_s (id),
    foreign key (characteristictypeid) references concept_s (id),
    foreign key (modifierid) references concept_s (id)
);
drop table if exists langrefset_s;
create table langrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    acceptabilityid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (acceptabilityid) references concept_s (id)
);
drop table if exists associationrefset_s;
create table associationrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    targetcomponentid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    -- foreign key (targetcomponentid) references concept_s (id)
    -- TODO FK can refer to either concept or description IDs
);
drop table if exists attributevaluerefset_s;
create table attributevaluerefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    valueid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (valueid) references concept_s (id)
);
drop table if exists simplemaprefset_s;
create table simplemaprefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    maptarget varchar(32) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists simplerefset_s;
create table simplerefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists complexmaprefset_s;
create table complexmaprefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapGroup smallint not null,
    mapPriority smallint not null,
    mapRule varchar(300),
    mapAdvice varchar(500),
    mapTarget varchar(10),
    correlationid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (correlationid) references concept_s (id)
);
drop table if exists extendedmaprefset_s;
create table extendedmaprefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapGroup smallint not null,
    mapPriority smallint not null,
    mapRule varchar(300),
    mapAdvice varchar(500),
    mapTarget varchar(10),
    correlationid varchar(18) not null,
    mapCategoryid varchar(18),
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (correlationid) references concept_s (id),
    foreign key (mapCategoryid) references concept_s (id)
);
drop table if exists expressionassociationrefset_s;
create table expressionassociationrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(20) not null,
    expression varchar(500) not null,
    definitionStatusid varchar(18) not null,
    correlationid varchar(18) not null,
    contentOriginid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (definitionStatusid) references concept_s (id),
    foreign key (correlationid) references concept_s (id),
    foreign key (contentOriginid) references concept_s (id)
);
drop table if exists mapcorrelationoriginrefset_s;
create table mapcorrelationoriginrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(20) not null,
    attributeid varchar(18) not null,
    correlationid varchar(18) not null,
    contentOriginid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (attributeid) references concept_s (id),
    foreign key (correlationid) references concept_s (id),
    foreign key (contentOriginid) references concept_s (id)
);
drop table if exists moduledependencyrefset_s;
create table moduledependencyrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    sourceeffectivetime date not null,
    targeteffectivetime date not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists refsetdescriptor_s;
create table refsetdescriptor_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    attributedescription bigint not null,
    attributetype bigint not null,
    attributeorder int not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists owlexpressionrefset_s;
create table owlexpressionrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    owlexpression text not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists mrcmattributedomainrefset_s;
create table mrcmattributedomainrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    domainid varchar(18) not null,
    grouped tinyint not null,
    attributecardinality char(4) not null,
    attributeingroupcardinality char(4) not null,
    rulestrengthid varchar(18) not null,
    contenttypeid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (domainid) references concept_s (id),
    foreign key (rulestrengthid) references concept_s (id),
    foreign key (contenttypeid) references concept_s (id)
);
drop table if exists mrcmmodulescoperefset_s;
create table mrcmmodulescoperefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mrcmRuleRefsetid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (mrcmRuleRefsetid) references concept_s (id)
);
drop table if exists mrcmattributerangerefset_s;
create table mrcmattributerangerefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    rangeConstraint text not null,
    attributeRule text not null,
    ruleStrengthid varchar(18) not null,
    contentTypeid varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (ruleStrengthid) references concept_s (id),
    foreign key (contentTypeid) references concept_s (id)
);
drop table if exists mrcmdomainrefset_s;
create table mrcmdomainrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    domainconstraint varchar(1024) not null,
    parentdomain varchar(1024),
    proximalPrimitiveConstraint text not null,
    proximalPrimitiveRefinement text,
    domainTemplateForPrecoordination text not null,
    domainTemplateForPostcoordination text not null,
    guideurl varchar(255) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists descriptiontyperefset_s;
create table descriptiontyperefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    descriptionformat bigint not null,
    descriptionlength int not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists memberannotationstringvaluerefset_s;
create table memberannotationstringvaluerefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    referencedmemberid varchar(36) not null,
    languagedialectcode varchar(2) not null,
    typeid varchar(18) not null,
    value text not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id)
);
drop table if exists componentannotationstringvaluerefset_s;
create table componentannotationstringvaluerefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    languagedialectcode varchar(2) not null,
    typeid varchar(18) not null,
    value text not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (typeid) references concept_s (id)
);
drop table if exists identifier_s;
create table identifier_s(
    alternateidentifier text not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    identifierschemeid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    primary key (alternateidentifier, identifierschemeid),
    foreign key (moduleid) references concept_s (id),
    foreign key (identifierschemeid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
);
-- AU-specific
drop table if exists attributevaluemaprefset_s;
create table attributevaluemaprefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapType varchar(18) not null,
    targetSnomedCtSubstance varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (mapType) references concept_s (id),
    foreign key (targetSnomedCtSubstance) references concept_s (id),
);
-- AU-specific
drop table if exists extendedassociationrefset_s;
create table extendedassociationrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    targetAdministeredForm varchar(18) not null,
    targetManufacturedForm varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (targetAdministeredForm) references concept_s (id),
    foreign key (targetManufacturedForm) references concept_s (id),
);
-- NL-specific
drop table if exists correlatedmaptypereferencesetrefset_s;
create table correlatedmaptypereferencesetrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(32),
    correlationId varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (correlationId) references concept_s (id),
);
-- NL-specific
drop table if exists correlatedextendedmaptypereferencesetrefset_s;
create table correlatedextendedmaptypereferencesetrefset_s(
    id varchar(36) not null primary key,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(32),
    snomedCtSourceCodeToTargetMapCodeCorrelationValue varchar(18) not null,
    mapTargetQualifier varchar(18) not null,
    foreign key (moduleid) references concept_s (id),
    foreign key (refsetid) references concept_s (id),
    foreign key (referencedcomponentid) references concept_s (id),
    foreign key (
        snomedCtSourceCodeToTargetMapCodeCorrelationValue
    ) references concept_s (id),
    foreign key (mapTargetQualifier) references concept_s (id),
);