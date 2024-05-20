net session 1>nul 2>nul && exit /b 0
echo Launching as admin

set "dir=%~dp1"
set "script=%~1"
set "args="

:loop_start
shift
set "args=%args%%1 "
if not "%~1"=="" goto :loop_start

set "args=%args:~0,-2%"

set vbs="%temp%\as_admin.vbs"

echo Set UAC = CreateObject^("Shell.Application"^) : > %vbs%
echo UAC.ShellExecute "cmd.exe", "/c cd /d ""%dir%"" && %script% %args%", "", "runas", 1 >> %vbs%

%vbs% & exit
