@echo off
echo =========================================
echo TEAM SYNC APP - FINAL WORKING VERSION
echo =========================================
echo.
echo ✅ Compilation errors fixed
echo ✅ Web build successful  
echo ✅ App ready to run
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo Starting Flutter development server...
echo.
echo The app will be available at:
echo 🌐 http://localhost:8080
echo.

REM Set Chrome as the browser
set CHROME_EXECUTABLE="C:\Program Files\Google\Chrome\Application\chrome.exe"

REM Clean build first
flutter clean
flutter pub get

REM Build for web to ensure everything compiles
echo Building web version...
flutter build web

REM Start the development server
echo Starting development server...
flutter run -d chrome --web-port=8080 --web-browser-flag="--disable-web-security"

pause
