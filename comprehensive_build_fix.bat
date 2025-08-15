@echo off
echo ================================
echo Flutter Windows Build Fix Script
echo ================================
echo.

echo Step 1: Cleaning previous build...
flutter clean
if exist build rmdir /s /q build 2>nul
if exist windows\build rmdir /s /q windows\build 2>nul
if exist .dart_tool rmdir /s /q .dart_tool 2>nul
echo Clean completed.
echo.

echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error getting dependencies. Retrying...
    flutter pub get
)
echo Dependencies retrieved.
echo.

echo Step 3: Checking Flutter configuration...
flutter doctor
echo.

echo Step 4: Building for Windows (Debug mode first)...
echo This may take several minutes...
flutter build windows --debug --verbose
if %errorlevel% neq 0 (
    echo Debug build failed. Trying release build...
    flutter build windows --release --verbose
)
echo.

echo Step 5: If build succeeded, running the app...
if %errorlevel% equ 0 (
    echo Build successful! Starting app...
    flutter run -d windows
) else (
    echo Build failed. Check the errors above.
    echo.
    echo Common solutions:
    echo 1. Update Visual Studio with C++ tools
    echo 2. Run 'flutter doctor' and fix any issues
    echo 3. Try running as administrator
    echo 4. Check Windows SDK installation
)

echo.
echo Script completed.
pause
