@echo off

REM Batch file to create tables and import to them from provided SNOMED 
REM Terminoology files
REM Copyright Chris Tillman 2018, licensed under GPL any version

REM Set the variables appropriately for your system

REM Set the path where SQL and batch scripts live
SET SCRIPT_PATH=E:\EncounterPro\SNOMED\MSSQL

REM The server designation, this one is a local SQL SERVER Express I access through Windows user permisson
SET MSSQLSERVER=DESKTOP-GU15HUD\ENCOUNTERPRO

REM The path the import files were extracted into ... if you have spaces in the path, the script will fail
SET IMPORT_FILE_PATH=E:\EncounterPro\SNOMED\SnomedCT_USEditionRF2_PRODUCTION_20180301T183000Z

REM The YYYYMMDD which makes up part of the filename.
SET YYYYMMDD=20180301

REM The representation of the specialization of the data which makes up part of the filename
REM (in this case it is the U.S. subset from UMLS)
SET LOCAL_ID=US1000124

REM Language (sometimes part of the filename)
SET SNOMED_LANG=en

REM The type of import, again part of the filename. Could be Snapshot, Full, or Delta
SET IMPORT_TYPE=Snapshot

REM In order to import UTF-8 files to SQL Server, you need a recent version of bcp. Microsoft didn't
REM get around to providing for UTF-8 files until 2016. It works with earlier SQL server versions.

REM Command Line Utilities 14.0  https://www.microsoft.com/en-us/download/details.aspx?id=53591
REM ODBC Driver 13.1  https://www.microsoft.com/en-us/download/details.aspx?id=53339
REM Windows Installer 14.5  https://www.microsoft.com/en-us/download/details.aspx?id=8483

REM The installed path to UTF-8 compatible bcp. This is the 64-bit version.
SET PATH_TO_BCP="C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\bcp.exe"

REM Execute the table setup script. You must not be connected to the snomedct database in another program.
sqlcmd -i "%SCRIPT_PATH%\create_snomed_tables.sql" -S %MSSQLSERVER% -d master -E

REM Import the data. -C 65001 chooses UTF8, -T is trusted connection, -c results in no format files being needed, -F 2 means skip the first line which has column names.
%PATH_TO_BCP% sct2_concept in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Terminology\sct2_Concept_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
%PATH_TO_BCP% sct2_description in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Terminology\sct2_Description_%IMPORT_TYPE%-%SNOMED_LANG%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
%PATH_TO_BCP% sct2_identifier in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Terminology\sct2_Identifier_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
%PATH_TO_BCP% sct2_statedrelationship in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Terminology\sct2_StatedRelationship_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
%PATH_TO_BCP% sct2_textdefinition in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Terminology\sct2_TextDefinition_%IMPORT_TYPE%-%SNOMED_LANG%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
%PATH_TO_BCP% sct2_relationship in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Terminology\sct2_Relationship_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2

REM I didn't do the refsets, the file names don't quite correspond to the table names from the original MYSQL script ...
REM "%PATH_TO_BCP%" sct2_refset in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_c in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_c_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_cci in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_cci_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_ci in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_ci_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_iisssc in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_iisssc_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_iissscc in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_iissscc_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_s in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_s_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
REM "%PATH_TO_BCP%" sct2_refset_ss in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\Refset\sct2_refset_ss_%IMPORT_TYPE%_%LOCAL_ID%_%YYYYMMDD%.txt" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2

REM Reset the path variable for the ICD coding file
SET IMPORT_TYPE=Documentation

%PATH_TO_BCP% tls_Icd10cmHumanReadableMap in "%IMPORT_FILE_PATH%\%IMPORT_TYPE%\tls_Icd10cmHumanReadableMap_%LOCAL_ID%_%YYYYMMDD%.tsv" -C 65001 -S %MSSQLSERVER% -d snomedct -T -c -F 2
