@echo off
echo =====================================================
echo    TEAM SYNC - MINIMAL VERSION LAUNCH
echo =====================================================
echo.
echo Killing any existing Flutter processes...
taskkill /F /IM dart.exe 2>nul
echo.
echo Starting Flutter app on port 3000...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
flutter run -d chrome --web-port=3000
pause
