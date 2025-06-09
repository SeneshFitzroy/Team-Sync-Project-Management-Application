@echo off
title Team Sync Flutter App Launcher
color 0A

echo ================================================================
echo           TEAM SYNC PROJECT MANAGEMENT APPLICATION
echo ================================================================
echo.

echo [1/4] Checking Flutter setup...
flutter doctor --android-licenses > nul 2>&1

echo [2/4] Getting dependencies...
flutter pub get

echo [3/4] Checking available devices...
flutter devices

echo.
echo ================================================================
echo                    LAUNCHING APPLICATION
echo ================================================================
echo.

echo Trying Windows Desktop App...
start "Team Sync Windows" cmd /k "flutter run -d windows"

timeout /t 3 /nobreak > nul

echo.
echo Trying Web Browser (Chrome)...
start "Team Sync Web" cmd /k "flutter run -d chrome --web-port=3000"

echo.
echo ================================================================
echo App is launching! Check the new windows that opened.
echo.
echo If you see any errors, try:
echo - flutter clean
echo - flutter pub get
echo - flutter run
echo ================================================================

pause
