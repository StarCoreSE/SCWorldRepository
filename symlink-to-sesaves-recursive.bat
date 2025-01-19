@echo off
setlocal enabledelayedexpansion

REM Check if the script is running as administrator
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo ====================================================
    echo This script must be run as an administrator to create symlinks!
    echo Right-click the script and select "Run as administrator".
    echo ====================================================
    echo.
    pause
    exit /b
)

REM Set the script's working directory to the location of this script
cd /d "%~dp0"

REM Define the root Space Engineers save directory
set saveRootDir=%APPDATA%\SpaceEngineers\Saves

REM Check if the root save directory exists
if not exist "!saveRootDir!" (
    echo Save directory does not exist: !saveRootDir!
    echo Please ensure that the Space Engineers game has created save directories.
    pause
    exit /b
)

REM List all Steam ID directories and let the user select one
set /a steamIDIndex=0
echo Searching for valid Steam ID directories in: !saveRootDir!
for /d %%i in (!saveRootDir!\*) do (
    set /a steamIDIndex+=1
    set "steamID!steamIDIndex!=%%~nxi"
    echo [!steamIDIndex!] %%~nxi
)

REM If no Steam ID directories found, exit
if !steamIDIndex! EQU 0 (
    echo No valid Steam ID directories found in: !saveRootDir!
    pause
    exit /b
)

REM Prompt user for selection if multiple directories exist
if !steamIDIndex! GTR 1 (
    set /p selectedSteamIDIndex="Enter the number corresponding to your Steam ID: "
    if "!steamID!selectedSteamIDIndex!!"=="" (
        echo Invalid selection. Exiting.
        pause
        exit /b
    )
    set "selectedSteamID=!steamID!selectedSteamIDIndex!!"
) else (
    set "selectedSteamID=!steamID1!"
)

REM Set the target Steam ID directory
set targetDir=!saveRootDir!\!selectedSteamID!
echo Using Steam ID directory: !targetDir!

REM Define the current directory as the search path for worlds
set currentDir=%cd%
echo Searching for world folders in: !currentDir!

REM Search recursively for Sandbox.sbc files
set foundWorldFolder=false
for /d /r %%d in (*) do (
    if exist "%%d\Sandbox.sbc" (
        echo Found world folder: %%d
        set foundWorldFolder=true

        REM Set source and destination paths
        set "sourceFolder=%%d"
        set "worldName=%%~nxd"
        set "destinationFolder=!targetDir!\!worldName!"

        REM Create the symlink if the destination does not already exist
        if exist "!destinationFolder!" (
            echo A directory or symlink named !worldName! already exists at the destination. Skipping...
        ) else (
            echo Creating symlink from "!sourceFolder!" to "!destinationFolder!"
            mklink /D "!destinationFolder!" "!sourceFolder!"
            if !errorlevel! neq 0 (
                echo Failed to create symlink for: !sourceFolder!. Check permissions or path issues.
            ) else (
                echo Successfully created symlink: !worldName!
            )
        )
    )
)

REM Check if no world folders were found
if "!foundWorldFolder!"=="false" (
    echo No valid world folders found containing Sandbox.sbc.
) else (
    echo Operation completed successfully.
)

REM Ensure the script window stays open regardless of the outcome
pause
