@echo off
cls
echo ========================================
echo        TEAM SYNC STATUS CHECK
echo ========================================
echo.

echo Checking Flutter environment...
flutter --version
echo.

echo Checking project dependencies...
flutter pub deps
echo.

echo Checking for Firebase configuration...
if exist "firebase.json" (
    echo ✅ Firebase configured
) else (
    echo ❌ Firebase not configured
)

if exist "lib\firebase_options.dart" (
    echo ✅ Firebase options exist
) else (
    echo ❌ Firebase options missing
)

if exist "firestore.rules" (
    echo ✅ Firestore rules file exists
) else (
    echo ❌ Firestore rules missing
)
echo.

echo Checking main project files...
if exist "lib\main.dart" (
    echo ✅ Main app file exists
) else (
    echo ❌ Main app file missing
)

if exist "lib\Services\firebase_service.dart" (
    echo ✅ Firebase service exists
) else (
    echo ❌ Firebase service missing
)

if exist "lib\Screens\Dashboard.dart" (
    echo ✅ Dashboard screen exists
) else (
    echo ❌ Dashboard screen missing
)
echo.

echo 🎯 NEXT STEPS:
echo 1. Deploy Firebase rules: fix_permissions_now.bat
echo 2. Test the app: final_test_app.bat
echo 3. Add team data: add_team_data.bat
echo.
pause
