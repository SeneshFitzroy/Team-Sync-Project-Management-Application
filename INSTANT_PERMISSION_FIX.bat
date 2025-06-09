@echo off
echo ========================================
echo    INSTANT PERMISSION FIX
echo ========================================
echo.

echo The project creation is failing due to Firestore permission errors.
echo You need to deploy the updated rules to Firebase.
echo.

echo OPTION 1: Firebase Console (FASTEST)
echo =====================================
echo.
echo 1. Open: https://console.firebase.google.com/
echo 2. Login with: seneshfitzroy@gmail.com
echo 3. Select: team-sync-project-management
echo 4. Go to: Firestore Database ^> Rules
echo 5. REPLACE ALL with:
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
echo 6. Click "Publish"
echo.

echo OPTION 2: Firebase CLI (if available)
echo =====================================
echo.
firebase deploy --only firestore:rules --project team-sync-project-management

echo.
echo After deploying rules:
echo 1. Refresh your app (F5)
echo 2. Try creating "hbbg" project again
echo 3. Should work without permission errors!
echo.

pause
