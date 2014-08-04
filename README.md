SNOMED CT DATABASE 
===============
MYSQL SQL Scripts to create and populate a MYSQL or POSTGRES database with a SNOMED CT terminology release


Minimum Specification
---------------------
- MYSQL v5.5.x
- POSTGRES v.x


Installation
------------
1. Download the SNOMED CT terminology release from the IHTSDO web site
2. Create the database using the db appropriate environment.sql script
3. Edit the db appropriate load.sql script with the correct location of the SNOMED CT release files
4. Load the database created using the edited load.sql script from the relevant command prompt, e.g. `mysql> source load.sql`, or via the relevant management tool (tested in both phpmyadmin and mysqlworkbench).

That should be it.
