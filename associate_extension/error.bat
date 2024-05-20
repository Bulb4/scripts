
set "out=%~dp0err.txt"

set "cmd=%*"

echo ^>"%cmd%"
if "%cmd:"=\%"=="" goto end

%cmd% 2> %out%

set ec=%errorlevel%

if "%ec%"=="0" (
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
