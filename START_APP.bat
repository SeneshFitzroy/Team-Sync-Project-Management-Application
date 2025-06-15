@echo off
echo =====================================================
echo    TEAM SYNC PROJECT MANAGEMENT APPLICATION
echo =====================================================
echo.
echo Starting Flutter Team Sync App...
echo.
echo Cleaning previous builds...
call flutter clean
echo.
echo Getting dependencies...
call flutter pub get
echo.
echo Starting app on Edge browser...
echo App will be available at: http://localhost:8081
echo.
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
call flutter run -d chrome --web-port=8081 --web-renderer=html
