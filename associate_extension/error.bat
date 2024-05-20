
set "out=%~dp0err.txt"
set ec=0
::set errorlevel=0

set "cmd=%*"
::pause
::set "cmd=%cmd:\=\\"%"
::set "cmd=%cmd:"=\"%"
::pause

echo ^>"%cmd%"
if "%cmd:"=\%"=="" goto end

::for %%a in (%*) do call set "cmd=%%cmd%% %%a"
::set "cmd=%cmd:~1%"

%cmd% 2> %out%

set ec=%errorlevel%

if "%ec%"=="0" (
	echo no errors exit b
	del %out%
	exit /b %ec%
) else (
	echo ^>"%cmd%"
	type %out%
	del %out%
	echo Error code: %ec%
)

:end
echo Error occured, press any key to continue...
set /p p=
exit %ec%
