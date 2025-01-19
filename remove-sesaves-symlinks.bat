@echo off
setlocal enabledelayedexpansion

REM Ensure the script runs as administrator
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo ====================================================
    echo This script must be run as an administrator to delete symlinks!
    echo Right-click the script and select "Run as administrator".
    echo ====================================================
    echo.
    pause
    exit /b
)

REM Define the root Space Engineers save directory
set saveRootDir="%APPDATA%\SpaceEngineers\Saves"

REM Verify if the root save directory exists
if not exist !saveRootDir! (
    echo Save directory does not exist: !saveRootDir!
    echo Unable to proceed.
    pause
    exit /b
)

REM Change to the save directory
cd /d "!saveRootDir!"

REM Locate the latest Steam ID directory
set latestSteamID=
for /d %%i in (*) do (
    if exist "%%i\*" (set latestSteamID=%%i)
)

REM Check if a Steam ID directory was found
if "!latestSteamID!"=="" (
    echo No valid Steam ID directory found.
    pause
    exit /b
)

REM Change to the Steam ID directory
set targetDir=!saveRootDir!\!latestSteamID!
cd /d "!targetDir!"

REM List and confirm removal of symbolic links
echo Searching for symbolic links in: !targetDir!
set foundSymlink=false
for /f "tokens=*" %%l in ('dir /AL /B') do (
    set foundSymlink=true
    echo Found symlink: %%l
)

REM Check if no symbolic links were found
if "!foundSymlink!"=="false" (
    echo No symbolic links found in: !targetDir!
    pause
    exit /b
)

REM Prompt user for confirmation
set /p confirmDelete="Do you want to delete all symlinks in this directory? [Y/N]: "
if /i "!confirmDelete!" NEQ "Y" (
    echo Operation canceled. No symlinks were removed.
    pause
    exit /b
)

REM Delete symbolic links
echo Deleting symbolic links in: !targetDir!
for /f "tokens=*" %%l in ('dir /AL /B') do (
    echo Removing symlink: %%l
    rmdir "%%l"
    if !errorlevel! == 0 (
        echo Successfully removed symlink: %%l
    ) else (
        echo Failed to remove symlink: %%l. Check permissions or path issues.
    )
)

REM Completion message
echo All symbolic links have been removed from: !targetDir!
pause
