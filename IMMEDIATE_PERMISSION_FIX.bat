@echo off
echo ============================================
echo   IMMEDIATE PERMISSION FIX - MANUAL
echo ============================================
echo.

echo STEP 1: Deploy Firestore Rules Manually
echo ========================================
echo.
echo 1. Open your browser and go to:
echo    https://console.firebase.google.com/
echo.
echo 2. Login with: seneshfitzroy@gmail.com
echo.
echo 3. Select project: team-sync-project-management
echo.
echo 4. Go to: Firestore Database ^> Rules
echo.
echo 5. REPLACE ALL existing rules with this:
echo.

echo rules_version = '2';
echo service cloud.firestore {
echo   match /databases/{database}/documents {
echo     // Allow all authenticated users full access (for development)
echo     match /{document=**} {
echo       allow read, write: if request.auth != null;
echo     }
echo   }
echo }

echo.
echo 6. Click "Publish" and wait for deployment
echo.
echo ========================================
echo  STEP 2: Add Real Sample Users
echo ========================================
echo.
echo After deploying rules, your app will work!
echo Then you can add these real users to test with:
echo.
echo Real Test Users:
echo - seneshfitzroy@gmail.com (owner)
echo - test7@gmail.com (team member)
echo - user1@example.com (team member)
echo - user2@example.com (team member)
echo.

pause

echo.
echo ========================================
echo  STEP 3: Test Project Creation
echo ========================================
echo.
echo After deploying rules:
echo 1. Refresh your app (F5)
echo 2. Try creating the "WEB" project again
echo 3. Should work without permission errors
echo.

echo Your app will then have full functionality!
pause
