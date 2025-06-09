@echo off
title Team Sync - Microsoft Edge Launcher (FIXED)
color 0B

echo ================================================================
echo      LAUNCHING TEAM SYNC IN MICROSOFT EDGE (FIXED VERSION)
echo ================================================================
echo.

echo [1/3] Cleaning and getting dependencies...
flutter clean
flutter pub get

echo [2/3] Setting Microsoft Edge as the default browser for Flutter...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo [3/3] Starting Flutter app...
echo URL will be: http://localhost:3000
echo.

flutter run -d chrome --web-port=3000

echo.
echo ================================================================
echo App should be running in Microsoft Edge!
echo ================================================================
pause
