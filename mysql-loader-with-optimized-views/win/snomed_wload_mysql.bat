@echo off
:: Windows Script for SnomedRfsMySql import of SNOMED CT Release File.
:: (c) Copyright 2020 SNOMED International 
:: Licenced under the terms of Apache 2.0 licence.
::
:: This script does the following:
::   1. Sets variables for locating and processing other files required for processing
::   2. Collects user input:
::        Essential: Release package zip archive or folder location
::        Required with defaults: Database name (snomedct), MySQL username (root), MySQL template script key (VP_latest)
::   3. Unzips the Release Package (unless already unzipped)
::   4. Builds a Snapshot transitive closure file using a Perl script (requires Strawberry Perl to be installed)
::   5. Creates a custom SQL script for a specified (or default) MySQL template script
::        The customizations relate to references to release package location, release date and database name
::   6. Invokes the mysql.exe command line application to run the SQL script. This does the following:
::        a) Creates the database with tables for each of the files to be imported
::        b) Imports data from the release files into these tables
::        c) Creates views of all the tables to provide convenient SQL access to snapshot and delta views
::        d) Creates composite views that facilitate access to concepts with descriptions and relationships
::        e) Creates composite views the enable review of historical data associated with inactivated concepts and descriptions
::        f) Indexes all the main tables in ways that enable efficient access
::        g) Imports the generated Transitive Closure snapshow into a table
::        h) Creates views that facilitate access to subtype testing and identification of proximal primitives
::        i) Creates stored procedures that illustrate searches for concept by text and constraints

:: Prerequisites:
::   A licensed download of a SNOMED CT Edition (note: the accompanying SQL template is designed for use with the International Edition)
::   Installation of MySQL Community Edition server (recommended version 8.0.17 or later but should also work with version 5.7)
::      The MySQL server need to running with a specified configuration (see documentation and the snomed_wconfig_mysql.bat file)
::   Installation of Strawberry Perl
::   At least 10Gb of free disk space (Release archive 0.5 Gb, Unzipped 3.5 Gb, Database 5.6 Gb)

:: Start new logfile.
:: Rename and retain most recent previous logfile
set logfile=%HOMEDRIVE%%HOMEPATH%\sct_load_mysql.log
set prevlog=%HOMEDRIVE%%HOMEPATH%\sct_load_mysql_old.log
2>nul del /f %prevlog% 
2>nul rename %logfile% %prevlog%
echo. >%logfile%

call:printlog "\nSNOMED CT Release Files MySql Loader - Started\nInitializing variables"
call:printf "\nSNOMED CT Release Files MySql Loader - Started\n\t(Log file: %logfile%)\n\nInitializing variables"

setlocal EnableDelayedExpansion

:: SET FOLDER PATH VARIABLES
set "winpath=%~dp0"
pushd "%winpath%"
:: loaderFolder is the SnomedRfsMySql folder containing relevant subfolders
cd ..
set "loaderFolder=%cd%"
set "mysqlload=mysql_load"

:: Set Placeholder variables for substitution in SQL file
set "phRelpath=$RELPATH"
set "phDbname=$DBNAME"
set "phReldate=$RELDATE"

:: Establish the location of Perl executables
echo on
call:printf "\nChecking for required software Perl and MySQL Server"
call:printLog "Checking for required software Perl and MySQL Server"

if exist "!winpath!perlPath.cfg" (
    set /p perlPath=<"!winpath!perlPath.cfg"
    if not exist !perlPath! (
        set perlPath=
        del /f "!winpath!perlPath.cfg"
    )
)

if not DEFINED perlPath (
    set perlPath="C:\Strawberry\perl\bin\perl.exe"
    if not exist !perlPath! (
        set perlPath=""
        call:getFilePath perl.exe perlPath
        REM Report error is no perl.exe is found.
        if "!perlPath!"=="NOT FOUND" (
            call:printLog "Unable to find perl.exe"
            call:printf "\nUnable to find perl.exe\nThis is required to run this process.\n\tPlease install Strawberry Perl (http://strawberryperl.com/) and then retry"
            exit /b 1
        )
    )
    REM Save path for quick reuse
    echo !perlPath! >"!winpath!perlPath.cfg"
)
call:printf "\tPERL Path:\t !perlPath!"
call:printLog "PERL Found: !perlPath!"

if exist "!winpath!mysqlPath.cfg" (
    set /p mysqlPath=<"!winpath!mysqlPath.cfg"
    if not exist !mysqlPath! (
        set mysqlPath=
        del /f "!winpath!mysqlPath.cfg"
    )
)
if not DEFINED mysqlPath (
REM Establish the location of MySQL Sever executables
    set mysqlPath=""
    call:getFilePath mysql.exe Server mysqlPath
    if "!mysqlPath!"=="NOT FOUND" (
        call:printLog "Unable to find mysql.exe"
        call:printf "\nUnable to find mysql.exe - Cannot import the data.\n\tPlease install MySQL Community Server and Workbench\n\t(https://dev.mysql.com/downloads/mysql/).\n\tThen configure in line with SnomedRfsMySql recommendations\n\tbefore retrying this import process".
        exit /b 1
    )
    REM Save path for quick reuse
    echo !mysqlPath! >"!winpath!mysqlPath.cfg"
)
call:printf "\tMySQL Path:\t !mysqlPath!"
call:printLog "MySQL Found !mysqlPath!"

:: Get source script prefix from input or default
set /P loadKey="Loader script identifying tag (default: create_InternationalRF2): "
if "a%loadKey%"=="a" (
    set "loadkey=create_InternationalRF2"
)
echo %loadKey%

if "%loadKey:~0,6%" neq "update" (
    REM Get Release Path
    call:printf "\nEnter the full path to the SNOMED CT Release Package folder or zip archive"
    set /P thisRelease="Release folder or zip archive path: "
    echo  !thisRelease!
    REM Get valid Unix style version of thisRelease for use in SQL
    REM Then revise theRelease to ensure it uses only backslashes
    set thisRelease=!thisRelease:.zip=!
    set thisReleaseSql=!thisRelease:\=/!
    set thisRelease=!thisRelease:/=\!
    REM Set releasePackage and releaseRoot variables from thisRelease
    for %%A in (!thisRelease!) do (
        set releasePackage=%%~nA
        set releaseRoot=%%~dpA
    )
    REM Set thisReldate from releasePackage
    set "thisReldate=!releasePackage:*20=!"
    set thisReldate=20!thisReldate:~0,6!
)


:: Get database name from input or default
set /P dbname="Database name (default: snomedct): "
if "a%dbname%"=="a" (
    set dbname=snomedct
)

:: Get MySql username from input or default
set /P mysqluser="MySQL User Name (default: root): "
if "a%mysqluser%"=="a" (
    set "mysqluser=root"
)
:: Add selected options to logfile
call:printlog "Release Path\t!thisRelease!\nDatabase Name\t%dbname%\nLoad Script Key\t%loadkey%\nSQL User\t%sqluser%\n\n"
:: Check the existence and validity of the specfied release path
:: If the release folder does not exist but the zip does then unzip the package
if not exist "%thisRelease%\" (
   if exist %thisRelease%.zip (
      call:printlog "Unzipping release package file:\n\t%thisRelease%.zip"
      call:printf "\nUnzipping release package file:\n\t%thisRelease%.zip"
      Call:UnzipFile "%releaseRoot%" "%thisRelease%.zip"   
   ) else (
      call:printf "\nError! No folder or zip file for:\n\t%thisRelease%"
      call:printlog "Error! No folder or zip file for:\n\t%thisRelease%"
      exit /b
   )
) else (
    call:printf "\nRelease package found:\t%thisRelease%"
    call:printlog "Release package found:\t%thisRelease%"
)

:: Check the release folder contains Full and Snapshot releases
if not exist "%thisRelease%\Full" (
    call:printf "\nError! No Full folder in release package"
    call:printlog "Error! No Full folder in release package" 
    exit /b
)
if not exist "%thisRelease%\Snapshot" (
    call:printf "\nError! No Snapshot folder in release package"
    call:printlog "Error! No Snapshot folder in release package" 
    exit /b
)

:: Run Perl Script to create Transitive Closure file

:: Find the Relationship File - tc_source
set tmpfile="%temp%\wltmp.txt"
pushd %thisRelease%\Snapshot\Terminology
setlocal EnableDelayedExpansion
set tpath=%thisRelease%\Snapshot\Terminology
set tc_source=""
:: Locate the snapshot relationships file in the termilogy path.
call:getFilePath "%tpath%\sct2_Relationship_..." "Snapshot" tc_source
if "!tc_source!"=="NOT FOUND" (
REM Report error if Snapshot Relationships file cannot be found. This should not happen!
    call:printf "\nError! No Snapshot Relationship file in release package"
    call:printLog "Error! No Snapshot Relationship file in release package"
    exit /b
)
:: Get the name for the Transitive Closure file based on the name of the relationships file
set "tc_target=%thisRelease%\xder_transitiveClosure%tc_source:*_Relationship=%"

:: If the Transitive Closure file is already there offer option to rebuild (useful if build was interrupted)
if exist %tc_target% (
    call:printf "\nTransitive Closure file exists\nUnless an error occured previously you should keep and reuse this file."
    set /P rebuild="Rebuild transitive closure file? (Default=no use existing, Enter Y to rebuild) ? "
) else (
    set "rebuild=B"
)
set "rebuild=%rebuild%n"
if %rebuild:~0,1%==y (
    set "rebuild=Y"
)
:: Depening on choices made either delete of retain existing transitive closure
if %rebuild:~0,1%==Y (
    call:printf "\nDeleting existing transitive closure file."
    call:printLog "Deleting existing transitive closure file."
    del %tc_target%
) else if exist %tc_target% (
    call:printf "\nKeeping existing transitive closure file."
    call:printLog "Keeping existing transitive closure file."
)

if not exist %tc_target% (
    call:printLog "Transitive Closure File generation is in progress."
    call:printf "\nTransitive Closure File generation is in progress.\n\tPlease wait until this completes.\n\tYou will then need to enter your MySQL password to allow the process to continue."
    "!perlPath!" "!loaderFolder!\lib\transitiveClosureRf2SnapMulti.pl" "!tc_source!" "!tc_target!"
    call:printLog "Transitive Closure File generation completed."
    call:printf "\nTransitive Closure File generation completed."
)

if exist %tc_target% (
	set "notc="
) else (
	set "notc=-- NO TC"
)

echo %notc%

:: Process the SQL template source script to generate the script to be run.
:: Set sql_file and sql_tmp names for SQL file substitution process
set "sql_file=!loaderFolder!\!mysqlload!\sct_mysql_load_!loadKey!.sql"

set "sql_tmp=!loaderFolder!\!mysqlload!\sct_mysql_wtemp.sql"


call:printf "\nGenerating local SQL import script:\n\t!sql_tmp!\nfrom SQL template: !sql_file!"
call:printLog "Generating local SQL import script:\n\t!sql_tmp!\nfrom SQL template: !sql_file!"

:: This section does the substitutions for the three placeholders in templace SQL script
:: Additional placeholders could be added if required using additional set line statement with a similar
:: The process uses Perl on the basis that this is required anyway for transitive closure processing. 
:: In each case: 
::     %phXXXX% variable holds the placeholder text 
::     %xxxx%   variable hold the replacement text collected from user input

set sedPattern="s#\$DBNAME#%dbname%#g;s#\$RELDATE#%thisReldate%#g;s#\$RELPATH#%thisReleaseSql%#g;s#\$NOTC#%notc%#g"
type %sql_file% | %perlPath% -pe %sedPattern% >"%sql_tmp%"

:: End of MySQL Script generation from template

:: Run the MySQL import process
call:printLog "Starting the SNOMED CT MySQL import process"
call:printf "\nStarting the SNOMED CT MySQL import process\n\nPlease enter the MySQL password for you chosen MySQL user account: %mysqluser%\n\nAfter you have done this the process will continue without further user input.\n\nDepending on your system performance this may take between 20 minutes and 90 minutes to complete"
call:printLog "!mysqlPath! --default-character-set=utf8mb4 --local-infile=1 --comments --password --user !mysqluser!   <!sql_tmp!"

"!mysqlPath!" --default-character-set=utf8mb4 --local-infile=1 --comments --password --user !mysqluser!   <"!sql_tmp!"

:: Final steps and completion
popd
call:printLog "MySQL Import Process complete"
call:printf "\nProcess complete\n\nYou can now view your database in MySQL Workbench\n"
exit /b

:: ------------------------::
:: END OF THE MAIN PROCESS ::
:: ------------------------::

:: --------------------------------------------::
::  PROCEDURES USED IN THE ABOVE BATCH PROCESS ::
:: --------------------------------------------::
:: This section contains all the procedures called in the script above.
:: These procedures are essential for the correct operation of the script.
:: -----------------::
:: PRINTF PROCEDURE ::
:: -----------------::
:: Unix printf equivalent procedure. Removes quotes in output and adds new line for \n

:printf
:: Emulate key elements of the Unix printf command
@echo off
:: Get the tab character into an environment variable
set /A args=0
for %%x in (%*) do set /A args+=1
setlocal
if %args% gtr 1 (
    set "text=%~1"
    :LOOP
        if "%~2"=="" GOTO ENDLOOP
        set "text=!text! %~2"
        shift
    GOTO LOOP
    :ENDLOOP
    call:printf "%text%"
    exit /b
endlocal
)
:: Note the tabfile is used as a source of the TAB character
set /p tab=<%~dp0\tabfile.tmp
set tab=%tab:~5,1%
setlocal EnableDelayedExpansion
set text=%1
set text=%text:"=%
set text=%text:\t=!tab!%
echo.%text:\n= &echo.%
exit /b

:: ------------------------::
:: GET-FILE-PATH PROCEDURE ::
:: ------------------------::
:: Gets path to file: 
::   if .exe in %programfiles% or %programfiles(x86)%
:: 

:getFilePath <searchfile> <Optional filter> <foundfile>
@echo off
set /A args=0
for %%x in (%*) do set /A args+=1
set paramHelp="Function getFilePath must have 2 or 3 parameters. IN searchfile-or-path IN Optional filter-text OUT found-file-location"
if %args% lss 2 (
    call:printf "Error! Too few parameters\n" %paramHelp%
    exit /b
) else if %args% gtr 3 (
    call:printf "Error! Too many parameters\n" %paramHelp%
    exit /b
)
set foundfile=""
set searchvar=%~1
set filter=%~2
set searchname=%~nx1
set searchnameonly=%~n1
set searchext=%~x1
setlocal EnableDelayedExpansion
if %searchvar:*...=X%==X (
    set searchpath=%searchvar%
) else if %searchvar:~1,1%==":" (
    set searchpath=%searchvar% 
) else if %searchvar:~0,1%=="\" (
    set searchpath=%~d1%searchvar% 
) else (
    set searchpath=%~d1\%searchvar%
)
set result=0
if "%searchext%"==".exe" (
    if %args%==2 (
        call:findFile "%programfiles%\%searchname%" result
    ) else (
        call:findFile "%programfiles%\%searchname%" "%filter%" result
    )
    if !result!==0 (
        if %args%==2 (
            call:findFile "%programfiles(x86)%\%searchname%" result
        ) else (
            call:findFile "%programfiles(x86)%\%searchname%" "%filter%" result
        )
    )
)
if !result!==0 (
    if %args%==2 (
        call:findFile "!searchpath!" result
    ) else (
        call:findFile "!searchpath!" "%filter%" result
        )
)
if !result!==0 (
    endlocal
    set result="!Error file not found: %searchvar%"
    
    if %args%==2 (
        set "%2=NOT FOUND"
    ) else (
        set "%3=NOT FOUND"
    )
    exit /b
)
endlocal
call:head "%temp%\prog_path.txt" 1 foundfile
if %args%==2 (
    set "%2=!foundfile!"
) else (
    set "%3=!foundfile!"
)
exit /b

::----------------------::
:: FILE FIND PROCEDURE  ::
::----------------------::
:findFile <searchpath> <OPTIONAL filter> <result>
@echo off
set /A args=0
for %%x in (%*) do set /A args+=1
set paramHelp="Function findFile must have 2 or 3 parameters. IN searchfile-or-path IN Optional filter-text OUT found-file-location"
    if %args% lss 2 (
        call:printf "Error! Too few parameters\n %paramHelp%"
        exit /b
    ) else if %args% gtr 3 (
        call:printf "Error! Too many parameters\n %paramHelp%"
        exit /b
    )
    setlocal
    set "searchpath=%~1"
    set "filter=%~2"
    if %args%==2 (
        dir /b /s "%searchpath:...=*%" 2>nul >%temp%\prog_path.txt
    ) else (
        dir /b /s "%searchpath:...=*%" 2>nul| find "%filter%" >%temp%\prog_path.txt
    )
    endlocal
    call:fileSize %temp%\prog_path.txt result
    if %args%==2 set %2=%result%
    if %args%==3 set %3=%result%
exit /b

::---------------------::
:: FILE SIZE PROCEDURE ::
::---------------------::

:fileSize <file> <result>
@echo off
set %2=%~z1
exit /b

:: ---------------::
:: HEAD PROCEDURE ::
:: ---------------::
:: Returns first x lines from a specified file

:head <file> <lines> <result>
@echo off
setlocal EnableExtensions EnableDelayedExpansion
set file=%1
set /a lines=%2
set /a fcount=0
for /f "usebackq tokens=*" %%i in (%file%) do (
  if not !fcount!==%lines% (
      if !fcount!==0 (
        endlocal
        set "result=%%~i"
      ) else (
        endlocal
        set /p result=<echo !result! & echo. %%~i
      )
      set /a fcount+=1
  )
)
set "%3=!result!"
exit /b
:: ----------------::
:: Log Printer     ::
:: ----------------::
:printlog <args>
>>%logfile% call:printf "%DATE:~-4%%DATE:~4,2%%DATE:~7,2%T%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%\n"%*
exit /b
:: ----------------::
:: UNZIP PROCEDURE ::
:: ----------------::
:: Called if needed to unzip the release package archive
:: Note: This procedure uses VBS

:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\unzip_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%
exit /b

::------------------::
:: END OF FUNCTIONS ::
:: END OF SCRIPT    ::
::------------------::
:debug
    setlocal EnableDelayedExpansion
    set foundfile=""
    call:getFilePath perl.exe foundfile
    echo perl.exe!foundfile!
    call:getFilePath nofile.exe foundfile
    echo nofile.exe !foundfile!
    call:getFilePath mysql.exe Server foundfile
    echo mysql.exe!foundfile!
    call:getFilePath "C:\SnomedCT_ReleaseFiles\SnomedCT_InternationalRF2_PRODUCTION_20190731T120000Z%\Snapshot\Terminology\sct2_Relationship..." "Snapshot" foundfile
    echo snap_rels !foundfile!
    endlocal
	exit /b