@echo off
cls
echo =========================================
echo    FLUTTER TEAM SYNC - FINAL VERSION
echo =========================================
echo.
echo Starting the fully working Team Sync app...
echo Browser: Microsoft Edge
echo URL: http://localhost:8081
echo.
echo =========================================

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo Cleaning project...
flutter clean >nul 2>&1

echo Getting dependencies...
flutter pub get >nul 2>&1

echo Starting app on Microsoft Edge...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8081

pause
