SNOMED CT DATABASE 
===============
MYSQL SQL Scripts to create and populate a MYSQL database with a SNOMED CT terminology release


Minimum Specification
---------------------
- MYSQL v5.5.x


Installation
------------
1. Download the SNOMED CT terminology release from the IHTSDO web site
2. Create the database using environment.sql
3. Edit the load.sql script with the correct location of the SNOMED CT release files
4. Load the database created using the edited load.sql script.

That should be it.