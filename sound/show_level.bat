:: wt -f -w 400 --pos "1625,1010" --size "20,1" nt -p sound_level D:\PortableApps\scripts\sound\show_level.bat

@echo off
cd /d "%~dp0"

set min_volume=54
set bar_width=9
set old_volume=

:loop_start
nircmdc wait 200
::timeout /t 1 > nul

svcl /GetDecibel Headphones
if "%old_volume%"=="%errorlevel%" goto :loop_start
set "old_volume=%errorlevel%"
set /a level_db= old_volume / 1000
set /a bar_chars_count= bar_width + (level_db / (min_volume / bar_width))

set i=0
set bar_char=#
set bar_str=
:bar_start

set "bar_str=%bar_str%%bar_char%"
if %i% equ %bar_chars_count% set bar_char=_
set /a i += 1
if %i% leq %bar_width% goto :bar_start

set "level_str= "
if %level_db% gtr -10 set "level_str=  "
if %level_db% equ -0 set "level_str=   "

set "level_str=%level_str%%level_db%db"

cls
echo|set /p=%bar_str%%level_str%

goto :loop_start
