@echo off
echo ========================================
echo   TEAM SYNC APP - COMPREHENSIVE LAUNCH
echo ========================================
echo.

echo [1/4] Cleaning Flutter build cache...
flutter clean
if %errorlevel% neq 0 (
    echo Failed to clean Flutter cache. Continuing...
)

echo.
echo [2/4] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Failed to get dependencies. Exiting...
    pause
    exit /b 1
)

echo.
echo [3/4] Building for web with optimizations...
flutter build web --source-maps

echo.
echo [4/4] Starting app in Microsoft Edge...
echo.
echo ========================================
echo   APP STARTING WITH ALL FIXES APPLIED
echo ========================================
echo.
echo ✅ Enhanced Firebase error handling
echo ✅ Improved Firestore retry logic  
echo ✅ Better authentication flow
echo ✅ Fixed debug mode checks
echo ✅ Modern CSS accessibility support
echo.
echo Open your browser to: http://localhost:8080
echo.

set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080

echo.
echo App session ended.
pause
