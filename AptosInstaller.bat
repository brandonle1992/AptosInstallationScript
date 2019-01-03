REM Author: Brandon Le

@echo off
call :Resume
goto %current%
goto :eof

:one
ECHO Installing Epicor/Aptos Retail Software
Echo ------------------------------------------
Echo    1. Check UAC
Echo    2. Set Current User to Admin
Echo    3. Prerequisite Check
Echo    4. CodeSoft Install
Echo    5. Install NSB (New Install)
Echo    6. Upgrade NSB (Upgrade Install)
Echo    7. MA Application
Echo    8. Sales Audit
ECHO    9. Fix Aptos Print
Echo ------------------------------------------
Set /p selection=Please select your operation (e.g. 1, 2):
If %selection% == 1 Goto CheckUAC
if %selection% == 2 Goto SetAdmin
if %selection% == 3 Goto PrerequisiteCheck
if %selection% == 4 Goto CodeSoftInstall
if %selection% == 5 Goto INSB
if %selection% == 6 Goto UpgradeINSB
if %selection% == 7 Goto MAInstall
if %selection% == 8 Goto SalesAudit
if %selection% == 9 Goto PrintFix
Cls
Echo You have entered a wrong operation. Please choose the right operation. & Goto Top

REM This part will check and promote user to administrator, configure IE Settings, Server connectiong via ODBC, and install a specific file when OS Version is 10
:PrerequisiteCheck
net localgroup administrators Sixflags\%username% /delete
call :IESite
call :ODBCSettings
call :Win10Req

:SetAdmin
net localgroup administrators Sixflags\%username% /add
if %ERRORLEVEL% EQU 0 ( ECHO Success on adding %username% to administrators group. ) ELSE ( ECHO ERROR. Something went wrong. )
set /p logoffChoice=Effects require the user to log off. Do it now? (y/n):
if "%logoffChoice%" == "y" goto LogOff
if "%logoffChoice%" == "n" goto Message
goto SetAdmin

:CheckUAC
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA') do for %%C in (%%a) DO SET _var=%%C
if %_var% == 0x1 goto UACEnableMenu
if %_var% == 0x0 goto UACDisableMenu

:UACEnableMenu
echo UAC is enabled. Epicor/Aptos requires it to be off.
Echo --------------------------------------------------
Echo    1. Disabled UAC
ECHO    2. Continue
Echo --------------------------------------------------
Set /p choice=Please select your operation (e.g. 1, 2):
if %choice% == 1 Goto DisableUAC
if %choice% == 2 Goto one
goto one

:UACDisableMenu
echo UAC is disabled. Epicor/Aptos requires it to be off.
Echo --------------------------------------------------
Echo    1. Enable UAC
ECHO    2. Continue
Echo --------------------------------------------------
Set /p choice=Please select your operation (e.g. 1, 2):
if %choice% == 1 Goto Enable
if %choice% == 2 Goto one
goto one

:DisableUAC
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
set /p shutdownChoice=Effects require a restart. Do it now? (y/n):
if /i "%shutdownChoice%" == "y" goto :Shutdown
if /i "%shutdownChoice%" == "n" goto Message
goto DisableUAC

:Message
cls
echo Please restart/log off for the effect to take changes.
pause > NUL
goto :eof

:LogOff
shutdown /l /f
:Shutdown
shutdown /r /c "Restarting for UAC Disable. This script will run again after logging back in."

:EnableUAC
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
set /p shutdownChoice=Effects require a restart. Do it now? (y/n):
if "%shutdownChoice%" == "y" goto :Shutdown
if "%shutdownChoice%" == "n" goto Message
goto EnableUAC

:CodeSoftInstall
start "" "\\servername\Epicor\CODESOFT20120001WEB.exe"
timeout 5 > NUL
pause
goto :one


:PrintFix
takeown /F "C:\Windows\Downloaded Program Files" /A
icacls "C:\Windows\Downloaded Program Files" /grant Users:(OI)(CI)M /T
icacls "C:\Windows\Downloaded Program Files" /setowner "NT SERVICE\TrustedInstaller"

copy "\\servername\Aptos\PrintFiles\*.*" "C:\Windows\Downloaded Program Files"
copy "\\servername\Aptos\PrintFiles\*.*" C:\Windows\System32
copy "\\servername\Aptos\PrintFiles\*.*" C:\Windows\SysWoW64

Regsvr32 "C:\Windows\Downloaded Program Files"\rsclientprint.dll
Regsvr32 c:\Windows\system32\rsclientprint.dll
Regsvr32 c:\Windows\syswow64\rsclientprint.dll
goto :one

:INSB
     REM --------------------------------------------------
     REM *********** Merchandising Installation ***********
     REM --------------------------------------------------

echo Install Merchandising Application...
start "" "\\servername\deploy\Retail 8.3\32-bit\Live\setup.exe"
timeout 5 > NUL
pause
goto :one

:UpgradeINSB
echo Upgrading Merchandising Application...
start "" "\\servername\deploy\Retail 8.3\32-bit\Live\EpicorRetail.application"
timeout 5 > NUL
pause
goto :one

:IESite
echo Configuring IE Settings....
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\servername" /v "http" /t REG_DWORD /d 2 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "2702" /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1208" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1209" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "2201" /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1201" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1200" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "270C" /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "2000" /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1001" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1004" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "1405" /t REG_DWORD /d 0 /f
goto :eof



:ODBCSettings
     REM --------------------------------------------------
     REM **************** ODBC & CliConfig ****************
     REM --------------------------------------------------

echo Setting up SQL Server settings for Queries Designer and Report Designer...
reg add HKLM\Software\ODBC\ODBC.INI\Foundation /f
reg add "HKLM\Software\ODBC\ODBC.INI\ODBC Data Sources" /v Foundation /t REG_SZ /d "SQL Server" /f
reg add HKLM\Software\ODBC\ODBC.INI\Foundation /v Database /t REG_SZ /d "fn_xpr_01" /f
reg add HKLM\Software\ODBC\ODBC.INI\Foundation /v Description /t REG_SZ /d "Foundation" /f
reg add HKLM\Software\ODBC\ODBC.INI\Foundation /v Driver /t REG_SZ /d "C:\WINDOWS\system32\SQLSRV32.dll" /f
reg add HKLM\Software\ODBC\ODBC.INI\Foundation /v LastUser /t REG_SZ /d "PLACEHOLDER" /f
reg add HKLM\Software\ODBC\ODBC.INI\Foundation /v Server /t REG_SZ /d "DCSQLAPTOS01" /f

reg add HKLM\Software\Wow6432Node\ODBC\ODBC.INI\Foundation /f
reg add "HKLM\Software\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" /v Foundation /t REG_SZ /d "SQL Server" /f
reg add HKLM\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\Foundation /v Database /t REG_SZ /d "fn_xpr_01" /f
reg add HKLM\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\Foundation /v Description /t REG_SZ /d "Foundation" /f
reg add HKLM\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\Foundation /v Driver /t REG_SZ /d "C:\WINDOWS\system32\SQLSRV32.dll" /f
reg add HKLM\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\Foundation /v LastUser /t REG_SZ /d "PLACEHOLDER" /f
reg add HKLM\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\Foundation /v Server /t REG_SZ /d "DCSQLAPTOS01" /f

reg add HKLM\Software\Microsoft\MSSQLServer\Client\ConnectTo /v DCSQLAPTOS01 /t REG_SZ /d "DBMSSOCN,DCSQLAPTOS01,1433" /f
reg add HKLM\Software\Wow6432Node\Microsoft\MSSQLServer\Client\ConnectTo /v DCSQLAPTOS01 /t REG_SZ /d "DBMSSOCN,DCSQLAPTOS01,1433" /f
goto :eof

:MAInstall
     REM --------------------------------------------------
     REM ************** SmartLook Front End ***************
     REM --------------------------------------------------

echo Install Queries Designer and Report Designer...
echo -------------------------------------------------------
echo "Installing MSA Application."
echo "Once done, double click the version number."
echo "Metadata Connection tab"
echo "Datasource Name: Foundation"
echo "Username: "
echo "Password: "
echo "Check Save settings to the registry to be used later."
echo "====================="
echo "Options tab"
echo "Metadata Cache Type: Load from the database"
start "" "\\servername\Live\SmartLookQueryDesigner.application"
pause
goto :one

:Win10Req
@echo off
Setlocal
:: Get windows Version numbers
For /f "tokens=2 delims=[]" %%G in ('ver') Do (set _version=%%G) 

For /f "tokens=2 delims=. " %%G in ('echo %_version%') Do (set _major=%%G)

Echo Windows Version : %_major%

if "%_major%" == "10" goto sub10
else goto :one
goto :one

:sub10
powershell -NoExit -Command "DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:d:\sources\sxs" < NUL
goto :one

:SalesAudit
start "" "\\servername\Live\EpicorRetail.application"

:resume
if exist %~dp0current.txt (
    set /p current=<%~dp0current.txt
) else (
    set current=one
)