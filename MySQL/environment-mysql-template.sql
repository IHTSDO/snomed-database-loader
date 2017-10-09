/* Template for creating the S-CT RF2 data tables - TYPE replaced with d, s and f at runtime*/

/* Section for type : TYPE */

drop table if exists concept_TYPE;
create table concept_TYPE(
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


drop table if exists description_TYPE;
create table description_TYPE(
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
key idx_casesignificanceid(casesignificanceid)
) engine=myisam default charset=utf8;

drop table if exists textdefinition_TYPE;
create table textdefinition_TYPE(
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

drop table if exists relationship_TYPE;
create table relationship_TYPE(
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

drop table if exists stated_relationship_TYPE;
create table stated_relationship_TYPE(
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

drop table if exists langrefset_TYPE;
create table langrefset_TYPE(
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

drop table if exists associationrefset_TYPE;
create table associationrefset_TYPE(
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

drop table if exists attributevaluerefset_TYPE;
create table attributevaluerefset_TYPE(
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

drop table if exists simplemaprefset_TYPE;
create table simplemaprefset_TYPE(
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

drop table if exists simplerefset_TYPE;
create table simplerefset_TYPE(
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

drop table if exists complexmaprefset_TYPE;
create table complexmaprefset_TYPE(
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

drop table if exists extendedmaprefset_TYPE;
create table extendedmaprefset_TYPE(
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

