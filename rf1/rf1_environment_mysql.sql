/* create the RF1 data tables */

drop table if exists rf1_concept;
create table rf1_concept(
	CONCEPTID			VARCHAR (18) NOT NULL,
	CONCEPTSTATUS		TINYINT (2) UNSIGNED NOT NULL,
	FULLYSPECIFIEDNAME	VARCHAR (255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	CTV3ID				BINARY (5) NOT NULL,
	SNOMEDID			VARBINARY (8) NOT NULL,
	ISPRIMITIVE			TINYINT (1) UNSIGNED NOT NULL,
	SOURCE				BINARY (4) NOT NULL,
	key idx_id(CONCEPTID)
) engine=myisam default charset=utf8;


drop table if exists rf1_description;
create table rf1_description(
	DESCRIPTIONID		VARCHAR (18) NOT NULL,
	DESCRIPTIONSTATUS	TINYINT (2) UNSIGNED NOT NULL,
	CONCEPTID			VARCHAR (18) NOT NULL,
	TERM				VARCHAR (4096) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	INITIALCAPITALSTATUS TINYINT (1) UNSIGNED NOT NULL,
	DESCRIPTIONTYPE		TINYINT (1) UNSIGNED NOT NULL,
	DEFAULTDESCTYPE		TINYINT (1) UNSIGNED NOT NULL,
	LANGUAGECODE		VARBINARY (8) NOT NULL,
	SOURCE				BINARY(4) NOT NULL,
key idx_id(DESCRIPTIONID),
key idx_status(DESCRIPTIONSTATUS)
) engine=myisam default charset=utf8;

drop table if exists rf1_textdefinition;
create table rf1_textdefinition(
	CONCEPTID			VARCHAR (18) NOT NULL,
	SNOMEDID			VARBINARY (8) NOT NULL,
	FULLYSPECIFIEDNAME	VARCHAR (255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	DEFINITION			VARCHAR (450) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	key idx_id(SNOMEDID)
) engine=myisam default charset=utf8;

drop table if exists rf1_relationship;
create table rf1_relationship(
	RELATIONSHIPID		VARCHAR (18) NOT NULL,
	CONCEPTID1			VARCHAR (18) NOT NULL,
	RELATIONSHIPTYPE	VARCHAR (18) NOT NULL,
	CONCEPTID2			VARCHAR (18) NOT NULL,
	CHARACTERISTICTYPE	TINYINT (1) UNSIGNED NOT NULL,
	REFINABILITY		TINYINT (1) UNSIGNED NOT NULL,
	RELATIONSHIPGROUP	TINYINT (2) UNSIGNED NOT NULL,
	SOURCE				BINARY (4) NOT NULL,
	key idx_id(RELATIONSHIPID)
) engine=myisam default charset=utf8;

drop table if exists rf1_stated_relationship;
create table rf1_stated_relationship(
	RELATIONSHIPID		VARCHAR (18) NOT NULL,
	CONCEPTID1			VARCHAR (18) NOT NULL,
	RELATIONSHIPTYPE	VARCHAR (18) NOT NULL,
	CONCEPTID2			VARCHAR (18) NOT NULL,
	CHARACTERISTICTYPE	TINYINT (1) UNSIGNED NOT NULL,
	REFINABILITY		TINYINT (1) UNSIGNED NOT NULL,
	RELATIONSHIPGROUP	TINYINT (2) UNSIGNED NOT NULL,
	SOURCE				BINARY (4) NOT NULL,
	key idx_id(RELATIONSHIPID)
) engine=myisam default charset=utf8;

DROP TABLE IF EXISTS rf1_subset;
CREATE TABLE rf1_subset (
	SubsetId			VARCHAR (18) NOT NULL,
	SubsetOriginalID	VARCHAR (18) NOT NULL,
	SubsetVersion		VARBINARY(4) NOT NULL,
	SubsetName			VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
	SubsetType			TINYINT (1) UNSIGNED NOT NULL,
	LanguageCode		VARBINARY(5),
	SubsetRealmID		VARBINARY (10) NOT NULL,
	ContextID			TINYINT (1) UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS rf1_subsetmember;
CREATE TABLE rf1_subsetmember (
	SubsetId			VARCHAR (18) NOT NULL,
	MemberID			VARCHAR (18) NOT NULL,
	MemberStatus		TINYINT (1) UNSIGNED NOT NULL,
	LinkedID			VARCHAR(18) CHARACTER SET latin1 COLLATE latin1_general_ci
);

DROP TABLE IF EXISTS rf1_reference;
CREATE TABLE rf1_reference(
	COMPONENTID			VARCHAR (18) NOT NULL,
	REFERENCETYPE		TINYINT (1) NOT NULL,
	REFERENCEDID		VARCHAR (18) NOT NULL,
	SOURCE				BINARY (4) NOT NULL
);

DROP TABLE IF EXISTS rf1_componenthistory;
CREATE TABLE rf1_componenthistory(
	COMPONENTID		VARCHAR (18) NOT NULL,
	RELEASEVERSION	BINARY (8) NOT NULL,
	CHANGETYPE		TINYINT (1) NOT NULL,
	STAT			TINYINT (1) NOT NULL,
	REASON			VARCHAR(255) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
	SOURCE			BINARY(4) NOT NULL
);
