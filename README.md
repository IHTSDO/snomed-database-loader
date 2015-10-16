SNOMED CT DATABASE 
===============
MYSQL SQL Scripts to create and populate a MYSQL or PostgreSQL database with a SNOMED CT terminology release


Minimum Specification
---------------------
- MYSQL v5.5.x
- PostgreSQL v.9


Installation
------------
1. Download the SNOMED CT terminology release from the IHTSDO web site
2. Create the database using the db appropriate create-database.sql script or skip/perform this action manually if you'd like the data to be loaded into a existing/different database.
3. Create the tables using the db appropriate environment.sql script.  The default file creates tables for full, snapshot and delta files and there's also a -full-only version.
4. Edit the db appropriate load.sql script with the correct location of the SNOMED CT release files
   An alternative under unix or mac would be to create a symlink to the appropriate directory 
   eg <code>ln -s /your/snomed/directory RF2Release</code>
5. Load the database created using the edited load.sql script from the relevant command prompt, e.g. <code>mysql> source load.sql</code> or via the relevant management tool (tested in both phpmyadmin and mysqlworkbench).
 - again by default for full, snapshot and delta unless you only want the full version.

NB If you're using mysql 5.5 or above then you'll need to start that with the following command in order to allow local files to be loaded: <code>mysql -u &#91;your_user&#93; -p --local-infile</code>
