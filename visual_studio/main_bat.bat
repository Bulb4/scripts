::@echo off
::### fs config ###

call .\config.bat

set disk_letter=Z:\
set disk_size=6G
set diff_args=--no-pager diff --minimal --ignore-space-at-eol
set gi=.gitignore
set exclude_dirs=.git .vs .vscode
::### initializing ###
set "file_path=%~1"
for %%I in ("%file_path%") do set "project_dir=%%~dpI"
set "project_dir=%project_dir:~0,-1%"
for %%I in ("%project_dir%..") do set "project_dir_parent=%%~dpI"
for %%I in ("%project_dir%") do set "project_dir_name=%%~nxI"
set "disk_path=%disk_letter%%project_dir_name%"

::make sure .git is excluded
if "%exclude_dirs:.git=%"=="%exclude_dirs%" set "%exclude_dirs%=.git %exclude_dirs%"

::set console window title
title %project_dir_name% - ramdisk

::make sure
cd %project_dir%

::args for robocopy, max 128 threads + visual style settings
set rb_args=/mt:1 /njh /ndl /nfl /nc /ns /np

::full console width separator
for /f "skip=4 tokens=1* delims=:" %%a in ('mode con') do (
	for /l %%c in (1,1,%%b) do call set "separator=%%separator%%#"
	goto break
)
:break

::mount ramdisk
if not exist %disk_letter% (
	imdisk -a -s %disk_size% -m %disk_letter% -p "/fs:NTFS /q /y"
	if %errorlevel%==0 (
		echo imdisk -D -m %disk_letter% > "%disk_letter%unmount.bat"
	) else (
		echo failed to mount the disk^(%disk_letter%^), error: %errorlevel% & goto error_exit
	)
)

set b_git_repo=1

set repo_url=
if exist ".git\config" ^
for /f %%i in ('%git_path% config --get remote.origin.url') do ^
set "repo_url=%%i"

if "%repo_url%"=="" goto no_repo

::whole code just to echo github.com/torvalds/linux.git
set "repo_url=%repo_url:@=,%"
set "repo_url=%repo_url::=,%"
set "repo_url=%repo_url:/=,%"
set tokens=
for %%a in (%repo_url%) do call set tokens=%%a %%tokens%%
for /f "tokens=1,2,3" %%a in ("%tokens%") do ^
echo git repo found: %%c/%%b/%%a

:no_repo
if "%repo_url%"=="" (
	set is_git_repo=0
	echo creating temp repository
	%git_path% init -q
)

set b_git_ignore=0
if exist %gi% (
	echo gitignore found: %gi%
	set b_git_ignore=1
) else (
	echo gitignore not found, creating: %gi%
	(for %%i in (%exclude_dirs%) do echo %%i) >> %gi%
)

set git_exclude_=
for %%a in (%exclude_dirs%) do ^
call set git_exclude_=%%git_exclude_%%--exclude="%%a" 


::find a unique name for backup directory
set i=
:loop
set "backup_dir=%project_dir%_backup%i%"
set /a i+=1
if exist %backup_dir% goto loop

mkdir %backup_dir%

set xf_exclude_files=
for /f "delims=" %%a in ('%git_path% ls-files -o --ignored --exclude-standard') do (
	call set xf_exclude_files=%%xf_exclude_files%% "%%a"
	md "%backup_dir%\%%a"^&rmdir "%backup_dir%\%%a"^&mklink /j "%backup_dir%\%%a" "%project_dir%\%%a""
)

if not "%xf_exclude_files%"=="" set "xf_exclude_files=/xf %xf_exclude_files%"

:: create backup directory with unique path
echo backuping %project_dir% at %backup_dir%
robocopy "%project_dir%" "%backup_dir%" /e /xd /xj %exclude_dirs% %xf_exclude_files% %rb_args%
if not %errorlevel%==1 echo failed to backup, robocopy exit code: %errorlevel% & goto error_exit
echo %separator%

::initial copy to ramdisk
echo copying %project_dir% to %disk_path%
robocopy "%project_dir%" "%disk_path%" /s /zb /mir /xj %rb_args%
echo %separator%

::store list of robocopy process id's for later use
set find_rb=tasklist /fi "imagename eq robocopy.exe" /nh /fo csv
set pids_save=
for /f "tokens=2 delims=," %%i in ('%find_rb%') do ^
call set pids_save=%%i;%%pids_save%%

::run again after 1 change is seen, exclude '.vs' and '.git', skip links, 1 second retry timeout
echo starting sync process %disk_path% to %project_dir%
start "" /b cmd /c robocopy "%disk_path%" "%project_dir%" /e /zb /mir /mon:1 /xd %exclude_dirs% %xf_exclude_files% /xj /w:1 %rb_args%

::find and save process id of just created robocopy instance
set pid="0"
for /f "tokens=2 delims=," %%i in ('%find_rb%') do ^
echo %pids_save% | findstr /i "%%i" || set pid=%%i
set pid=%pid:~0,-1%

timeout /t 1 > 1
echo %separator%
tasklist /fi "pid eq %pid%"
echo %separator%

for %%I in ("%ide_path%") do set "ide_name=%%~nxI"
echo starting %ide_name% %disk_path%\%~nx1
::start ide and wait until it's closed
call "%ide_path%" "%disk_path%\%~nx1"


::kill background robocopy process
taskkill /F /PID %pid%

::wait for robocopy and ide to shutdown
timeout /t 1
echo %separator%
echo copy %disk_path% to %project_dir%
::fully copy to the project directory
robocopy "%disk_path%" "%project_dir%" /e /zb /mir /w:1 /xj %rb_args%

echo %separator%

::create junction links so git diff ignores everything in %exclude_dirs%
for %%a in (%exclude_dirs%) do ^
if exist "%project_dir%\%%a" ^
mklink /j "%backup_dir%\%%a" "%project_dir%\%%a"


::%git_path% %diff_args% --no-index "%backup_dir%" "%project_dir%"
%git_path% %diff_args% "%backup_dir%" "%project_dir%"





if %b_git_repo%==0 rmdir /s /q ".git"
if %b_git_ignore%==0 del %gi%

echo delete backup dir? "%backup_dir%"
set /p choice=y/n 
if /i "%choice%"=="y" (
	rmdir /s /q %backup_dir%
)
exit

:error_exit
echo error occured
pause