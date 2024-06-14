@echo off

call "as_admin.bat" "%~0"

set "weird=%weird:^=^^^%"
for %%a in ("&" "|" ">" "<") do ^
call set "weird=%%weird:%%~a=^%%~a%%"


set "e=%~dp0error.bat"
set exec=call "%%e%%"

set "key=HKCR\SystemFileAssociations"

echo Enter file extension^(example: .txt^):
set /p extension=
::if not "%extension:~0,1%"=="." echo Extension should start with . character & goto err

set "key=%key%\%extension%"
%exec% reg add %key% /f
%exec% reg query %key% /s

set "key=%key%\shell"
%exec% reg add %key% /f

echo Enter menu name^(example: Open with Notepad^):
set /p menu_name=
if "%menu_name%"=="" echo Menu name should not be empty & goto err

for %%a in ("/" "\" ":" "<") do ^
echo %%~a

set "menu_key=%menu_name%"
set "menu_key=%menu_key:/=_%"
set "menu_key=%menu_key:\=_%"
set "menu_key=%menu_key::=_%"
set "menu_key=%menu_key:^*=_%"
set "menu_key=%menu_key:?=_%"
set "menu_key=%menu_key:"=_%"
set "menu_key=%menu_key:>=_%"
set "menu_key=%menu_key:<=_%"
set "menu_key=%menu_key:&=_%"
set "menu_key=%menu_key:|=_%"
set "menu_key=%menu_key:<=_%"
set "menu_key=%menu_key:^(=_%"
set "menu_key=%menu_key:.=_%"
set "menu_key=%menu_key: =_%"
set "menu_key=%menu_key:___=_%"
set "menu_key=%menu_key:__=_%"

set key_tmp= && set "key_tmp=%~dp0temp"
mkdir "%key_tmp%" & mkdir "%key_tmp%\%menu_key%"
for /f "delims=" %%f in ('dir /b /l "%key_tmp%"') do set "menu_key=%%f"
rmdir /s /q "%key_tmp%"
echo %menu_key%

set "key=%key%\%menu_key%"
%exec% reg add "%key:"=\"%" /ve /d "%menu_name:"=\"%" /f

echo Enter path to icon
echo ^(example: "C:\Windows\System32\notepad.exe"^)
echo ^(example: "C:\MyProgram\icon.ico"^)
echo Leave empty if you don't need it:
set /p icon_path=
if exist %icon_path% ^
%exec% reg add "%key%" /v Icon /d "%icon_path:"=\"%" /f

echo Enter command, put path and arg into quotes^(example: "C:\Windows\System32\notepad.exe" "%%%%1"^):
set /p command=

set "key=%key%\command"
%exec% reg add %key% /d "%command:"=\"%" /f

echo File association created successfully
pause
exit /b 0

:err
%exec%
exit /b %errorlevel%