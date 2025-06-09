@echo off
echo ========================================
echo   FIRESTORE PERMISSION DENIED FIX
echo ========================================
echo.

echo Current Status:
echo ✅ Firebase login successful
echo ✅ User data saved successfully  
echo ❌ Activity logging permission denied
echo ❌ Project loading permission denied
echo.

echo Solution: Deploy updated Firestore security rules
echo.

echo [1/4] Checking Firebase CLI...
firebase --version
if %errorlevel% neq 0 (
    echo Installing Firebase CLI...
    npm install -g firebase-tools
)

echo.
echo [2/4] You need to manually run these commands:
echo.
echo   firebase login
echo   firebase use --add
echo   Select: team-sync-project-management
echo   firebase deploy --only firestore:rules
echo.

echo [3/4] Alternative: Copy rules to Firebase Console
echo.
echo Go to: https://console.firebase.google.com/project/team-sync-project-management/firestore/rules
echo Copy the rules from firestore.rules file and click Publish
echo.

echo [4/4] Current firestore.rules content:
echo.
type firestore.rules
echo.

echo ========================================
echo   AFTER DEPLOYING RULES EXPECT:
echo ========================================
echo ✅ Firebase login successful
echo ✅ User data saved successfully  
echo ✅ Activity logged successfully
echo ✅ Projects loaded successfully
echo ✅ No more permission denied errors
echo.

pause
