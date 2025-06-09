@echo off
cls
echo ========================================
echo    TEAM SYNC - FIXED AND READY TO RUN
echo ========================================
echo.
echo [1/3] Getting dependencies...
call flutter pub get
echo.
echo [2/3] Building for web...
call flutter build web
echo.
echo [3/3] Starting app in Edge...
echo.
echo Choose [3] Edge when prompted!
echo.
call flutter run -d edge --web-port=8080
echo.
echo App should now be running in Edge browser!
pause
