@echo off
echo ============================================
echo    ADDING SAMPLE DATA TO TEAM SYNC APP
echo ============================================
echo.

echo This script will add sample projects and tasks to your app.
echo.
echo IMPORTANT: Make sure you are logged into your app first!
echo.
echo Sample data includes:
echo - 4 realistic projects (Team Sync App, E-Commerce, Marketing, Database Migration)
echo - 7 sample tasks across different projects and categories
echo - 3 activity log entries
echo.

pause

echo.
echo Running sample data script...
flutter run ADD_SAMPLE_DATA.dart

if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCCESS: Sample data added successfully!
    echo.
    echo What you can now test:
    echo.
    echo 📋 DASHBOARD:
    echo   - View 4 sample projects with different statuses
    echo   - See progress bars and member counts
    echo   - Test project filtering and sorting
    echo.
    echo 📋 TASK MANAGER:
    echo   - Switch between Project Tasks and My Tasks
    echo   - See sample tasks in different statuses
    echo   - Test task filtering and search
    echo.
    echo 📅 CALENDAR:
    echo   - View tasks with due dates
    echo   - See calendar integration
    echo.
    echo 💬 CHAT:
    echo   - Sample team members available
    echo   - Project-based communication setup
    echo.
    echo Your app now has realistic data to test all features!
    echo Refresh your browser to see the changes.
) else (
    echo.
    echo ❌ ERROR: Failed to add sample data
    echo.
    echo Common solutions:
    echo 1. Make sure you're logged into the app first
    echo 2. Check your internet connection
    echo 3. Ensure Firebase is properly configured
    echo 4. Try running: flutter run ADD_SAMPLE_DATA.dart manually
)

echo.
pause
