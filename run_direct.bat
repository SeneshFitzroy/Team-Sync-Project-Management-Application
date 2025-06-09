@echo off
title Team Sync - Direct Launcher
color 0A

echo ================================================================
echo              TEAM SYNC DIRECT LAUNCH UTILITY
echo ================================================================
echo.
echo This script will start the Team Sync app using direct commands
echo that bypass the usual Flutter launcher.
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [1/4] Cleaning project...
call flutter clean

echo [2/4] Getting dependencies...
call flutter pub get

echo [3/4] Starting web server...
start "Flutter Web Server" cmd /C "flutter run -d web-server --web-port=8080"

echo Waiting for server to initialize...
timeout /t 5 /nobreak > nul

echo [4/4] Opening Microsoft Edge...
start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "http://localhost:8080"

echo.
echo ================================================================
echo Team Sync should be opening in Microsoft Edge!
echo If you don't see the app, manually go to: http://localhost:8080
echo ================================================================
echo.

pause
