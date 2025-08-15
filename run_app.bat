@echo off
echo ====================================
echo Flutter App Build and Run Script
echo ====================================
echo.

echo Step 1: Cleaning previous build...
flutter clean
echo Clean completed.
echo.

echo Step 2: Getting dependencies...
flutter pub get
echo Dependencies retrieved.
echo.

echo Step 3: Running the app on Windows...
flutter run -d windows

echo Script completed.
