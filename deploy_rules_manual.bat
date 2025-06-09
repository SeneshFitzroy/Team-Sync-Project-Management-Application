@echo off
echo ========================================
echo   INSTANT FIRESTORE RULES DEPLOYMENT
echo ========================================
echo.
echo MANUAL STEPS (Use the opened browser):
echo.
echo 1. In the Firebase Console that just opened:
echo    https://console.firebase.google.com/project/team-sync-project-management/firestore/rules
echo.
echo 2. Click "Edit rules" if not already in edit mode
echo.
echo 3. REPLACE ALL existing rules with this:
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
echo 4. Click "Publish" button
echo.
echo 5. Wait for "Rules published successfully" message
echo.
echo 6. Come back here and press any key to continue...
echo.
pause
echo.
echo ✅ Rules should now be deployed!
echo ✅ Try creating a project again - it should work now!
echo.
echo Press any key to exit...
pause >nul
