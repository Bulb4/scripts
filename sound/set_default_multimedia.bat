@echo off

cd /d "%~dp0"

set "get_default_device=svcl.exe /scomma "" /Columns "Name,DefaultMultimedia,DefaultCommunications""
set "set_default_device=svcl.exe /SetDefault"
set enabled="Render"

:start

timeout /t 1 > nul

for /f "skip=1 tokens=*" %%a in ('%get_default_device%') do call :process_line "%%a"

goto :start

:process_line
set "input=%*"
set "fix_delimeters=%input:,=","%"

for /f "tokens=1-3 delims=," %%a in ("%fix_delimeters%") do ^
if "%%b"=="%enabled%" if not "%%c"=="%enabled%" ^
%set_default_device% %%a 2 & powershell "[console]::beep(500,100)"
exit /b 0