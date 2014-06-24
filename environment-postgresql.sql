/* Create the database */
drop schema if exists snomedct;
create schema if not exists snomedct;
set schema 'snomedct';

/* create the Full S-CT data tables */

drop table if exists curr_concept_f cascade;
create table curr_concept_f(
  id varchar(18) not null primary key,
  effectivetime char(8) not null unique,
  active char(1) not null unique,
  moduleid varchar(18) not null unique,
  definitionstatusid varchar(18) not null unique 
);

drop table if exists curr_description_f cascade;
create table curr_description_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  conceptid varchar(18) not null unique,
  languagecode varchar(2) not null unique,
  typeid varchar(18) not null unique,
  term varchar(255) not null unique,
  casesignificanceid varchar(18) not null unique 
);

drop table if exists curr_textdefinition_f cascade;
create table curr_textdefinition_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null references curr_concept_f(effectivetime),
  active char(1) not null references curr_concept_f(active),
  moduleid varchar(18) not null references curr_concept_f(moduleid),
  conceptid varchar(18) not null references curr_description_f(conceptid),
  languagecode varchar(2) not null references curr_description_f(conceptid),
  typeid varchar(18) not null references curr_description_f(conceptid),
  term varchar(1024) not null unique,
  casesignificanceid varchar(18) not null references curr_description_f(conceptid)
);

drop table if exists curr_relationship_f cascade;
create table curr_relationship_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null references curr_concept_f(effectivetime),
  active char(1) not null references curr_concept_f(active),
  moduleid varchar(18) not null references curr_concept_f(moduleid),
  sourceid varchar(18) not null unique,
  destinationid varchar(18) not null unique,
  relationshipgroup varchar(18) not null unique,
  typeid varchar(18) not null references curr_description_f(conceptid),
  characteristictypeid varchar(18) not null unique,
  modifierid varchar(18) not null unique 
);

drop table if exists curr_stated_relationship_f cascade;
create table curr_stated_relationship_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  sourceid varchar(18) not null references curr_relationship(source_id),
  destinationid varchar(18) not null references curr_relationship(destinationid),
  relationshipgroup varchar(18) not null references curr_relationship_f(relationshipgroup),
  typeid varchar(18) not null references curr_relationship_f(typeid),
  characteristictypeid varchar(18) not null references curr_relationship_f(characteristictypeid),
  modifierid varchar(18) not null references curr_relationship_f(modifierid)
);

drop table if exists curr_langrefset_f cascade;
create table curr_langrefset_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  refsetid varchar(18) not null unique,
  referencedcomponentid varchar(18) not null unique,
  acceptabilityid varchar(18) not null unique 
);

drop table if exists curr_associationrefset_d cascade;
create table curr_associationrefset_d(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  refsetid varchar(18) not null references curr_langrefset_f(refsetid),
  referencedcomponentid varchar(18) not null references curr_langrefset_f(referencedcomponentid),
  targetcomponentid varchar(18) not null unique 
);

drop table if exists curr_attributevaluerefset_f cascade;
create table curr_attributevaluerefset_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  refsetid varchar(18) not null references curr_langrefset_f(refsetid),
  referencedcomponentid varchar(18) not null references curr_langrefset_f(referencedcomponentid),
  valueid varchar(18) not null unique 
);

drop table if exists curr_simplemaprefset_f cascade;
create table curr_simplemaprefset_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  refsetid varchar(18) not null references curr_langrefset_f(refsetid),
  referencedcomponentid varchar(18) not null references curr_langrefset_f(referencedcomponentid),
  maptarget varchar(32) not null unique 
);

drop table if exists curr_simplerefset_f cascade;
create table curr_simplerefset_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  refsetid varchar(18) not null references curr_langrefset_f(refsetid),
  referencedcomponentid varchar(18) not null references curr_langrefset_f(referencedcomponentid)
);

drop table if exists curr_complexmaprefset_f cascade;
create table curr_complexmaprefset_f(
  id varchar(18) not null references curr_concept_f(id),
  effectivetime char(8) not null  references curr_concept_f(effectivetime),
  active char(1) not null  references curr_concept_f(active),
  moduleid varchar(18) not null  references curr_concept_f(moduleid),
  refsetid varchar(18) not null references curr_langrefset_f(refsetid),
  referencedcomponentid varchar(18) not null references curr_langrefset_f(referencedcomponentid),
  mapGroup smallint not null unique,
  mapPriority smallint not null unique,
  mapRule varchar(18) unique,
  mapAdvice varchar(18) unique,
  mapTarget varchar(18) unique,
  correlationId varchar(18) not null unique 
);
