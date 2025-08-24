@echo off
setlocal enabledelayedexpansion
set "scriptdir=%~dp0"
for %%F in ("%scriptdir%*") do (
    echo %%~nxF | findstr /i "^load.*$" >nul
    if errorlevel 1 (
        mklink /H "%%~nxF" "%%~fF"
    )
)
