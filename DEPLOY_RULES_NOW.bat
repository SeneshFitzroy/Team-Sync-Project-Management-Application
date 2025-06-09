@echo off
cls
echo ========================================
echo   IMMEDIATE FIRESTORE RULES DEPLOYMENT
echo ========================================
echo.
echo CRITICAL: Your app has permission-denied errors because
echo the Firestore security rules haven't been deployed yet.
echo.
echo STEPS TO FIX (Takes 2 minutes):
echo.
echo Step 1: Opening Firebase Console...
start https://console.firebase.google.com/project/team-sync-project-management/firestore/rules
echo.
echo Step 2: In the browser that just opened:
echo ========================================
echo.
echo   1. Click "Edit rules" (if not already editing)
echo.
echo   2. REPLACE ALL existing rules with this code:
echo.
echo      rules_version = '2';
echo      service cloud.firestore {
echo        match /databases/{database}/documents {
echo          match /{document=**} {
echo            allow read, write: if request.auth != null;
echo          }
echo        }
echo      }
echo.
echo   3. Click "Publish" button
echo.
echo   4. Wait for "Rules published successfully" message
echo.
echo ========================================
echo.
echo Step 3: Test the fix
echo ===================
echo After deploying rules:
echo   1. Go back to your app
echo   2. Try creating a project again
echo   3. Should work without permission errors!
echo.
echo Current Error: [cloud_firestore/permission-denied]
echo After Fix:     ✅ Project created successfully!
echo.
echo Press any key when you've deployed the rules...
pause >nul
echo.
echo ✅ Rules should now be deployed!
echo ✅ Try creating your "hbbg" project again!
echo.
pause
