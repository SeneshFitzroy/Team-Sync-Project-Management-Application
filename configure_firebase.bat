@echo off
echo ========================================
echo   FIREBASE CONFIGURATION SCRIPT
echo ========================================
echo.

echo [1/5] Checking Firebase CLI...
firebase --version
if %errorlevel% neq 0 (
    echo Installing Firebase CLI...
    npm install -g firebase-tools
)

echo.
echo [2/5] Logging into Firebase...
firebase login --no-localhost

echo.
echo [3/5] Initializing Firebase project...
firebase use --add

echo.
echo [4/5] Deploying Firestore rules...
firebase deploy --only firestore:rules

echo.
echo [5/5] Deploying Firestore indexes...
firebase deploy --only firestore:indexes

echo.
echo ========================================
echo   FIREBASE CONFIGURATION COMPLETE!
echo ========================================
echo.
echo Your Firestore rules have been deployed.
echo The app should now work without permission errors.
echo.
pause
