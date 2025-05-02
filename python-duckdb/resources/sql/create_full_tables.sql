/* create the Full SCT data tables */
drop table if exists concept_f;
create table concept_f(
    id varchar(18) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    definitionstatusid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists description_f;
create table description_f(
    id varchar(18) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    conceptid varchar(18) not null,
    languagecode varchar(2) not null,
    typeid varchar(18) not null,
    term varchar(4096) not null,
    casesignificanceid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists textdefinition_f;
create table textdefinition_f(
    id varchar(18) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    conceptid varchar(18) not null,
    languagecode varchar(2) not null,
    typeid varchar(18) not null,
    term varchar(4096) not null,
    casesignificanceid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists relationship_f;
create table relationship_f(
    id varchar(18) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    destinationid varchar(18) not null,
    relationshipgroup bigint not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists stated_relationship_f;
create table stated_relationship_f(
    id varchar(18) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    destinationid varchar(18) not null,
    relationshipgroup bigint not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists relationship_concrete_values_f;
create table relationship_concrete_values_f(
    id varchar(18) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    value varchar(4096) not null,
    relationshipgroup bigint not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists langrefset_f;
create table langrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    acceptabilityid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists associationrefset_f;
create table associationrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    targetcomponentid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists attributevaluerefset_f;
create table attributevaluerefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    valueid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists simplemaprefset_f;
create table simplemaprefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    maptarget varchar(32) not null,
    primary key (id, effectivetime)
);
drop table if exists simplerefset_f;
create table simplerefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists complexmaprefset_f;
create table complexmaprefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapGroup smallint not null,
    mapPriority smallint not null,
    mapRule varchar(300),
    mapAdvice varchar(500),
    mapTarget varchar(10),
    correlationid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists extendedmaprefset_f;
create table extendedmaprefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
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
    primary key (id, effectivetime)
);
drop table if exists expressionassociationrefset_f;
create table expressionassociationrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(20) not null,
    expression varchar(500) not null,
    definitionStatusid varchar(18) not null,
    correlationid varchar(18) not null,
    contentOriginid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists mapcorrelationoriginrefset_f;
create table mapcorrelationoriginrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(20) not null,
    attributeid varchar(18) not null,
    correlationid varchar(18) not null,
    contentOriginid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists moduledependencyrefset_f;
create table moduledependencyrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    sourceeffectivetime char(8) not null,
    targeteffectivetime char(8) not null,
    primary key (id, effectivetime)
);
drop table if exists refsetdescriptor_f;
create table refsetdescriptor_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    attributedescription bigint not null,
    attributetype bigint not null,
    attributeorder bigint not null,
    primary key (id, effectivetime)
);
drop table if exists owlexpressionrefset_f;
create table owlexpressionrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    owlexpression text not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmattributedomainrefset_f;
create table mrcmattributedomainrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    domainid varchar(18) not null,
    grouped char(1) not null,
    attributecardinality char(4) not null,
    attributeingroupcardinality char(4) not null,
    rulestrengthid varchar(18) not null,
    contenttypeid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmmodulescoperefset_f;
create table mrcmmodulescoperefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mrcmRuleRefsetid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmattributerangerefset_f;
create table mrcmattributerangerefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    rangeConstraint text not null,
    attributeRule text not null,
    ruleStrengthid varchar(18) not null,
    contentTypeid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmdomainrefset_f;
create table mrcmdomainrefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
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
    primary key (id, effectivetime)
);
drop table if exists descriptiontyperefset_f;
create table descriptiontyperefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    descriptionformat bigint not null,
    descriptionlength int not null,
    primary key (id, effectivetime)
);
drop table if exists memberannotationstringvaluerefset_f;
create table memberannotationstringvaluerefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    referencedmemberid varchar(36) not null,
    languagedialectcode varchar(2) not null,
    typeid varchar(18) not null,
    value text not null,
    primary key (id, effectivetime)
);
drop table if exists componentannotationstringvaluerefset_f;
create table componentannotationstringvaluerefset_f(
    id varchar(36) not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    languagedialectcode varchar(2),
    -- TODO: not null constraint removed
    typeid varchar(18) not null,
    value text not null,
    primary key (id, effectivetime)
);
drop table if exists identifier_f;
create table identifier_f(
    alternateidentifier text not null,
    effectivetime char(8) not null,
    active char(1) not null,
    moduleid varchar(18) not null,
    identifierschemeid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    primary key (
        alternateidentifier,
        effectivetime,
        identifierschemeid
    )
);