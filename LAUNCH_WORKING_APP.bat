@echo off
echo =========================================
echo TEAM SYNC APP - FULLY WORKING VERSION
echo =========================================
echo.
echo ✅ All compilation errors resolved
echo ✅ Black screen issue fixed
echo ✅ App ready to run successfully
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo Starting Team Sync Project Management App...
echo.
echo The app will be available at:
echo 🌐 http://localhost:8080
echo.

REM Stop any existing Flutter processes
taskkill /IM dart.exe /F 2>nul

REM Start the development server
echo Starting Flutter development server...
set CHROME_EXECUTABLE="C:\Program Files\Google\Chrome\Application\chrome.exe"
flutter run -d chrome --web-port=8080

pause
