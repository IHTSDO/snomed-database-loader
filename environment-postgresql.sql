/* create the Full S-CT data tables */
set schema 'snomedct';

drop table if exists curr_concept_f cascade;
create table curr_concept_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  definitionstatusid varchar(18) not null,
  CONSTRAINT curr_concept_f_pkey PRIMARY KEY(id, effectivetime, active)
);

drop table if exists curr_description_f cascade;
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
  CONSTRAINT curr_description_f_pkey PRIMARY KEY(id, effectivetime, active)
);

drop table if exists curr_textdefinition_f cascade;
create table curr_textdefinition_f(
  id varchar(18) not null,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  conceptid varchar(18) not null,
  languagecode varchar(2) not null,
  typeid varchar(18) not null,
  term varchar(1024) not null unique,
  casesignificanceid varchar(18) not null,
  CONSTRAINT curr_textdefinition_f_pkey PRIMARY KEY(id, effectivetime, active)
);

drop table if exists curr_relationship_f cascade;
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
  CONSTRAINT curr_relationship_f_pkey PRIMARY KEY(id, effectivetime, active)
);

drop table if exists curr_stated_relationship_f cascade;
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
  CONSTRAINT curr_stated_relationship_f_pkey PRIMARY KEY(id, effectivetime, active)
);

drop table if exists curr_langrefset_f cascade;
create table curr_langrefset_f(
  id uuid not null primary key,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  acceptabilityid varchar(18) not null 
);

drop table if exists curr_associationrefset_d cascade;
create table curr_associationrefset_d(
  id uuid not null primary key,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  targetcomponentid varchar(18) not null 
);

drop table if exists curr_attributevaluerefset_f cascade;
create table curr_attributevaluerefset_f(
  id uuid not null primary key,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  valueid varchar(18) not null 
);

drop table if exists curr_simplerefset_f cascade;
create table curr_simplerefset_f(
  id uuid not null primary key,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null
);

drop table if exists curr_simplemaprefset_f cascade;
create table curr_simplemaprefset_f(
  id uuid not null primary key,
  effectivetime char(8) not null,
  active char(1) not null,
  moduleid varchar(18) not null,
  refsetid varchar(18) not null,
  referencedcomponentid varchar(18) not null,
  maptarget text not null 
);

drop table if exists curr_complexmaprefset_f cascade;
create table curr_complexmaprefset_f(
  id uuid not null primary key,
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
  correlationId varchar(18) not null 
);

drop table if exists curr_extendedmaprefset_f cascade;
create table curr_extendedmaprefset_f(
  id uuid not null primary key,
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
  mapCategoryId varchar(18)
)