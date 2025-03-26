@echo off
echo Stopping Flutter processes...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM flutter.exe /T 2>nul
taskkill /F /IM java.exe /T 2>nul
taskkill /F /IM gradle.exe /T 2>nul

echo Cleaning Flutter project...
flutter clean

echo Deleting problematic directories manually...
rd /s /q build 2>nul
rd /s /q .dart_tool 2>nul
rd /s /q .gradle 2>nul
rd /s /q android\.gradle 2>nul
rd /s /q android\app\build 2>nul

echo Getting packages...
flutter pub get

echo Clean up complete! Try building your app now.
echo Run: flutter run
