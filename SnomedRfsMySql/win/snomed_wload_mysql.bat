@echo off

set logfile=%HOMEDRIVE%%HOMEPATH%\snomed_wload_mysql.log
echo >%logfile%
call:printlog "\nSNOMED CT Release Files MySql Loader - Started\nInitializing variables"
call:printf "\nSNOMED CT Release Files MySql Loader - Started\n\t(Log file: %logfile%)\n\nInitializing variables"

setlocal EnableDelayedExpansion
:: SET FOLDER PATH VARIABLE

set "winpath=%~dp0"
pushd "%winpath%"
:: loaderFolder is the SnomedRfsMySql folder containing the win folder
cd ..
set "loaderFolder=%cd%"
set "mysqlload=mysql_load"

:: Set Placeholder variables for substitution in SQL file
set "phRelpath=$RELPATH"
set "phDbname=$DBNAME"
set "phReldate=$RELDATE"

:: Get Release Path
set /P thisRelease="Release folder path? "

:: Get valid Unix style version of thisRelease for use in SQL
:: Then revise theRelease to ensure it uses only backslashes
set thisReleaseSql=%thisRelease:\=/%
set thisRelease=%thisRelease:/=\%

:: Set releasePackage and releaseRoot variables from thisRelease
for %%A in (%thisRelease%) do (
    set releasePackage=%%~nA
    set releaseRoot=%%~dpA
)

:: Set thisReldate from releasePackage
set "thisReldate=%releasePackage:*20=%"

set thisReldate=20%thisReldate:~0,6%


:: Get database name from input or default
set /P dbname="Database name (default: snomedct): "

if "a%dbname%"=="a" (

    set dbname=snomedct

)


:: Get source script prefix from input or default
set /P loadKey="SQL Script (default: VP_latest): "

if "a%loadKey%"=="a" (

    set "loadkey=VP_latest"

)


:: Get MySql username from input or default
set /P mysqluser="MySQL User Name (default: root): "

if "a%mysqluser%"=="a" (

    set "mysqluser=root"

)
call:printlog "Release Path\t%thisRelease%\nDatabase Name\t%dbname%\nLoad Script Key\t%loadkey%\nSQL User\t%sqluser%\n\n"

:: Check the existence and validity of the specfied release path
:: If the release folder does not exist try to unzip zip relevant package
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
set foundfile=""
call:getFilePath "%tpath%\sct2_Relationship..." "Snapshot" foundfile
set tc_source=!foundfile!

:: Get the name for the Transitive Closure file based on the name of the relationships file
set "tc_target=%thisRelease%\xder_transitiveClosure%tc_source:*_Relationship_=%"

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
if %rebuild:~0,1%==Y (
    call:printf "\nDeleting existing transitive closure file."
    call:printLog "Deleting existing transitive closure file."
    del %tc_target%
) else if exist %tc_target% (
    call:printf "\nKeeping existing transitive closure file."
    call:printLog "Keeping existing transitive closure file."
)

if not exist %tc_source% (
     call:printf "\nError! No Snapshot Relationship file in release package"
     call:printLog "Error! No Snapshot Relationship file in release package"
    exit /b
) else if not exist %tc_target% (
    :: Establish the location of Perl executables
    call:printf "\nStarting transitive closure generator"
    call:printLog "Starting transitive closure generator"
    set foundfile=""
    CALL:getFilePath perl.exe foundfile
    set perlpath=!foundfile!
    call:printf "\nPERL Processor Found !perlpath!"
    call:printLog "PERL Processor Found !perlpath!"

    if !perlpath!=="NOT FOUND" (
        call:printLog "Unable to find perl.exe"
        call:printf "\nUnable to find perl.exe - Cannot build transitive closure table file.\n\tPlease install Strawberry Perl (http://strawberryperl.com/) and then retry"
        exit /b 1
    )
    call:printLog "Transitive Closure File generation is in progress."
    call:printf "\nTransitive Closure File generation is in progress.\n\tPlease wait until this completes.\n\tYou will then need to enter your MySQL password to allow the process to continue."
    "!perlpath!" "!loaderFolder!\lib\transitiveClosureRf2SnapMulti.pl" "!tc_source!" "!tc_target!"
    call:printLog "Transitive Closure File generation completed."
    call:printf "\nTransitive Closure File generation completed."
)

:: Establish the location of MySQL Sever executables
set foundfile=""
CALL:getFilePath mysql.exe Server foundfile
set "mysqlPath=!foundfile!"
call:printf "\nMySQL Path: !mysqlPath!"
call:printLog "MySQL Path: !mysqlPath!"
if "!mysqlPath!"=="NOT FOUND" (
    call:printf "\nUnable to find mysql.exe - Cannot import the data.\n\tPlease install MySQL Community Server and Workbench\n\t(https://dev.mysql.com/downloads/mysql/).\n\tThen configure in line with SnomedRfsMySql recommendations\n\tbefore retrying this import process".
    exit /b 1
)
:: Process the SQL template source script to generate the script to be run.
:: Set sql_file and sql_tmp names for SQL file substitution process
set "sql_file=!loaderFolder!\!mysqlload!\sct_mysql_load_!loadKey!.sql"

set "sql_tmp=!loaderFolder!\!mysqlload!\sct_mysql_wtemp.sql"


call:printf "\nGenerating local SQL import script:\n\t!sql_tmp!\nfrom SQL template: !sql_file!"
call:printLog "Generating local SQL import script:\n\t!sql_tmp!\nfrom SQL template: !sql_file!"

 >"!sql_tmp!" echo -- Generated SQL Load Script --

for /f tokens^=*^ delims^=^ eol^= %%i in (!sql_file!) do (
    setlocal EnableDelayedExpansion
    set line=%%i
    set "line=!line:%phRelpath%=%thisReleaseSql%!"
    set "line=!line:%phDbname%=%dbname%!"
    set "line=!line:%phReldate%=%thisReldate%!"
    >>"%sql_tmp%" echo !line! 
    endlocal
)

call:printLog "Starting the SNOMED CT MySQL import process"
:: Run the MySQL import process
call:printf "\nStarting the SNOMED CT MySQL import process\n\nPlease enter the MySQL password for you chosen MySQL user account: %mysqluser%\n\nAfter you have done this the process will continue without further user input.\n\nDepending on your system performance this may take between 20 minutes and 90 minutesto complete"
call:printLog "!mysqlPath! --default-character-set=utf8mb4 --local-infile=1 --comments --password --user !mysqluser!   <!sql_tmp!"

"!mysqlPath!" --default-character-set=utf8mb4 --local-infile=1 --comments --password --user !mysqluser!   <"!sql_tmp!"

:: Final steps and completion
popd
call:printLog "MySQL Import Process complete"
call:printf "\nProcess complete\n\nYou can now view your database in MySQL Workbench\n"
exit /b

:: --------------------------------------------::
::  PROCEDURES USED IN THE ABOVE BATCH PROCESS ::
:: --------------------------------------------::

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

set /p tab=<%~dp0\tabfile.tmp
set tab=%tab:~5,1%
setlocal enableextensions enabledelayedexpansion
set text=%1
set text=%text:"=%
set text=%text:\t=!tab!%
echo %text:\n= &echo.%
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
    exit /b
)
endlocal
CALL:head "%temp%\prog_path.txt" 1 foundfile
if %args%==2 (
    set "%2=%foundfile%"
) else (
    set "%3=%foundfile%"
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
    set foundfile=""
    CALL:getFilePath mysql.exe Server foundfile
    echo !foundfile!
    CALL:getFilePath perl.exe foundfile
    echo !foundfile!
    call:getFilePath "C:\SnomedCT_ReleaseFiles\SnomedCT_InternationalRF2_PRODUCTION_20190731T120000Z%\Snapshot\Terminology\sct2_Relationship..." "Snapshot" foundfile
    echo !foundfile!
exit /b