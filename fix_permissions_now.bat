@echo off
cls
echo ========================================
echo        QUICK FIRESTORE RULES FIX
echo ========================================
echo.
echo Your project creation is failing due to permission errors.
echo This script will help you fix it in 2 minutes!
echo.
echo Step 1: Open Firebase Console
echo ------------------------------
echo Opening Firebase Console in your browser...
start https://console.firebase.google.com/project/team-sync-project-management/firestore/rules
echo.
echo Step 2: Update the Rules
echo ------------------------
echo.
echo In the browser that just opened:
echo 1. Click "Edit rules" if not already editing
echo 2. REPLACE ALL existing rules with this code:
echo.
echo rules_version = '2';
echo service cloud.firestore {
echo   match /databases/{database}/documents {
echo     match /{document=**} {
echo       allow read, write: if request.auth != null;
echo     }
echo   }
echo }
echo.
echo 3. Click "Publish" button
echo 4. Wait for "Rules published successfully" message
echo.
echo Step 3: Test Your App
echo ---------------------
echo After publishing the rules:
echo 1. Go back to your app
echo 2. Try creating the "hbbg" project again
echo 3. It should work without errors!
echo.
echo ========================================
echo Press any key when you've deployed the rules...
pause >nul
echo.
echo ✅ Great! Now try creating your project again.
echo ✅ The permission errors should be fixed!
echo.
pause
