@echo off
title Direct Flutter Launch
color 0A

echo ========================================================
echo       DIRECT FLUTTER LAUNCH - NO TASK MANAGER ROUTE
echo ========================================================
echo.

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

REM This script runs Flutter without using the taskmanager route
echo Running Flutter directly...
echo.

flutter run -d chrome

echo.
echo If you see errors, try these commands:
echo.
echo flutter clean
echo flutter pub get
echo flutter run
echo.

pause