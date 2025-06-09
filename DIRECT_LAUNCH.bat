@echo off
title Team Sync - Direct Launch
color 0A

echo =======================================================
echo      TEAM SYNC - DIRECT LAUNCH IN EDGE BROWSER
echo =======================================================
echo.

echo [1/4] Cleaning project...
flutter clean

echo [2/4] Getting dependencies...
flutter pub get

echo [3/4] Setting Edge as browser...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo [4/4] Running Direct Launch...
echo.
echo Starting app with direct launcher...
echo URL: http://localhost:5000
echo.

flutter run -d chrome --web-port=5000 -t direct_launch.dart

echo.
pause