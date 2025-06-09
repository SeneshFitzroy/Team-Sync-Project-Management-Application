@echo off
title Direct TaskManager Launch
color 0A

echo ================================================================
echo           DIRECT TASKMANAGER LAUNCH IN EDGE
echo ================================================================
echo.

echo [1/3] Navigating to project directory...
cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo [2/3] Setting Microsoft Edge as browser...
set CHROME_EXECUTABLE="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

echo [3/3] Launching direct TaskManager in Edge...
echo.
echo Starting Flutter web server on port 8080...
echo.

flutter run -d chrome --web-port=8080 -t run_task_manager_direct.dart

pause
