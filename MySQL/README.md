# SNOMED CT DATABASE

MYSQL SQL Scripts to create and populate a MYSQL database with a SNOMED CT terminology release

## Minimum Specification

- MYSQL v5.5.x

## Scripted Installation (Mac & Unix)

run load_release.sh

<rf2 archive="" location="">
  <schemaname>
  <loadtype -="" delta|snap|full|all="">
</loadtype>
</schemaname>
</rf2>

eg ./load_release.sh ~/Backup/SnomedCT_RF2Release_INT_20150731.zip SCT_20150731 SNAP

Note that the scripted installation will now support loading other Editions. The script asks for a module identifier, which is INT by default, for the international edition. Loading the US Edition, for example, would work as follows: `Enter module string used in filenames [INT]: US1000124`

## Manual Installation

1. Download the SNOMED CT terminology release from the IHTSDO web site
2. Create the database using the db appropriate create-database.sql script or skip/perform this action manually if you'd like the data to be loaded into a existing/different database.
3. Create the tables using the db appropriate environment.sql script. The default file creates tables for full, snapshot and delta files and there's also a -full-only version.
4. Edit the db appropriate load.sql script with the correct location of the SNOMED CT release files An alternative under unix or mac would be to create a symlink to the appropriate directory eg `ln -s /your/snomed/directory RF2Release`
5. Load the database created using the edited load.sql script from the relevant command prompt, e.g. `mysql> source load.sql` or via the relevant management tool (tested in both phpmyadmin and mysqlworkbench).

  - again by default for full, snapshot and delta unless you only want the full version.

NB If you're using mysql 5.5 or above then you'll need to start that with the following command in order to allow local files to be loaded: `mysql -u [your_user] -p --local-infile`

### Issues

If you see the following error: ERROR 1148 (42000) at line 2 in file: 'tmp_rf1_loader.sql': The used command is not allowed with this MySQL version

This is a security feature of MYSQL to prevent local files being loaded. The load script script includes an argument of "--local-infile" when starting the client application, but this must also be permitted in the server configuration (eg /usr/local/etc/my.cnf which you may need to create. Type mysql --help for a list of expected config locations). Add the following block to your mysql config file: `[mysql] local-infile=1`

See <http://stackoverflow.com/questions/10762239/mysql-enable-load-data-local-infile>
