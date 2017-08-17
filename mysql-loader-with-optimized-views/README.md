# SNOMED CT MySQL Loader with Optimized Views
## Using the SQL Loader

## Introduction

The file “rf2_import_full_template.sql” is a MySQL import script for the FULL view of the International Release It is now being made available by the SNOMED International Education and Product Support Team. You are free to use it under an Apache 2.0 License.

The script is provided in a template form, which means you need to edit it to make two replacements described in this document. These replacements tell the script where to find the RF2 release file folder on your system and the release date (as this is part of the release file names).

It creates tables, loads SNOMED CT FULL release files, indexes, adds some optimizations and creates a useful views that enable access to SNAPSHOT views of commonly required data for different dates.

It has worked well in the past but it is not the only MySQL import script that exists for this purpose and it is not guaranteed to work on any given version as it may need adjustments for file changes. However, it has been posted here after requests from attendees at a recent E-Learning Webinar. 

These scripts are is not formally supported by SNOMED International but as part of our on going commitment to Education, updates may be made from time-to-time. If you are an established MySQL user you should be able to figure out what it is doing and where appropriate adapt or enhance the scripts to meet your requirements. Please share your adaptations using GitHub. Thank you. 

The file “rf2_import_tc_template.sql” included in the package is a similar script that imports the Transitive Closure Table: You first need to create this using the Transitive Closure Script which (unlike the main script) is only able to read from the SNAPSHOT version of the files.

These scripts are Apache licensed which means you are free to reuse, modify it etc.  If make improvements it or develop a completely different (better) option please go ahead. Please share your adaptations using GitHub. Thank you. 

## Comment

Most examples in the SNOMED CT Terminology Services Guide http://snomed.org/tsg-import were built on the results of this import scripts. Furthermore, during 2017 a more detailed guide to importing release files will be developed based on these scripts.

## Install MySQL Community Edition

Use the MySQL Community Edition installer for your enviornment (see https://www.mysql.com/products/community/)  
- Choose and install the correct versions your operating system (and OS version)
- Be sure to select the option to install MySQL Workbench as well as the Server.

## Download the SNOMED CT Release Files

Before importing you need to download and unzip the SNOMED CT International Release RF2 files. You will need a SNOMED CT licence to do this see http://snomed.org/license

- Before importing the Transitive Closure you also need to generated the transitive closure file using the transitive closure Perl script. This must be generated from the SNAPSHOT file (unlike the main import which works with the FULL release)

As currently configured the script imports the FULL release from folder: 

- $PATH$/SnomedCT_RF2Release_INT_$YYYYMMDD$/

Also refers to individual release file using $YYYYMMDD$ as the release date. Therefore, before you use the script you need to create copies of these files with the $PATH$ and $YYYYMMDD$ replaced with the correct values

1. Make copies of the two template files (rf2_import_full_template.sql and rf2_import_tc_template.sql).
    - Include the release date in the names of the copied templates (e.g rf2_import_full_20170731.sql)
2. In your copies make the following global replacements using a suitable text editor:
    1. Adjust source folder by $PATH$ with the path in which the release file is present (e.g. '/User/name/snomed_release_files' or 'C:\mypath\snomed_release_files')
    2. Adjust release date by replacing all instances of $YYYYMMDD$ with appropriate Release Date (eg. 20170731)
    
3. In the full import file you will find lines that look like this. Make sure there are two lines for the date of your current release. If not add copies of these lines with the relevant release date added.

    INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 1,900000000000509007,'YYYY-MM-DD',0,'YYYY-MM-DD Lang:en-US'$$
    INSERT INTO `config` (`id`,`languageId`,`versionTime`,`active`,`name`) SELECT 2,900000000000508004,'YYYY-MM-DD',0,'YYYY-MM-DD Lang:en-GB'$$

### Note

These lines create a configuration for setting a snapshot view for those dates
in each of the languages or dialect in the import (en-US and en-GB).

The active date for the optimized SNAPSHOT view is specified by updating this ‘config’ table as follows

- Set active=0 for all rows
- Set active=1 for the row for the data and language required to be used as the default

## Running the script

Open the script in MySQL Workbench.

## Database and Tables

The database created is called: snomedct

The table names directly derived from the release files are prefixed "sct_"

The transitive closer table is a snapshot view and is prefixed "ss_"

## Optimized and Simplified Views

You will find the script creates a variety of optimised views of the database tables. 

These have the following prefixes:

- sva_: Snapshot view for latest date
- soa_: Snapshot view for latest date - optimised (usually but not always faster than sva)
- svx_: Snapshot view for specified* date
  sox_: Snapshot view for specified* date - optimised (usually but not always faster than sva)

* The specified date (and language) is set in the table called: config
Only one of the many rows in the table should have the value: active=1 and that is the row that will be used to determine the active configuration Language and ShapshotTime for the views.

In addition to the table based views there are some useful combined views:

These names follow the relevant prefix noted above:

-_fsn: view of descriptions that are fully specified names (preferred in config language)
-_pref: the preferred synonyms (preferred in config language)
-_syn: all acceptable synonyms (in config language)
-_synall: all preferred or acceptable synonyms

There are also three types of relationship views with fsn or preferred term:

-_rel_child_(fsn|pref): Subtype children of a selected concept
-_rel_parent_(fsn|pref): Subtype children of a selected concept
-_rel_def_(fns|pref): All defining relationships of a selected concept

In each case the relevant concepts are shown using either the fully specified name or preferred term based on the following suffix.

