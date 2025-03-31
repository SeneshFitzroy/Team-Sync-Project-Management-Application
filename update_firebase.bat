@echo off
echo Cleaning Flutter project...
flutter clean
echo.

echo Deleting Pub cache...
flutter pub cache clean
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Running Flutter doctor...
flutter doctor -v
echo.

echo Analyzing project for issues...
flutter analyze
echo.

echo Resolving dependencies...
flutter pub deps
echo.

echo Done! Your project should now be free of the PigeonUserDetails error.
echo Try running your app now with: flutter run
