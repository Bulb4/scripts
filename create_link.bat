@echo off

cd /d "%~dp0" && net session 1>nul 2>nul || ( echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/c cd ""%~sdp0"" && %~s0 %~1 %~2", "", "runas", 1 > "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )


set browse_root=17

if "%~2"=="/j" set browse_root="%~d1"

set "target=%~1"
set "target_relative=.\"

echo target:    %target%

set "vbs=browse.vbs"
>"%vbs%" echo set shell=WScript.CreateObject("Shell.Application"^)
>>"%vbs%" echo set folder=shell.BrowseForFolder(0, "Select destination directory", 72, %browse_root%)
>>"%vbs%" echo if not folder is nothing then WScript.Echo folder.self.path

for /f "usebackq delims=" %%a in (`cscript //nologo "%vbs%"`) do set "dir_path=%%a"
del "%vbs%"

::set "dir_path=%~2\"

if "%dir_path%"=="" goto :eof

if not "%dir_path:~-1,1%"=="\" set "dir_path=%dir_path%\"

echo link:      %dir_path% .\%~nx1

set common=0

:common_path_start
call set "c=%%target:~%common%,1%%"
call set "d=%%dir_path:~%common%,1%%"
if not "%c%"=="%d%" goto :common_path_end
set /a common=common+1
goto :common_path_start
:common_path_end

if "%common%"=="0" goto :append_path_end

set i=%common%
:skip_parents_start
call set "char=%%dir_path:~%i%,1%%"
set /a i=i+1
echo char: %char%
if "%char%"=="" goto :skip_parents_end
if "%char%"=="\" set "target_relative=%target_relative%..\"
goto :skip_parents_start
:skip_parents_end

set /a i=common - 1
:append_path_start
set /a i=i+1
call set "char=%%target:~%i%,1%%"
if "%char%"=="" goto :append_path_end
set "target_relative=%target_relative%%char%"
goto :append_path_start
:append_path_end

if "%target_relative%"==".\" (
	echo target:    %target%
) else (
	echo relative:  %dir_path% %target_relative%
	set "target=%target_relative%"
)

pushd "%dir_path%"
mklink %~2 ".\%~nx1" "%target%"
popd

if "%errorlevel%"=="0" (
	timeout /t 5
) else (
	pause
)
