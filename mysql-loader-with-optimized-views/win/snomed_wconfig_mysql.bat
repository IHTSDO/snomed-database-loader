@echo off

setlocal
set mydate=%date:~10,4%%date:~4,2%%date:~7,2%
if "%time:~0,1%"==" " (
    set mytime=%mydate%0%time:~1,1%%time:~3,2%%time:~6,2%
) else (
    set mytime=%mydate%%time:~0,2%%time:~3,2%%time:~6,2%
)
set initial_path=%cd%
set batch_path=%~dp0

for /f %%i in ('certUtil -hashfile "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" MD5') do (
    set result=1
    if %%i==CertUtil: ( 
        set cx=1
        )  else if %%i==MD5 (
        set cx=1
        ) else (
        set inicur=%%i)
    )

for /f %%i in ('certUtil -hashfile "%batch_path%\snomed_win_my.ini" MD5') do (
    if %%i==CertUtil: (
        set cx=1
        )  else if %%i==MD5 (
        set cx=1
        ) else (
        set ininew=%%i)
    )
if not %inicur%==%ininew% (
cd "C:\ProgramData\MySQL\MySQL Server 8.0"
rename my.ini my_pre_%mytime%.ini
cd %batch_path%
echo Copying "%batch_path%snomed_win_my.ini" to "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini".
copy snomed_win_my.ini "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini"
cd %initial_path%
) else (
    echo File "%batch_path%snomed_win_my.ini" already matches "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini".
)
endlocal