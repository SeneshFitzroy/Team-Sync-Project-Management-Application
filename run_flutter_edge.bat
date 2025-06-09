@echo off
title Team Sync - Microsoft Edge Launcher
color 0B

echo ================================================================
echo           LAUNCHING TEAM SYNC IN MICROSOFT EDGE
echo ================================================================
echo.

echo Setting Microsoft Edge as the default browser for Flutter...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo.
echo Starting Flutter app...
echo URL will be: http://localhost:3000
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"
flutter clean
flutter pub get
flutter run -d chrome --web-port=3000

echo.
echo ================================================================
echo App should be running in Microsoft Edge!
echo ================================================================
pause
