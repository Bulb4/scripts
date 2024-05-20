::@echo off
::todo
::GetForeground window change check, close
::show device volume dB
::auto update

set "wnd=call :nircmd_wnd"

pushd "%~dp0"

set "console_title=mixer_console"
title %console_title%
::%wnd% hide ititle %console_title%

set "old_foreground_window="
set apps_count=0
call :calc_sound_apps

set screen_w=1920
set screen_h=1080

set mixer_app_w=110
::set mixer_app_h=56
set mixer_app_h=311

set "image_name=SndVol.exe"
set "find_running=tasklist /fi "imagename eq %image_name%""

:check_fresh
%find_running% | findstr /i "%image_name%" && taskkill /im "%image_name%" && goto :check_fresh

start "" /b cmd /c winapiexec Sleep 0000 , u@SystemParametersInfoA 4163 0 1 3
start "" /b cmd /c winapiexec Sleep 5000 , u@SystemParametersInfoA 4163 0 0 1

set /a arg_pos = screen_w ^| (screen_h ^<^< 16)
start %image_name% -r %arg_pos%

:wait_wnd
for /f delims^=^"^ tokens^=17 %%a in ('%find_running% /v /fo csv /nh') do set "active_title=%%a"
echo %active_title% | findstr /c:"Volume Mixer - " || goto :wait_wnd

call :winapi_32 u@FindWindowW 0 "%active_title%" || ( echo failed to get handle & pause & exit )
set "hwnd=%winapi_res%"

%wnd% move 14 226 0 0

::%wnd% -exstyle 0x10000000
::%wnd% +exstyle 0x00044200
:: WS_EX_APPWINDOW
%wnd% +exstyle 0x00040000
%wnd% -style 0x80CC0000

::%wnd% settopmost 1
::%wnd% hideshow

:running
%wnd% child trans class "Volume Flood" 96
goto :skip1
%wnd% child hide id 305
%wnd% child hide id 410
%wnd% child hide id 411

%wnd% child setsize id 301 1 36 96 19
%wnd% child move class "ToolbarWindow32" 0 -4 0 0
%wnd% child setsize id 401 28 -1 44 38
%wnd% child setsize id 300 25 -2 44 38

%wnd% child +style id 304 0x0000164C
%wnd% child setsize id 304 100 -6 7 69
%wnd% child sendmsg id 304 1051 24 0
%wnd% child sendmsg id 304 1033 1 0
%wnd% child move id 304 -7 0 7 0
%wnd% child sendmsg id 304 1051 16 0

:skip1

set /a mixer_w = mixer_app_w * (apps_count + 2) + 2 + 30
set /a mixer_x = screen_w - mixer_w - 4 + 1
set /a mixer_y = screen_h - mixer_app_h - 30 - 4 + 1 + 75

winapiexec u@SetWindowPos %hwnd% 0 %mixer_x% %mixer_y% %mixer_w% 250 1024

::%wnd% child setsize id 412 %mixer_app_w% 0 %mixer_w% %mixer_app_h%

set /a border_x = -1
set /a border_w = mixer_app_w - border_x
::%wnd% child setsize id 410 %border_x% 0 %border_w% %mixer_app_h%

::%wnd% trans 255

::%wnd% min
::%wnd% normal
nircmdc win activate class "Shell_TrayWnd"
::nircmdc win focus class "Shell_TrayWnd"

:idle
nircmdc wait 500
%find_running% | findstr /i "%image_name%" || goto :end

::call :winapi_32 u@GetForegroundWindow
::set "foreground_window=%winapi_res%"
::
::if not "%old_foreground_window%"=="" ^
::if not "%old_foreground_window%"=="%foreground_window%" ^
::if not %foreground_window%=="%hwnd%" goto :end
::
::set "old_foreground_window=%foreground_window%"


set "old_apps_count=%apps_count%"
call :calc_sound_apps

if not "%old_apps_count%"=="%apps_count%" echo apps_count "%old_apps_count%-^>%apps_count%" & goto :running

goto :idle
:end
::taskkill /im "%image_name%"
popd
exit

:calc_sound_apps
set apps_count=0
set "tmp_file=processes.txt"
echo.> %tmp_file%

set "get_columns=svcl /Columns "Direction,Process Path,Process ID" /scomma"
for /f "tokens=1,2,3 delims=," %%a in ('%get_columns% ^| more +1') do ^
if "%%a"=="Render" if not "%%b"=="" findstr /c:" %%c " %tmp_file% || echo %%b %%c >> %tmp_file% && set /a apps_count += 1

::blacklist
::call :cb "ShellExperienceHost.exe"
::call :cb "rundll32.exe"
::call :cb "HxTsr.exe"
exit /b

::check blocked processes
:cb
findstr /c:"%~1" %tmp_file% && set /a apps_count -= 1
exit /b 0

:nircmd_wnd
set "args=_%* "
call set "args=%%args:_%1 =%%"
set "wnd_cmd=nircmdc win %1 handle %hwnd% %args%"
::echo %wnd_cmd%
%wnd_cmd% & exit /b

:winapi_32
set winapi_res=0
set "out_file=%temp%\w32_%random%"
start "" /wait /b winapiexec.exe msvcrt.dll@fwprintf ^( msvcrt.dll@_wfopen "%out_file%" "w" ^) "%%d" ^( %* ^)
for /f %%a in (%out_file%) do set "winapi_res=%%a"
del %out_file%
set /a e=! winapi_res
::set "winapi_res=0x%winapi_res%"
exit /b %e%
