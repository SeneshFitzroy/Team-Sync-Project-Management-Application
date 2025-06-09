@echo off
title Team Sync - Microsoft Edge Launch
color 0B
echo ================================================================
echo           TEAM SYNC - MICROSOFT EDGE LAUNCHER
echo ================================================================
echo.

echo [1/3] Navigating to project directory...
cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [2/3] Getting Flutter dependencies...
flutter pub get

echo [3/3] Launching Team Sync in Microsoft Edge...
echo.
echo Starting app at: http://localhost:8080
echo Browser: Microsoft Edge
echo.

REM Set Edge as the browser for Flutter web
set CHROME_EXECUTABLE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe

REM Start Flutter web server
start "Flutter Server" cmd /k "flutter run -d web-server --web-port=8080"

REM Wait a moment for server to start
timeout /t 5 /nobreak > nul

REM Launch Edge with the app
start "Team Sync App" msedge "http://localhost:8080" --new-window

echo.
echo ================================================================
echo App should open in Microsoft Edge shortly!
echo If Edge didn't open, manually navigate to: http://localhost:8080
echo ================================================================
pause
