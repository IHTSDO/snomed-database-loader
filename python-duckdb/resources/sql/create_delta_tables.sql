/* create the Delta S-CT data tables */
drop table if exists concept_d;
create table concept_d(
    id varchar(18) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    definitionstatusid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists description_d;
create table description_d(
    id varchar(18) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    conceptid varchar(18) not null,
    languagecode varchar(2) not null,
    typeid varchar(18) not null,
    term varchar(4096) not null,
    casesignificanceid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists textdefinition_d;
create table textdefinition_d(
    id varchar(18) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    conceptid varchar(18) not null,
    languagecode varchar(2) not null,
    typeid varchar(18) not null,
    term varchar(4096) not null,
    casesignificanceid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists relationship_d;
create table relationship_d(
    id varchar(18) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    destinationid varchar(18) not null,
    relationshipgroup int not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists stated_relationship_d;
create table stated_relationship_d(
    id varchar(18) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    destinationid varchar(18) not null,
    relationshipgroup int not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists relationship_concrete_values_d;
create table relationship_concrete_values_d(
    id varchar(18) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    sourceid varchar(18) not null,
    value varchar(4096) not null,
    relationshipgroup int not null,
    typeid varchar(18) not null,
    characteristictypeid varchar(18) not null,
    modifierid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists langrefset_d;
create table langrefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    acceptabilityid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists associationrefset_d;
create table associationrefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    targetcomponentid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists attributevaluerefset_d;
create table attributevaluerefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    valueid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists simplemaprefset_d;
create table simplemaprefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    maptarget varchar(32) not null,
    primary key (id, effectivetime)
);
drop table if exists simplerefset_d;
create table simplerefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists complexmaprefset_d;
create table complexmaprefset_d(
    id varchar(36) not null unique,
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
    primary key (id, effectivetime)
);
drop table if exists extendedmaprefset_d;
create table extendedmaprefset_d(
    id varchar(36) not null unique,
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
    primary key (id, effectivetime)
);
drop table if exists expressionassociationrefset_d;
create table expressionassociationrefset_d(
    id varchar(36) not null unique,
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
    primary key (id, effectivetime)
);
drop table if exists mapcorrelationoriginrefset_d;
create table mapcorrelationoriginrefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mapTarget varchar(20) not null,
    attributeid varchar(18) not null,
    correlationid varchar(18) not null,
    contentOriginid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists moduledependencyrefset_d;
create table moduledependencyrefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    sourceeffectivetime date not null,
    targeteffectivetime date not null,
    primary key (id, effectivetime)
);
drop table if exists refsetdescriptor_d;
create table refsetdescriptor_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    attributedescription bigint not null,
    attributetype bigint not null,
    attributeorder int not null,
    primary key (id, effectivetime)
);
drop table if exists owlexpressionrefset_d;
create table owlexpressionrefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    owlexpression text not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmattributedomainrefset_d;
create table mrcmattributedomainrefset_d(
    id varchar(36) not null unique,
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
    primary key (id, effectivetime)
);
drop table if exists mrcmmodulescoperefset_d;
create table mrcmmodulescoperefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    mrcmRuleRefsetid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmattributerangerefset_d;
create table mrcmattributerangerefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    rangeConstraint text not null,
    attributeRule text not null,
    ruleStrengthid varchar(18) not null,
    contentTypeid varchar(18) not null,
    primary key (id, effectivetime)
);
drop table if exists mrcmdomainrefset_d;
create table mrcmdomainrefset_d(
    id varchar(36) not null unique,
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
    primary key (id, effectivetime)
);
drop table if exists descriptiontyperefset_d;
create table descriptiontyperefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    descriptionformat bigint not null,
    descriptionlength int not null,
    primary key (id, effectivetime)
);
drop table if exists memberannotationstringvaluerefset_d;
create table memberannotationstringvaluerefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    referencedmemberid varchar(36) not null,
    languagedialectcode varchar(2) not null,
    typeid varchar(18) not null,
    value text not null,
    primary key (id, effectivetime)
);
drop table if exists componentannotationstringvaluerefset_d;
create table componentannotationstringvaluerefset_d(
    id varchar(36) not null unique,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    refsetid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    languagedialectcode varchar(2) not null,
    typeid varchar(18) not null,
    value text not null,
    primary key (id, effectivetime)
);
drop table if exists identifier_d;
create table identifier_d(
    alternateidentifier text not null,
    effectivetime date not null,
    active tinyint not null,
    moduleid varchar(18) not null,
    identifierschemeid varchar(18) not null,
    referencedcomponentid varchar(18) not null,
    primary key (alternateidentifier, effectivetime, identifierschemeid)
);