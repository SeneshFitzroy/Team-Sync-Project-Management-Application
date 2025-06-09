@echo off
cls
echo ========================================
echo      TEAM SYNC - QUICK TEST RUN
echo ========================================
echo.
echo Testing the app with all the fixes applied...
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [1/3] Checking Flutter setup...
flutter doctor --version
echo.

echo [2/3] Getting dependencies...
flutter pub get
echo.

echo [3/3] Running app in Edge browser...
echo Opening Team Sync app...
echo.
echo TIP: After the app opens:
echo 1. Login with your test account (test7@gmail.com)
echo 2. Try creating a new project
echo 3. If you see permission errors, run: fix_permissions_now.bat
echo.

set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080

echo.
echo App session ended.
pause
