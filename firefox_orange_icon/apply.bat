@echo off
call "..\config.bat"

set icons_res_path="%~dp0\orange_icons.res"

cd /d "%firefox_path%"

set "f1=firefox.exe"
set "f2=firefox2.exe"

copy /v /b %f1% %f2% && del %f1%

if exist %f1% ( echo file is locked ) else (
	call %rh_path% -open %f2% -save %f1% -a addoverwrite -r %icons_res_path% -m ICONGROUP,,
)

del "firefox2.exe"

where nircmdc && nircmdc shellrefresh
pause
