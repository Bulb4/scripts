@echo off

call "..\config.bat"

set "config_path=%equalizer_apo_path%\config\config.txt"
set "shortcuts_list=%~dp0eq_shortcuts.txt"
set "configs_list=%~dp0eq_configs.txt"

set "pref_on=[#] "
set "pref_off=[_] "

set "enable_cfg=%~1"
set current_cfg=0

pushd "%shortcuts_path%\Sound"

for /f "tokens=1,* delims=#" %%i in (%shortcuts_list%) do if exist ".\%pref_on%%%j.lnk" set current_cfg=%%i
if "%enable_cfg%"=="%current_cfg%" set enable_cfg=0

for /f "tokens=1,* delims=#" %%i in (%shortcuts_list%) do ren ".\%pref_on%%%j.lnk" "%pref_off%%%j.lnk"
for /f "tokens=1,* delims=#" %%i in (%shortcuts_list%) do if "%%i"=="%enable_cfg%" ren ".\%pref_off%%%j.lnk" "%pref_on%%%j.lnk"

popd

echo Include: mono0.txt> "%config_path%"

for /f "tokens=1,2" %%i in (%configs_list%) do (
	if "%%i"=="%enable_cfg%" (
		echo Include: %%j>> "%config_path%"
	) else (
		echo # Include: %%j>> "%config_path%"
	)
)
