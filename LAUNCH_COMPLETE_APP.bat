@echo off
cls
color 0b
echo.
echo =========================================
echo    🎯 TEAM SYNC - COMPLETE VERSION
echo =========================================
echo.
echo 🎨 Beautiful Blue Theme
echo 📱 All Original Features Restored  
echo 🔧 Every Button Working
echo 🚀 Full Project Management Suite
echo.
echo =========================================
echo.
echo 🔄 Starting the complete app...
echo 📍 Browser: Microsoft Edge
echo 🌐 URL: http://localhost:8081
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo ⚡ Cleaning project cache...
flutter clean >nul 2>&1

echo 📦 Getting dependencies...
flutter pub get >nul 2>&1

echo 🚀 Launching Team Sync on Edge...
echo.
echo =========================================
echo    🎉 ENJOY YOUR COMPLETE APP!
echo =========================================
echo.
echo ✅ Welcome Pages with animations
echo ✅ Enhanced login with validation
echo ✅ Rich dashboard with statistics
echo ✅ Project management features
echo ✅ Task management system
echo ✅ Team collaboration tools
echo ✅ Calendar and scheduling
echo ✅ Chat communication
echo ✅ Profile and settings
echo ✅ Search and filter options
echo.
echo Press Ctrl+C to stop the app
echo =========================================
echo.

set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8081
