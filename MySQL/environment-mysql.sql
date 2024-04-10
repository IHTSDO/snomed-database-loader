
/* create the Full S-CT data tables */

drop table if exists concept_f;
create table concept_f(
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
) engine=myisam default charset=utf8;


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
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

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
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

drop table if exists relationship_f;
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
) engine=myisam default charset=utf8;

drop table if exists stated_relationship_f;
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
) engine=myisam default charset=utf8;

drop table if exists langrefset_f;
create table langrefset_f(
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
) engine=myisam default charset=utf8;

drop table if exists associationrefset_f;
create table associationrefset_f(
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
) engine=myisam default charset=utf8;

drop table if exists attributevaluerefset_f;
create table attributevaluerefset_f(
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
) engine=myisam default charset=utf8;

drop table if exists simplemaprefset_f;
create table simplemaprefset_f(
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
) engine=myisam default charset=utf8;

drop table if exists simplerefset_f;
create table simplerefset_f(
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
) engine=myisam default charset=utf8;

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
mapRule text,
mapAdvice text,
mapTarget varchar(18),
correlationId varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_mapTarget(mapTarget)
) engine=myisam default charset=utf8;

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
mapRule text,
mapAdvice text,
mapTarget varchar(18),
correlationId varchar(18) not null,
mapCategoryId varchar(18),
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_mapTarget(mapTarget)
) engine=myisam default charset=utf8;

/* create the Snapshot S-CT data tables */

drop table if exists concept_s;
create table concept_s(
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
) engine=myisam default charset=utf8;


drop table if exists description_s;
create table description_s(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
conceptid varchar(18) not null,
languagecode varchar(2) not null,
typeid varchar(18) not null,
term varchar(4096) not null,
casesignificanceid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

drop table if exists textdefinition_s;
create table textdefinition_s(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
conceptid varchar(18) not null,
languagecode varchar(2) not null,
typeid varchar(18) not null,
term varchar(4096) not null,
casesignificanceid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

drop table if exists relationship_s;
create table relationship_s(
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
) engine=myisam default charset=utf8;

drop table if exists stated_relationship_s;
create table stated_relationship_s(
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
) engine=myisam default charset=utf8;

drop table if exists langrefset_s;
create table langrefset_s(
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
) engine=myisam default charset=utf8;

drop table if exists associationrefset_s;
create table associationrefset_s(
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
) engine=myisam default charset=utf8;

drop table if exists attributevaluerefset_s;
create table attributevaluerefset_s(
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
) engine=myisam default charset=utf8;

drop table if exists simplemaprefset_s;
create table simplemaprefset_s(
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
) engine=myisam default charset=utf8;

drop table if exists simplerefset_s;
create table simplerefset_s(
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
) engine=myisam default charset=utf8;

drop table if exists complexmaprefset_s;
create table complexmaprefset_s(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
mapGroup smallint not null,
mapPriority smallint not null,
mapRule text,
mapAdvice text,
mapTarget varchar(18),
correlationId varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_mapTarget(mapTarget)
) engine=myisam default charset=utf8;

drop table if exists extendedmaprefset_s;
create table extendedmaprefset_s(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
mapGroup smallint not null,
mapPriority smallint not null,
mapRule text,
mapAdvice text,
mapTarget varchar(18),
correlationId varchar(18) not null,
mapCategoryId varchar(18),
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_mapTarget(mapTarget)
) engine=myisam default charset=utf8;

/* create the Delta S-CT data tables */

drop table if exists concept_d;
create table concept_d(
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
) engine=myisam default charset=utf8;


drop table if exists description_d;
create table description_d(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
conceptid varchar(18) not null,
languagecode varchar(2) not null,
typeid varchar(18) not null,
term varchar(4096) not null,
casesignificanceid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

drop table if exists textdefinition_d;
create table textdefinition_d(
id varchar(18) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
conceptid varchar(18) not null,
languagecode varchar(2) not null,
typeid varchar(18) not null,
term varchar(4096) not null,
casesignificanceid varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_conceptid(conceptid),
key idx_languagecode(languagecode),
key idx_typeid(typeid),
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

drop table if exists relationship_d;
create table relationship_d(
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
) engine=myisam default charset=utf8;

drop table if exists stated_relationship_d;
create table stated_relationship_d(
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
) engine=myisam default charset=utf8;

drop table if exists langrefset_d;
create table langrefset_d(
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
) engine=myisam default charset=utf8;

drop table if exists associationrefset_d;
create table associationrefset_d(
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
) engine=myisam default charset=utf8;

drop table if exists attributevaluerefset_d;
create table attributevaluerefset_d(
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
) engine=myisam default charset=utf8;

drop table if exists simplemaprefset_d;
create table simplemaprefset_d(
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
) engine=myisam default charset=utf8;

drop table if exists simplerefset_d;
create table simplerefset_d(
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
) engine=myisam default charset=utf8;

drop table if exists complexmaprefset_d;
create table complexmaprefset_d(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
mapGroup smallint not null,
mapPriority smallint not null,
mapRule text,
mapAdvice text,
mapTarget varchar(18),
correlationId varchar(18) not null,
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_mapTarget(mapTarget)
) engine=myisam default charset=utf8;

drop table if exists extendedmaprefset_d;
create table extendedmaprefset_d(
id varchar(36) not null,
effectivetime char(8) not null,
active char(1) not null,
moduleid varchar(18) not null,
refsetid varchar(18) not null,
referencedcomponentid varchar(18) not null,
mapGroup smallint not null,
mapPriority smallint not null,
mapRule text,
mapAdvice text,
mapTarget varchar(18),
correlationId varchar(18) not null,
mapCategoryId varchar(18),
key idx_id(id),
key idx_effectivetime(effectivetime),
key idx_active(active),
key idx_moduleid(moduleid),
key idx_refsetid(refsetid),
key idx_referencedcomponentid(referencedcomponentid),
key idx_mapTarget(mapTarget)
) engine=myisam default charset=utf8;