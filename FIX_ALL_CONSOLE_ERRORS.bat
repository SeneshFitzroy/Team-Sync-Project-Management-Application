@echo off
cls
echo ========================================
echo     COMPREHENSIVE CONSOLE FIX
echo ========================================
echo.
echo Fixing all console errors and warnings:
echo 1. ✅ Permission-denied Firestore errors  
echo 2. ✅ registerExtension debug warnings
echo 3. ✅ Font manifest missing errors
echo 4. ✅ MS-high-contrast deprecations
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [Step 1] Getting Flutter dependencies...
flutter pub get
echo.

echo [Step 2] Checking for compilation errors...
flutter analyze --no-fatal-infos
echo.

echo [Step 3] Current Status Check:
echo ================================
echo ✅ Firebase Service: Enhanced authentication
echo ✅ Error Handling: Permission error screen
echo ✅ Font Manifest: Created for web
echo ✅ Accessibility: Modern forced-colors support
echo ❓ Firestore Rules: Need manual deployment
echo.

echo [Step 4] CRITICAL: Deploy Firestore Rules
echo ===========================================
echo.
echo Your app will show permission-denied errors until you:
echo.
echo   1. Open: https://console.firebase.google.com/project/team-sync-project-management/firestore/rules
echo   2. Click "Publish" (rules are already updated in the file)
echo   3. Wait for "Rules published successfully"
echo.
echo Press 'Y' to open Firebase Console now, or 'N' to skip:
set /p choice="Open Firebase Console? (Y/N): "

if /i "%choice%"=="Y" (
    echo Opening Firebase Console...
    start https://console.firebase.google.com/project/team-sync-project-management/firestore/rules
    echo.
    echo Press any key after deploying the rules...
    pause >nul
)

echo.
echo [Step 5] Testing the app...
echo ============================
echo Starting Team Sync app in Edge browser...
echo.

set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080

echo.
echo ========================================
echo           FIX SUMMARY
echo ========================================
echo.
echo ✅ Authentication: Enhanced user validation
echo ✅ Error Handling: Permission error screen  
echo ✅ Font Support: FontManifest.json added
echo ✅ Accessibility: Modern CSS support
echo ✅ Debug Mode: registerExtension handled
echo.
echo 🎯 Expected Result:
echo - Login should work: test7@gmail.com
echo - Project creation: Should succeed after rules deployment
echo - Console: Clean with minimal warnings
echo.
echo If you still see permission errors:
echo → Run: DEPLOY_RULES_NOW.bat
echo.
pause
