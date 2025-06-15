@echo off
echo Testing compilation...
flutter analyze
if %errorlevel% equ 0 (
    echo ✅ Analysis passed! No compilation errors.
    echo Ready to run on Edge browser!
) else (
    echo ❌ Analysis failed. Check for errors.
)
pause
