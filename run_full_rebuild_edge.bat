@echo off
title Team Sync - Clean Launch in Edge
color 0A

echo ================================================================
echo           TEAM SYNC - COMPLETE REBUILD AND LAUNCH
echo ================================================================
echo.

echo [1/5] Navigating to project directory...
cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [2/5] Cleaning Flutter project...
flutter clean

echo [3/5] Getting dependencies...
flutter pub get

echo [4/5] Setting Microsoft Edge as browser...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo [5/5] Launching app in Microsoft Edge...
echo.
echo Starting Flutter web server on port 8080...
echo URL will be: http://localhost:8080
echo.

start "Flutter Server" cmd /c "flutter run -d web-server --web-port=8080 && pause"

echo Waiting for server to initialize...
timeout /t 5 /nobreak > nul

echo Launching Edge browser...
start msedge "http://localhost:8080"

echo.
echo ================================================================
echo The app should now be running in Microsoft Edge!
echo If you don't see it, wait a few moments and check:
echo http://localhost:8080
echo ================================================================
pause
