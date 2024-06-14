@echo off

set key="HKCU\Control Panel\Desktop\WindowMetrics"
call :reg_backup %key%

::taskbar element min width, pixels
call :reg_add %key% /f /v "MinWidth" /d 250
::settings with pixels * -15
call :reg_add %key% /f /v "BorderWidth" /d 0
call :reg_add %key% /f /v "CaptionHeight" /d -270
call :reg_add %key% /f /v "MenuHeight" /d -225
call :reg_add %key% /f /v "ScrollHeight" /d -195
call :reg_add %key% /f /v "ScrollWidth" /d -195
call :reg_add %key% /f /v "PaddedBorderWidth" /d 0

::Tahoma, 8px LOGFONTW structure
set "font_bin=F5FFFFFF00000000000000000000000090010000000000CC000000005400610068006F006D00610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
 
call :reg_add %key% /f /t REG_BINARY /v "CaptionFont" /d %font_bin%
call :reg_add %key% /f /t REG_BINARY /v "MenuFont" /d %font_bin%


set key="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
call :reg_backup %key%
call :reg_add %key% /f /t REG_DWORD /v "ExtendedUIHoverTime" /d 1
call :reg_add %key% /f /t REG_DWORD /v "ThumbnailLivePreviewHoverTime" /d 1
call :reg_add %key% /f /t REG_DWORD /v "DesktopLivePreviewHoverTime" /d 1


set key="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
call :reg_backup %key%
call :reg_add %key% /f /t REG_DWORD /v "NumThumbnails" /d 1
call :reg_add %key% /f /t REG_DWORD /v "MinThumbSizePx" /d 300
call :reg_add %key% /f /t REG_DWORD /v "MaxThumbSizePx" /d 500

::HKEY_CURRENT_USER\AppEvents\EventLabels\*
::ExcludeFromCPL 0

::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management
::ClearPageFileAtShutdown 1
::DisablePagingExecutive 1
::LargeSystemCache 1

::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power
::HiberbootEnabled

::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
::UseOLEDTaskbarTransparency 1

::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Dwm
::ForceEffectMode 1

::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes
::EnableTransparency 1

::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl
::VolumeUnits

pause
exit
exit /b

:reg_backup
set "backup_path=.\reg_backups"

if not exist "%backup_path%" (
	echo First launch. Creating backups in %backup_path%
	mkdir "%backup_path%"
)

set "key_escaped=%~1"
set "key_escaped=%key_escaped:\=_%"
set backup_path="%backup_path%\%key_escaped%.reg"
if exist %backup_path% echo %1 & exit /b

reg export %1 %backup_path%>nul && echo Backup was created: %backup_path% || ( echo Failed to create backup for key: %1 & pause & exit )

echo %1
exit /b

:reg_add

set key="%~1"

:process_args
shift
if "%1"=="/v" set "name=%~2"
if "%1"=="/d" set "value=%2"
if "%1"=="/t" set "type= /t %2"
if not "%2"=="" goto process_args

set "v_=/v "

if "%name%"=="" (
	set "v_=/ve"
)

for /f "usebackq skip=2 tokens=1-3" %%a in (`reg query %key% %v_%%name% 2^>nul`) do (
	set "old_found=%%a"
	set "old_value=%%c"
)

set no_change="0"

if "%old_value%"=="%value%" set no_change=1

set /a int_old_value=%old_value%
set /a int_value=%value%
if "%int_old_value%"=="%int_value%" set no_change=1

if "%no_change%"=="1" (
	echo no change: %name%
	exit /b
)

if "%name%"=="" set "name=Default"

::define a variable containing a single backspace character
for /f %%a in ('"prompt $H &echo on &for %%b in (1) do rem"') do set bs=%%a
echo | set /p z=".%bs%  "
::reg add %key% /f 2>&1 | find "ERROR" || ( echo     failed to set %name% & echo. & exit /b )

reg add %key% /f%type% %v_%%name% /d "%value%" 2>&1 | find "ERROR" && echo     failed to set %name%

if "%old_found%"=="" (
	echo   created: %name%
	echo     value: %value%
) else (
	echo   updated: %name%
	echo     old value: %old_value%
	echo     new value: %value%
)
echo.
exit /b
