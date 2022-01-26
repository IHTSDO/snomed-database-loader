# SNOMED CT MySQL Loader Scripts Information
## SnomedRfsMySql 2022-01-26

## IMPORTANT NOTES

This loader has been tested to work with MySQL 8.x and with the earlier version 5.7.

Use with MySQL version 8.x requires the server to reference a copy of the file *cnf/my_snomedserver.cnf* as an additional configuration file.

# Scripts and Subfolders

Files in this folder with the .sql suffix are used to import SNOMED CT release files.

NOTES:
	- The subfolders contain additional scripts that may be of interest
	- mysql_create: Scripts used to create SNOMED CT database.
		- The essential first step in creating a database is to use a create script.
		- This subfolder typically contains:
			- A copy of scripts that can be used to build the database for the current release (e.g. sct_mysql_load_create_InternationalRF2_2021.sql).
			- A copy of scripts that can be used to build the database for an earlier release that may include a different set of release files (e.g. sct_mysql_load_create_InternationalRF2_2020.sql). 
	- mysql_extend: Scripts used extend a SNOMED CT database by adding files from a specific extension release.
		- These scripts can only be used to extend an existing release including the SNOMED CT International core modules is already installed.
	- mysql_update: Scripts used to update an existing SNOMED CT database with newer versions of views and procedures that are used to optimise or simplify access to data, without requiring a complete reinstallation of the data.
	- mysql_index: Scripts that can be used to reindex data in an existing SNOMED CT database, without requiring a complete reinstallation of the data.

# Summarised Instructions for Use

Full instructions for running these scripts is provided on the following web document:
   https://confluence.ihtsdotools.org/display/DOCSQLPG/Appendix+A%3A+Building+the+SNOMED+CT+Example+Database

If the initial configuration steps shown on that page have already been done, the release data can be imported using the following steps:   
1. Open the appropriate command line shell
	- On a Mac or Unix system open Terminal
	- On a Windows system open the command shell
2. Change directory to the parent folder SnomedRfsMySql
	- For example if this folder is in you user home folder on Mac/Unix the command would be:
		Mac/Unix: cd ~/SnomedRfsMySql
		Windows : cd \SnomedRfsMySql
3. Run the following command
		Mac/Unix: bash/mysql_load
		Windows : win\snomed_wload_mysql
4. Respond to prompts for additional information
	- Including specifying the relevant import script.
	- For example to load the latest SNOMED CT International Release: 
		sct_mysql_load_create_InternationalRF2
5. NOTE: The import process may take a long time to run
	- During the process a report on the steps being undertaken and completed will be shown
	- When the process completes you should have a fully installed MySql schema populated with the chosen release data

## bash/snomed_config_mysql

* Applies the required MySQL configuration settings in *cnf/my_snomedserver.cnf* to the server.

## bash/snomed_load_mysql

1. Collects user input to configure the following settings:
    - Name of the SQL import script to be used (default: create_latest)
        - Note VP_latest refers to the file *mysql_load/sct_mysql_load_create_latest.sql*
    - Path to SNOMED CT release file package
    - Name of the database schema to be created (default: snomedct)
    - MySQL database username for running the SNOMED CT import script (default: root)
2. Configures the import script to use the chosen settings
3. Builds a Transitive Closure snapshot file (from the relationships release file)
4. Prompts for the MySQL password
5. Runs the SNOMED CT MySQL import script

# Other Operating System Environments

In other environments the following steps may need to be carried out manually.
* MySQL configuration changes
* Running the Perl script to generate the Transitive Closure snapshot file.
* Modifying and running the SNOMED CT MySQL import script *mysql_load/sct_mysql_load_create_latest.sql*.

The notes below outline the extent to which the scripts may be useful in other environments and outline steps required to run the processes manually.

## Other Unix Based Systems

### Configuration Settings on Other Unix Based Systems

As written the script *bash/snomed_mysql_config* is unlikely to work on other Unix based systems. This is because it assumes the default location for configuration files on the Mac.
Therefore, you will need to manually adjust the settings to include the settings in the *cnf/my_snomedserver.cnf* file in one of the configuration file read when the MySQL server is started.

### Loading the SNOMED CT Release Package on Other Unix Based Systems

This script *bash/snomed_mysql_load* should work in most Unix based environments. It uses the bash shell and general purpose unix utilities. However, it has not been tested except on the Mac, so some changes might be necessary.

If it does not work please refer to the notes on use on Widnows systems below for a description of the required manual steps.

## Support for Use on Windows

## win/snomed_wconfig_mysql.bat

* Applies the required MySQL configuration settings in *win/snomed_win_my.cnf* to the server.

## win/snomed_wload_mysql.bat

1. Collects user input to configure the following settings:
    - Name of the SQL import script to be used (default: create_latest)
        - Note VP_latest refers to the file *mysql_load/sct_mysql_load_create_latest.sql*
    - Path to SNOMED CT release file package
    - Name of the database schema to be created (default: snomedct)
    - MySQL database username for running the SNOMED CT import script (default: root)
2. Configures the import script to use the chosen settings
3. Builds a Transitive Closure snapshot file (from the relationships release file)
4. Prompts for the MySQL password
5. Runs the SNOMED CT MySQL import script

### Configuration Settings on Windows Systems

Manually adjust the settings to include the settings in the *cnf/my_snomedserver.cnf* file in one of the configuration file read when the MySQL server is started.

### Loading the SNOMED CT Release Package on Other Unix Based Systems

1. Create a copy of the file *mysql_load/sct_mysql_load_VP_latest.sql*
    - Name the new file: *mysql_load_local.sql*
2. Open the file *mysql_load_local.sql* in text editor. 
3. Use the text editor to replace all instances of the following three placeholders:
    - $RELPATH with the full path to the folder containing the SNOMED CT release package you want to import.
    - $RELDATE with the YYYYDDMM representation of the release date (e.g. 20190731)
    - $DBNAME with the name of the database schema you want to create (e.g. snomedct).
4. Save the file *mysql_load_local.sql*.
5. Run the following command line:

    mysql --defaults-extra-file="*my_snomedimport_client.cnf*"  --protocol=tcp --host=localhost --default-character-set=utf8mb4 --comments --user *mysql_username* --password  < "*mysql_load_local.sql*"

### NOTES
- The full path names of the following files should be included on the command line enclosed in quotation marks.
  - "*my_snomedimport_client.cnf*"
  - "*mysql_load_local.sql*"
- The *mysql_username* must either be **root** or another account with rights to drop and create database schemas. You will be required to enter the password for this account when running the command.
- There are spaces before each of the double dashes in the command line.
