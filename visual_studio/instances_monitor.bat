
set "last_count=%vs_instances%"
set "get_count=tasklist /fo csv /fi "imagename eq devenv.exe""

:loop
timeout /t 10

set count=0
for /f %%a in ('%get_count%') do set /a count=count2 + 1

set "count=[%count%]"
if "%count%"=="[1]" set "count="

if "%last_count%"=="%count%" goto :loop

setx vs_instances "%count%"
set "last_count=%count%"

goto :loop
