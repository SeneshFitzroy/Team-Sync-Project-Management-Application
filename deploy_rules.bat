@echo off
echo ============================================
echo   FIREBASE FIRESTORE RULES DEPLOYMENT
echo ============================================
echo.

echo Checking Firebase CLI installation...
firebase --version >nul 2>&1
if errorlevel 1 (
    echo Firebase CLI not found. Installing...
    npm install -g firebase-tools
    if errorlevel 1 (
        echo ERROR: Failed to install Firebase CLI
        echo Please install manually: npm install -g firebase-tools
        pause
        exit /b 1
    )
) else (
    echo Firebase CLI is installed.
)

echo.
echo Checking Firebase login status...
firebase projects:list >nul 2>&1
if errorlevel 1 (
    echo You need to login to Firebase first.
    echo Opening Firebase login...
    firebase login
    if errorlevel 1 (
        echo ERROR: Firebase login failed
        pause
        exit /b 1
    )
)

echo.
echo Current Firebase project:
firebase use

echo.
echo Deploying Firestore security rules...
firebase deploy --only firestore:rules

if errorlevel 1 (
    echo.
    echo ERROR: Failed to deploy Firestore rules
    echo.
    echo Common solutions:
    echo 1. Check your internet connection
    echo 2. Verify Firebase project is properly initialized
    echo 3. Ensure you have proper permissions for the project
    echo 4. Try: firebase use --add (to set project)
    echo.
) else (
    echo.
    echo ✅ SUCCESS: Firestore rules deployed successfully!
    echo.
    echo The following changes have been applied:
    echo - User-specific data access rules
    echo - Enhanced security for projects and activities
    echo - Helper functions for permission checking
    echo.
    echo You can now test your app - the permission-denied errors should be resolved.
)

echo.
pause
