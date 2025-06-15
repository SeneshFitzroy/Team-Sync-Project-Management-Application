@echo off
echo ===============================================
echo LAUNCHING FLUTTER APP WITH FULL ERROR OUTPUT
echo ===============================================
cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo.
echo Step 1: Cleaning project...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Checking for errors...
flutter analyze

echo.
echo Step 4: Setting up Edge browser...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo.
echo Step 5: Starting Flutter app...
echo URL will be: http://localhost:8080
echo.
flutter run -d chrome --web-port=8080

pause
