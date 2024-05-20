@echo off

set script_path="%~dp0to_clipboard.bat"
set icon_path="%windir%\System32\shell32.dll,-16806"

echo script path: %script_path%
if "%script_path%"=="""" goto end

pushd %~d0\

@echo on

reg add HKCR\*\shell\copy_path /ve /d "Copy full path"
reg add HKCR\*\shell\copy_path /v "Icon" /d %icon_path%
reg add HKCR\*\shell\copy_path\command /ve /d "%script_path% \"%%1\""

reg add HKCR\Directory\shell\copy_path /ve /d "Copy full path"
reg add HKCR\Directory\shell\copy_path /v "Icon" /d %icon_path%
reg add HKCR\Directory\shell\copy_path\command /ve /d "%script_path% \"%%1\""

reg add HKCR\Directory\Background\shell\copy_path /ve /d "Copy full path"
reg add HKCR\Directory\Background\shell\copy_path /v "Icon" /d %icon_path%
reg add HKCR\Directory\Background\shell\copy_path\command /ve /d "%script_path% \"%%V\""

@echo off

popd
:end
echo.
echo.
pause