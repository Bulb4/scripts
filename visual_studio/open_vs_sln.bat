::@echo off

if "%~1"=="" echo no arg1 & goto :error

call .\config.bat
set "prefix_format=[#...] "

set "sln_parent_dir="
for %%a in ("%~dp1\.") do set "sln_parent_dir=%%~nxa"

if not exist "%active_dirs_path%" mkdir "%active_dirs_path%"
if not exist "%cache_path%" mkdir "%cache_path%"
if not exist "%cache_path%\%sln_parent_dir%" mkdir "%cache_path%\%sln_parent_dir%"

set "vs_path=%~1\..\.vs"

if exist "%vs_path%" dir /al /b "%vs_path%\..\" | find ".vs" && goto :skip_linking || rd /s /q "%vs_path%"
if exist "%vs_path%" echo solution is already open & goto :error

if not exist "%vs_path%" mklink /j "%vs_path%" "%cache_path%\%sln_parent_dir%" & attrib +h "%vs_path%" /l
if not exist "%vs_path%" echo failed to create link & goto :error

:skip_linking
ren "%vs_path%" ".vs_check" && ren "%vs_path%_check" ".vs" || ( echo failed to update directory date & goto :error )

call :format_count

mode con: cols=60 lines=1
title VS#%idx% ^| %sln_parent_dir%

set "current_instance=%vs_instances%"
dir "%active_dirs_path%" | find " 2 Dir(s)" && set "current_instance="

set "active_dir=%active_dirs_path%\%vs_instances%%sln_parent_dir%"
mklink /j "%active_dir%" "%~dp1"
attrib +h "%~1\.." /d


call :format_count
setx vs_instances "%vs_instances%"
set "vs_instances=%current_instance%"

call "%ide_path%" "%~1"

timeout /t 1
rmdir "%active_dir%"
attrib -h "%~1\.." /d


call :format_count
dir "%active_dirs_path%" | find " 2 Dir(s)" && set "vs_instances="
setx vs_instances "%vs_instances%"

exit /b
:error
echo error occured & pause & exit /b 1

:format_count
set idx=0
:loop_start
set /a idx=idx+1
call set "vs_instances=%%prefix_format:...=%idx%%%"
dir /al /b "%active_dirs_path%" | find "%vs_instances%" &&^
goto :loop_start || exit /b
