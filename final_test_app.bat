@echo off
cls
echo ========================================
echo      TEAM SYNC - FINAL TEST RUN
echo ========================================
echo.

echo Checking if you've deployed the Firestore rules...
echo.
echo ✅ If you completed the Firebase rules deployment, continue.
echo ❌ If NOT, run fix_permissions_now.bat first!
echo.
pause

echo [1/4] Getting Flutter dependencies...
flutter pub get
echo.

echo [2/4] Checking for compilation errors...
flutter analyze lib/main.dart
echo.

echo [3/4] Starting the app in Edge browser...
echo.
echo 🎯 TEST PLAN:
echo 1. Login with test7@gmail.com / any password
echo 2. Try creating "hbbg" project
echo 3. Check console for errors
echo 4. Add some team members
echo.

set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=8080

echo.
echo [4/4] After testing, add sample team data:
echo Run: add_team_data.bat
echo.
echo ========================================
echo All done! Your Team Sync app is ready! 🎉
echo ========================================
pause
