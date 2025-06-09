@echo off
title Team Sync - New Direct Launch
color 0A

echo =======================================================
echo           TEAM SYNC - RUNNING WITH WEB SERVER
echo =======================================================
echo.

echo Starting Flutter web server on port 8080...
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

flutter clean
flutter pub get
flutter run -d web-server --web-port=8080

echo.
echo =======================================================
echo       OPEN http://localhost:8080 IN YOUR BROWSER
echo =======================================================
echo.

pause
