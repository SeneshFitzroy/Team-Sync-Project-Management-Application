@echo off
cls
echo ========================================
echo      ULTIMATE FIX AND RUN SCRIPT
echo ========================================
echo.
echo Step 1: Fixing dependencies...
echo.

REM Clean Flutter project
flutter clean

REM Get updated dependencies
flutter pub get

echo.
echo Step 2: Running app in Edge browser...
echo.

REM Set Edge as the Chrome executable and run
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080

echo.
echo App should now be running in Edge browser!
echo.
pause
