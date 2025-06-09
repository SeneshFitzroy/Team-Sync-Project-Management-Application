@echo off
cls
echo ========================================
echo     FINAL VERIFICATION TEST
echo ========================================
echo Current Date: June 10, 2025
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [1/5] Checking workspace structure...
echo ✅ Project directory: %CD%
if exist "lib\Services\firebase_service.dart" (echo ✅ Firebase Service: Found) else (echo ❌ Firebase Service: Missing)
if exist "lib\Screens\CreateaNewProject.dart" (echo ✅ Create Project Screen: Found) else (echo ❌ Create Project Screen: Missing)
if exist "lib\Screens\PermissionErrorScreen.dart" (echo ✅ Permission Error Screen: Found) else (echo ❌ Permission Error Screen: Missing)
if exist "web\assets\FontManifest.json" (echo ✅ Font Manifest: Found) else (echo ❌ Font Manifest: Missing)
if exist "firestore.rules" (echo ✅ Firestore Rules: Found) else (echo ❌ Firestore Rules: Missing)
echo.

echo [2/5] Flutter status check...
flutter --version
echo.

echo [3/5] Dependencies check...
flutter pub get --dry-run
echo.

echo [4/5] Compilation check...
flutter analyze --no-fatal-infos
echo.

echo [5/5] Starting the app in Edge browser...
echo ========================================
echo.
echo 🎯 TESTING INSTRUCTIONS:
echo 1. App will open in Edge browser
echo 2. Login with: test7@gmail.com (any password)
echo 3. Try creating a project named "Final Test Project"
echo 4. Check console for errors
echo.
echo 🔑 EXPECTED RESULTS:
echo ✅ Clean login process
echo ✅ Project creation works (after Firestore rules deployment)
echo ✅ Minimal console warnings
echo ✅ Icons display properly
echo.
echo Press any key to start the app...
pause >nul

echo Starting Team Sync app...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080 --release

echo.
echo ========================================
echo        VERIFICATION COMPLETE
echo ========================================
echo.
echo If you encountered permission-denied errors:
echo → Run: DEPLOY_RULES_NOW.bat
echo.
echo If everything worked:
echo → All console errors have been fixed! 🎉
echo.
pause
