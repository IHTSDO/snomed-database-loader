/* create the Full S-CT data tables */
/* Change the table suffix for different release type. _f stands for full, _d stands for delta, _s stands for snapshot */
set schema 'snomedct';

/*create table concept_f*/
drop table if exists concept_f cascade;
create table concept_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  definitionstatusid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table description_f*/
drop table if exists description_f cascade;
create table description_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  conceptid varchar(18) not null,
  languagecode varchar(2) not null,
  typeid varchar(18) not null,
  term text not null,
  casesignificanceid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table textdefinition_f*/
drop table if exists textdefinition_f cascade;
create table textdefinition_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  conceptid varchar(18) not null,
  languagecode varchar(2) not null,
  typeid varchar(18) not null,
  term text not null,
  casesignificanceid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table relation_f*/
drop table if exists relationship_f cascade;
create table relationship_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  sourceid varchar(18) not null,
  destinationid varchar(18) not null,
  relationshipgroup varchar(18) not null,
  typeid varchar(18) not null,
  characteristictypeid varchar(18) not null,
  modifierid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table stated_relationship_f*/
drop table if exists stated_relationship_f cascade;
create table stated_relationship_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  sourceid varchar(18) not null,
  destinationid varchar(18) not null,
  relationshipgroup varchar(18) not null,
  typeid varchar(18) not null,
  characteristictypeid varchar(18) not null,
  modifierid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table langrefset_f*/
drop table if exists langrefset_f cascade;
create table langrefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  acceptabilityid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table associationrefset_f*/
drop table if exists associationrefset_f cascade;
create table associationrefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  targetcomponentid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table attributevaluerefset_f*/
drop table if exists attributevaluerefset_f cascade;
create table attributevaluerefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  valueid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);


/*create table simplerefset_f*/
drop table if exists simplerefset_f cascade;
create table simplerefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table simplemaprefset_f*/
drop table if exists simplemaprefset_f cascade;
create table simplemaprefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  maptarget text not null,
  PRIMARY KEY(id, effectivetime)
);

/*create table extendedmaprefset_f*/
drop table if exists extendedmaprefset_f cascade;
create table extendedmaprefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  mapGroup smallint not null,
  mapPriority smallint not null,
  mapRule text,
  mapAdvice text,
  mapTarget text,
  correlationId varchar(18),
  mapCategoryId varchar(18),
  PRIMARY KEY(id, effectivetime)
);

/*create table MRCMModuleScoperefset_f*/
DROP TABLE IF EXISTS MRCMModuleScoperefset_f CASCADE;
CREATE TABLE MRCMModuleScoperefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
	mrcmRuleRefsetId varchar(18) NOT NULL,
	PRIMARY KEY (id, effectiveTime)
);

/*create table RefsetDescriptorrefset_f*/
DROP TABLE IF EXISTS RefsetDescriptorrefset_f CASCADE;
CREATE TABLE RefsetDescriptorrefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
	attributeDescription varchar(18) NOT NULL,
	attributeType varchar(18) NOT NULL,
	attributeOrder INTEGER NOT NULL,
	PRIMARY KEY (id, effectiveTime)
);

/*create table DescriptionTyperefset_f*/
DROP TABLE IF EXISTS DescriptionTyperefset_f CASCADE;
CREATE TABLE DescriptionTyperefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
	descriptionFormat VARCHAR(18) NOT NULL,
	descriptionLength INTEGER NOT NULL,
	PRIMARY KEY (id, effectiveTime)
);


/*create table MRCMAttributeDomain_f*/
DROP TABLE IF EXISTS MRCMAttributeDomain_f CASCADE;
CREATE TABLE MRCMAttributeDomain_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
	domainId varchar(18) NOT NULL,
	grouped char(1) NOT NULL,
	attributeCardinality VARCHAR(12) NOT NULL,
	attributeInGroupCardinality VARCHAR(12) NOT NULL,
	ruleStrengthId varchar(18) NOT NULL,
	contentTypeId varchar(18) NOT NULL,
	PRIMARY KEY (id, effectiveTime)
);


/*create table OWLExpressionRefset_f*/
DROP TABLE IF EXISTS OWLExpressionRefset_f CASCADE;
CREATE TABLE OWLExpressionRefset_f(
  id uuid not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
	owlexpression TEXT NOT NULL,
	PRIMARY KEY (id, effectiveTime)
);