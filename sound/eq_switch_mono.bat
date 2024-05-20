@echo off
call "..\config.bat"

set "config_path=%equalizer_apo_path%\config\"

set "name0=Enable Mono.lnk"
set "name1=Disable Mono.lnk"

pushd "%shortcuts_path%"

if exist ".\%name0%" (
	ren "%name0%" "%name1%"
) else if exist ".\%name1%" (
	ren "%name1%" "%name0%"
)

popd
pushd "%config_path%"

ren mono0.txt mono2.txt
ren mono1.txt mono0.txt
ren mono2.txt mono1.txt

popd