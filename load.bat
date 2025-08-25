@echo off
setlocal enabledelayedexpansion

REM Get the directory of this script.
set "SCRIPT_DIR=%~dp0"

REM Get the current directory.
set "TARGET_DIR=%CD%"

REM Loop through all items in the script's directory.
for %%F in ("%SCRIPT_DIR%*") do (
    REM Check if it is a file.
    if not exist "%%F\" (
        set "FILENAME=%%~nxF"
        REM Check if the filename does not start with "load" (case-insensitive).
        echo "!FILENAME!" | findstr /B /I "load" > nul
        if errorlevel 1 (
            echo Creating hard link for: "!FILENAME!"
            mklink /H "!TARGET_DIR!\!FILENAME!" "%%~fF"
        )
    )
)

endlocal