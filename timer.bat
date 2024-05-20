@echo off

set "prefix= %~2"
set "prefix_len=0"

:len_start
set /a prefix_len+=1
call set "char=%%prefix:~%prefix_len%,1%%"
if not "%char%"=="" goto :len_start
set /a prefix_len-=1

call set "prefix=%%prefix:~1,%prefix_len%%%"

if not "%prefix_len%"=="0" ^
set "prefix=%prefix%: " & set /a prefix_len+=2 & title %prefix%

set "duration=%~1"
if "%duration%"=="0" set /p "duration=Enter timer duration in minutes: "

set /a duration=duration + 0
if "%duration%"=="0" echo duration is zero & pause & exit /b 1

set /a columns=5+prefix_len
if %columns% lss 18 set columns=18
mode con cols=%columns% lines=1

:loop_start

set /a duration-=1

set /a hours=duration / 60
set /a minutes=duration %% 60

if %hours% lss 10 set "hours=0%hours%"
if %minutes% lss 10 set "minutes=0%minutes%"

set "time_left=%hours%:%minutes%"

cls
title %prefix%%time_left%
echo|set /p="%prefix%%time_left%"


call timeout /t 60 > nul

if %duration% gtr 0 goto :loop_start

exit /b 0
