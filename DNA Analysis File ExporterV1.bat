REM DNA Analysis File Exporter V 1.0
REM By Joe Juette
REM Purpose: Only get the data needed for analysis and presentations. There is no longer the need to upload the entire DNA folder for analysis.
REM File MUST be placed in the DNA.EXE Directory and run it from there. 
REM Select the operation.
REM When Creating the packages you will be asked if this is realated to a File or Directory ALWAYS select D for Directory.
REM Complete Analysis Package Copies the Report Directory and the DNA Map Files To Analysis_Package Folder.
REM Reports Package Copies only the Report Directory to the Reports_Package Folder.
REM DNA MAP Package Copies only the .gz Files from the DNA Map Directory to the Map_Package Folder.
REM Logs Package Copies only the Log Directory and Subdirectories to the Logs_Package Folder.
REM Troubleshooting Package Copies the Log Directory, DNA.exe.config, and the DNA.DbObfuscation.log to the Troubleshooting_Package Folder.
REM Once Completed Zip the nessesary Package Folders and send them to the CyberArk Engineer for further analysis.


ECHO OFF
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
)
set"var=%cd%"
CLS
md Packages_To_Send
:MENU
ECHO.
ECHO.............................
ECHO PRESS 1,2,3,4,5 or 6 to Exit
ECHO.............................
ECHO.
ECHO 1 - Create Complete Analysis Package
ECHO 2 - Create a Report Package
ECHO 3 - Create a DNA MAP Package
ECHO 4 - Create a Logs Package
ECHO 5 - Create a Troubleshooting Package
ECHO 6 - Exit
ECHO.
ECHO Once finished creating the packages, make sure you zip them up. 
ECHO.
call :colorEcho 06 "When Asked Does a package specify a file name or directory name on the target ALWAYS select D for Directory."
ECHO.
SET /P M=Type 1, 2, 3, 4, 5, 6 then press ENTER:
IF %M%==1 GOTO Analysis
IF %M%==2 GOTO Report
IF %M%==3 GOTO Map
IF %M%==4 GOTO Logs
IF %M%==5 GOTO TS
IF %M%==6 GOTO EOF
:Analysis
xcopy Reports Packages_To_Send\Analysis_Package
copy "DNA Map"\*.gz Packages_To_Send\Analysis_Package
GOTO MENU 
:Report
xcopy Reports Packages_To_Send\Reports_Package
GOTO MENU
:Map
md Packages_To_Send\Map_Package
copy "DNA MAP"\*.gz Packages_To_Send\Map_Package
GOTO MENU
:Logs
xcopy /S Log Packages_To_Send\Logs_Package
copy DNA.DbObfuscation.log Packages_To_Send\Logs_Package
GOTO MENU
:TS
xcopy /S Log Packages_To_Send\Troubleshooting_Package
copy DNA.exe.config Packages_To_Send\Troubleshooting_Package
copy DNA.DbObfuscation.log Packages_To_Send\Troubleshooting_Package
GOTO MENU

:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2""
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i