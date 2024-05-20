@echo off
set "process_name=%~nx1"

if not exist "%~1" (
	echo file not found: "%~1"
	pause
	goto :eof
)

taskkill /IM %process_name% /F /T
set "process_killed=%errorlevel%"

start "" %*

if "%process_killed%"=="0" (
	echo "started: "
	tasklist /FI "imagename eq %process_name%" | more +2
	timeout /t 5
)
