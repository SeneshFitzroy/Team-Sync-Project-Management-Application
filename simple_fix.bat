@echo off
echo Simple Flutter Build Fix
echo.

echo Cleaning...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo Building for Windows...
call flutter build windows --release

echo Done!
pause
