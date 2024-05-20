@echo off

call "..\config.bat"

mode con cols=14 lines=1

set "reg_key=HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
set "reg_name=AppsUseLightTheme"
set "reg_name2=SystemUsesLightTheme"

set "light=%~1"
if not "%light%"=="" goto :skip_read

REM 2^>nul
for /f "usebackq skip=2 tokens=1-3" %%a in (`reg query %reg_key% /v %reg_name%`) do ^
set "light=%%c"

if "%light%"=="" exit /b 1
set "light=%light:~-1%"
set /a light=!light

:skip_read

reg add %reg_key% /t REG_DWORD /v %reg_name% /f /d %light%
reg add %reg_key% /t REG_DWORD /v %reg_name2% /f /d %light%

powershell -File "%~dp0set_desktop_wallpaper.ps1" "%~dp0wallpaper%light%.png"

set "name0=Set Dark Theme"
set "name1=Set Light Theme"

del "%shortcuts_path%\%name0%.url"
del "%shortcuts_path%\%name1%.url"

if "%light%"=="1" set "name=%name0%"
if "%light%"=="0" set "name=%name1%"

call :create_shortcut "%~0" "%shortcuts_path%\%name%" 174

exit /b

:create_shortcut
set "target=%~1"
set "path=%~2.url"
set "icon_idx=%~3"

del "%path%"
echo [InternetShortcut]>> "%path%"
echo URL="%target%">> "%path%"
echo IconFile=%SystemRoot%\System32\shell32.dll>> "%path%"
echo IconIndex=%icon_idx%>> "%path%"
exit /b
