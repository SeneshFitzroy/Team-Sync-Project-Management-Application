@echo off
echo ====================================
echo FLUTTER APP STARTUP MONITOR
echo ====================================

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo.
echo [1/5] Checking Flutter installation...
flutter --version

echo.
echo [2/5] Checking available devices...
flutter devices

echo.
echo [3/5] Analyzing project for errors...
flutter analyze

echo.
echo [4/5] Cleaning and getting dependencies...
flutter clean
flutter pub get

echo.
echo [5/5] Starting app...
echo Setting Edge as default browser...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo Starting Flutter web app on port 8080...
echo App will be available at: http://localhost:8080
echo.

start "" "http://localhost:8080"
flutter run -d chrome --web-port=8080 --verbose

pause
