@echo off
call "..\config.bat"

mode con cols=14 lines=1

set "icon0=16" & set "name0=Headphones"
set "path0=%shortcuts_path%\Set %name0%.url"

set "icon1=1" &  set "name1=Line Out"
set "path1=%shortcuts_path%\Set %name1%.url"

if exist "%path0%" set "name=%name0%" & set "icon_idx=%icon0%" & set "sc_path=%path0%"
if exist "%path1%" set "name=%name1%" & set "icon_idx=%icon1%" & set "sc_path=%path1%"

call :create_shortcut "%~0" "%path0%" "%icon0%"
call :create_shortcut "%~0" "%path1%" "%icon1%"
del "%sc_path%"

nircmdc setdefaultsounddevice "%name%" 1
nircmdc setdefaultsounddevice "%name%" 2

exit /b

:create_shortcut
del "%~2"
echo [InternetShortcut] >> "%~2"
echo URL="%~1" >> "%~2"
echo IconFile=%SystemRoot%\System32\mmres.dll >> "%~2"
echo IconIndex=%~3 >> "%~2"
exit /b
