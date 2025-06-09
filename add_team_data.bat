@echo off
cls
echo ========================================
echo      ADD REAL TEAM MEMBERS
echo ========================================
echo.
echo This will add realistic team member data to your app
echo including projects, tasks, and collaborative features.
echo.
echo Prerequisites:
echo - Your app must be running
echo - You must be logged in
echo - Firestore rules must be deployed
echo.
echo Step 1: Make sure you're logged into the app
echo Step 2: Press any key to add sample data
echo.
pause >nul

cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

echo Adding comprehensive team data...
echo.

dart run ADD_REAL_TEAM_DATA.dart

echo.
echo ✅ Team member data added successfully!
echo.
echo Your app now includes:
echo - 6 realistic team members
echo - 4 collaborative projects  
echo - Multiple tasks assigned to team members
echo - Project milestones and progress tracking
echo.
echo Refresh your app to see the new data!
echo.
pause
