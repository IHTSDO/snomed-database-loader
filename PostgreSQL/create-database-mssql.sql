/* create the Full S-CT data tables */


IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_concept_f') DROP TABLE curr_concept_f;
create table curr_concept_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  definitionstatusid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_description_f') DROP TABLE curr_description_f;
create table curr_description_f(
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

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_textdefinition_f') DROP TABLE curr_textdefinition_f;
create table curr_textdefinition_f(
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

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_relationship_f') DROP TABLE curr_relationship_f;
create table curr_relationship_f(
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

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_stated_relationship_f') DROP TABLE curr_stated_relationship_f;
create table curr_stated_relationship_f(
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

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_langrefset_f') DROP TABLE curr_langrefset_f;
create table curr_langrefset_f(
  id uniqueidentifier  not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  acceptabilityid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_associationrefset_f') DROP TABLE curr_associationrefset_f;
create table curr_associationrefset_f(
  id uniqueidentifier not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  targetcomponentid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_attributevaluerefset_f') DROP TABLE curr_attributevaluerefset_f;
create table curr_attributevaluerefset_f(
  id uniqueidentifier not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  valueid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_simplerefset_f') DROP TABLE curr_simplerefset_f;
create table curr_simplerefset_f(
  id uniqueidentifier not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  PRIMARY KEY(id, effectivetime)
);

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_simplemaprefset_f') DROP TABLE curr_simplemaprefset_f;
create table curr_simplemaprefset_f(
  id uniqueidentifier not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  maptarget text not null,
  PRIMARY KEY(id, effectivetime)
);

IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'curr_extendedmaprefset_f') DROP TABLE curr_extendedmaprefset_f;
create table curr_extendedmaprefset_f(
  id uniqueidentifier not null,
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
)