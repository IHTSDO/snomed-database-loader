/* create the database */
drop schema if exists 'snomedct';
create schema if not exists 'snomedct';
set schema 'snomedct';

/* create the Full S-CT data tables */

drop table if exists curr_concept_f;
create table curr_concept_f(
primary key id varchar(18) not null,
unique effectivetime char(8) not null,
unique active char(1) not null,
unique moduleid varchar(18) not null,
unique definitionstatusid varchar(18) not null
);

drop table if exists curr_description_f;
create table curr_description_f(
id varchar(18) not null references curr_concept_f(id),
effectivetime char(8) not null  references curr_concept_f(id),
active char(1) not null  references curr_concept_f(id),
moduleid varchar(18) not null  references curr_concept_f(id),
unique conceptid varchar(18) not null,
unique languagecode varchar(2) not null,
unique typeid varchar(18) not null,
unique term varchar(255) not null,
unique casesignificanceid varchar(18) not null
);

drop table if exists curr_textdefinition_f;
create table curr_textdefinition_f(
id varchar(18) not null references curr_concept_f(id),
effectivetime char(8) not null references curr_concept_f(id),
active char(1) not null references curr_concept_f(id),
moduleid varchar(18) not null references curr_concept_f(id),
conceptid varchar(18) not null references curr_description_f(conceptid),
languagecode varchar(2) not null references curr_description_f(conceptid),
typeid varchar(18) not null references curr_description_f(conceptid),
unique term varchar(1024) not null,
casesignificanceid varchar(18) not null references curr_description_f(conceptid)
);

drop table if exists curr_relationship_f;
create table curr_relationship_f(
id varchar(18) not null references curr_concept_f(id),
effectivetime char(8) not null references curr_concept_f(id),
active char(1) not null references curr_concept_f(id),
moduleid varchar(18) not null references curr_concept_f(id),
unique sourceid varchar(18) not null,
unique destinationid varchar(18) not null,
unique relationshipgroup varchar(18) not null,
typeid varchar(18) not null references curr_description_f(conceptid),
unique characteristictypeid varchar(18) not null,
unique modifierid varchar(18) not null
);

/*
id varchar(18) not null references curr_concept_f(id),
effectivetime char(8) not null references curr_concept_f(id),
active char(1) not null references curr_concept_f(id),
moduleid varchar(18) not null references curr_concept_f(id),
conceptid varchar(18) not null references curr_description_f(conceptid),
languagecode varchar(2) not null references curr_description_f(conceptid),
typeid varchar(18) not null references curr_description_f(conceptid),
term varchar(1024) not null references curr_description_f(conceptid),
casesignificanceid varchar(18) not null references curr_description_f(conceptid)
references curr_relationship_f(typeid)
*/

drop table if exists curr_stated_relationship_f;
create table curr_stated_relationship_f(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
sourceid varchar(18) not null,
destinationid varchar(18) not null,
relationshipgroup varchar(18) not null,
typeid varchar(18) not null references curr_relationship_f(typeid),
characteristictypeid varchar(18) not null,
modifierid varchar(18) not null
);

drop table if exists curr_langrefset_f;
create table curr_langrefset_f(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
acceptabilityid varchar(18) not null
);

drop table if exists curr_associationrefset_d;
create table curr_associationrefset_d(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
targetcomponentid varchar(18) not null
);

drop table if exists curr_attributevaluerefset_f;
create table curr_attributevaluerefset_f(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
valueid varchar(18) not null
);

drop table if exists curr_simplemaprefset_f;
create table curr_simplemaprefset_f(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
maptarget varchar(32) not null
);

drop table if exists curr_simplerefset_f;
create table curr_simplerefset_f(
	id varchar(36) not null,
	effectivetime char(8) not null,
	active char(1) not null,
	moduleid varchar(18) not null,
	refsetid varchar(18) not null,
	referencedcomponentid varchar(18) not null
);

drop table if exists curr_complexmaprefset_f;
create table curr_complexmaprefset_f(
	id varchar(36) not null,
	effectivetime char(8) not null,
	active char(1) not null,
	moduleid varchar(18) not null,
	refsetid varchar(18) not null,
	referencedcomponentid varchar(18) not null,
	mapGroup smallint not null,
	mapPriority smallint not null,
	mapRule varchar(18),
	mapAdvice varchar(18),
	mapTarget varchar(18),
	correlationId varchar(18) not null
);
