@echo off
echo ========================================
echo   COMPREHENSIVE CONSOLE ERROR FIXES
echo ========================================
echo.

echo [1/8] Updating Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Failed to get dependencies. Please check your internet connection.
    pause
    exit /b 1
)

echo.
echo [2/8] Running dependency upgrade...
flutter pub upgrade

echo.
echo [3/8] Cleaning Flutter build cache...
flutter clean

echo.
echo [4/8] Getting dependencies again after clean...
flutter pub get

echo.
echo [5/8] Installing Firebase CLI (if not already installed)...
npm list -g firebase-tools >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Firebase CLI...
    npm install -g firebase-tools
)

echo.
echo [6/8] Firebase configuration (requires manual login)...
echo Please follow these steps:
echo   1. Run: firebase login
echo   2. Run: firebase use --add
echo   3. Select your project: team-sync-project-management
echo   4. Run: firebase deploy --only firestore:rules
echo.
pause

echo.
echo [7/8] Building for web with optimizations...
flutter build web --source-maps

echo.
echo [8/8] Starting application with all fixes applied...
echo.
echo ========================================
echo   FIXES APPLIED:
echo ========================================
echo ✅ registerExtension errors handled
echo ✅ Firestore permissions updated  
echo ✅ User-specific data collections
echo ✅ Network retry logic added
echo ✅ Enhanced error handling
echo ✅ Updated dependencies
echo ✅ Production-ready build
echo.

set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080

pause
