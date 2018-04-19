# SNOMED CT DATABASE

PostgreSQL SQL Scripts to create and populate a PostgreSQL database with a SNOMED CT terminology release.

**NOTE:** This script is not directly supported by SNOMED International and has not been fully tested by the SNOMED International team. It has been kindly donated by others in the SNOMED CT community.

## Minimum Specification

- PostgreSQL v.9

# Creating the SNOMED CT schema on PostgreSQL

PostgreSQL is an [`ORDBMS`](http://en.wikipedia.org/wiki/ORDBMS) therefore every Database is self-contained object. A _"database"_ contains logins, one or more schemas, groups, etc. and every conection is related to a sigle database.

## Diffences from the MySQL version

- PostgreSQL does not need `engine=myisam` which by itself is a bit strange as `myisam` does not support foreign keys.
- Changes `database` for `schema`
- using the `unique` constraint instead of `key`

## Scripted Installation (Mac & Unix)

run load_release-postgresql.sh

<rf2 archive="" location="">
  <schemaname>
  <loadtype -="" delta|snap|full|all="">
</loadtype>
</schemaname>
</rf2>

eg ./load_release-postgresql.sh ~/Backup/SnomedCT_RF2Release_INT_20180131.zip SCT_20180131 SNAP

Note that the scripted installation will now support loading other Editions. The script asks for a module identifier, which is INT by default, for the international edition. Loading the US Edition, for example, would work as follows: `Enter module string used in filenames [INT]: US1000124`

## Manual Installation

1. Download the SNOMED CT terminology release from the IHTSDO web site
2. Create the database using the db create-database-postgres.sql script or skip/perform this action manually if you'd like the data to be loaded into a existing/different database.
3. Create the tables using the db appropriate environment.sql script. The default file creates tables for full, snapshot and delta files and there's also a -full-only version.
4. Edit the db appropriate load.sql script with the correct location of the SNOMED CT release files An alternative under unix or mac would be to create a symlink to the appropriate directory eg `ln -s /your/snomed/directory RF2Release`
5. Load the database created using the edited load.sql script from the relevant command prompt, again by default for full, snapshot and delta unless you only want the full version.
