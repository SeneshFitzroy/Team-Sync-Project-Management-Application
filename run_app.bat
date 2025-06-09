@echo off
echo Starting Flutter Team Sync Application...
echo.

echo Step 1: Checking Flutter setup...
flutter doctor

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Checking available devices...
flutter devices

echo.
echo Step 4: Listing available emulators...
flutter emulators

echo.
echo Step 5: Attempting to run on web (Chrome)...
start "Flutter Web" flutter run -d chrome --web-port=3000

echo.
echo Step 6: If web doesn't work, trying Windows...
start "Flutter Windows" flutter run -d windows

echo.
echo If you have an Android emulator, you can start it with:
echo flutter emulators --launch [EMULATOR_ID]
echo Then run: flutter run

pause
