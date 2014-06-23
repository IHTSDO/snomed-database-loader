/* create the database */
drop database if exists snomedct;
create database if not exists snomedct;
use snomedct;

/* create the Full S-CT data tables */

drop table if exists curr_concept_f;
create table curr_concept_f(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
definitionstatusid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_definitionstatusid(definitionstatusid)
)  default charset=utf8;


drop table if exists curr_description_f;
create table curr_description_f(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
conceptid varchar(18) not null,
languagecode varchar(2) not null,
typeid varchar(18) not null,
term varchar(255) not null,
casesignificanceid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_term(term),
key idx_casesignificanceid(casesignificanceid)
)  default charset=utf8;

drop table if exists curr_textdefinition_f;
create table curr_textdefinition_f(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
conceptid varchar(18) not null,
languagecode varchar(2) not null,
typeid varchar(18) not null,
term varchar(1024) not null,
casesignificanceid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_term(term(255)),
key idx_casesignificanceid(casesignificanceid)
)  default charset=utf8;

drop table if exists curr_relationship_f;
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
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_sourceid(sourceid),
key idx_destinationid(destinationid),
key idx_relationshipgroup(relationshipgroup),
key idx_typeid(typeid),
key idx_characteristictypeid(characteristictypeid),
key idx_modifierid(modifierid)
)  default charset=utf8;

drop table if exists curr_stated_relationship_f;
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
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_sourceid(sourceid),
key idx_destinationid(destinationid),
key idx_relationshipgroup(relationshipgroup),
key idx_typeid(typeid),
key idx_characteristictypeid(characteristictypeid),
key idx_modifierid(modifierid)
)  default charset=utf8;

drop table if exists curr_langrefset_f;
create table curr_langrefset_f(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
acceptabilityid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_acceptabilityid(acceptabilityid)
)  default charset=utf8;

drop table if exists curr_associationrefset_d;
create table curr_associationrefset_d(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
targetcomponentid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_targetcomponentid(targetcomponentid)
)  default charset=utf8;

drop table if exists curr_attributevaluerefset_f;
create table curr_attributevaluerefset_f(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
valueid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_valueid(valueid)
)  default charset=utf8;

drop table if exists curr_simplemaprefset_f;
create table curr_simplemaprefset_f(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
maptarget varchar(32) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_maptarget(maptarget)
)  default charset=utf8;

drop table if exists curr_simplerefset_f;
create table curr_simplerefset_f(
	id varchar(36) not null,
	effectivetime char(8) not null,
	active char(1) not null,
	moduleid varchar(18) not null,
	refsetid varchar(18) not null,
	referencedcomponentid varchar(18) not null,
	key idx_id(id),
	key idx_effectivetime(effectivetime),
	key idx_active(active),
	key idx_moduleid(moduleid),
	key idx_refsetid(refsetid),
	key idx_referencedcomponentid(referencedcomponentid)
)  default charset=utf8;

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
	correlationId varchar(18) not null,
	key idx_id(id),
	key idx_effectivetime(effectivetime),
	key idx_active(active),
	key idx_moduleid(moduleid),
	key idx_refsetid(refsetid),
	key idx_referencedcomponentid(referencedcomponentid),
	key idx_mapTarget(mapTarget)
)  default charset=utf8;
