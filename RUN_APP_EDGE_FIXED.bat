@echo off
echo ========================================
echo     RUNNING TEAM SYNC APP IN EDGE
echo ========================================
echo.

echo [Step 1] Cleaning project...
flutter clean

echo.
echo [Step 2] Getting dependencies...
flutter pub get

echo.
echo [Step 3] Starting app in Edge browser...
echo Open your Edge browser if it doesn't open automatically
echo.

flutter run -d edge --web-port=8080

echo.
echo ========================================
echo If app doesn't start, try:
echo 1. Close any running Flutter processes
echo 2. Run: flutter doctor
echo 3. Try again
echo ========================================
pause
