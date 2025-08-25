@echo off
echo Starting build fix process...

echo Cleaning Flutter project...
flutter clean

echo Removing build directories...
if exist build rmdir /s /q build
if exist windows\build rmdir /s /q windows\build

echo Getting dependencies...
flutter pub get

echo Upgrading dependencies...
flutter pub upgrade --major-versions

echo Building for Windows...
flutter build windows --release

echo Build process complete!
pause
