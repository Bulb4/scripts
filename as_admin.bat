shift
set "dir=%~dp0"
set "script=%~0"

set "args="

:loop_start
shift
set "args=%args%%0 "
if not "%~0"=="" goto :loop_start

set "args=%args:~0,-2%"

cd /d "%dir%"

net session 1>nul 2>nul && exit /b 0

echo Launching as admin

set vbs="%temp%\as_admin.vbs"

echo Set UAC = CreateObject^("Shell.Application"^) : > %vbs%
echo UAC.ShellExecute "cmd.exe", "/c cd ""%dir%"" && %script% %args%", "", "runas", 1 >> %vbs%

%vbs%

exit 
