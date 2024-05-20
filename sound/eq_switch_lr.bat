@echo off
call "..\config.bat"

set "config_path=%equalizer_apo_path%\config\"

set "name0=Switch to RL.lnk"
set "name1=Switch to LR(default).lnk"

pushd "%shortcuts_path%"

if exist ".\%name0%" (
	ren "%name0%" "%name1%"
) else if exist ".\%name1%" (
	ren "%name1%" "%name0%"
)

popd
pushd "%config_path%"

ren lr0.txt lr2.txt
ren lr1.txt lr0.txt
ren lr2.txt lr1.txt

popd