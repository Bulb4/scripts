@echo off

set "letter=P:"
set "projects_dir=D:\projects\in_work"

if not exist "%letter%\" subst "%letter%" "%projects_dir%"
