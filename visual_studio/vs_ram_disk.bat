@echo off
set "main_bat=main_bat.bat"
set enable_logs=0
set "log_file=%~dp0log.txt"

if "%enable_logs%"=="1" (
	@echo on
	call "%~dp0%main_bat%" %* > "%log_file%" 2>&1
) else (
	call "%~dp0%main_bat%" %*
)

exit /b %ERRORLEVEL%
