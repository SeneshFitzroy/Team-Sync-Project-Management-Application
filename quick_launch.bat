@echo off
cd /d "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"
flutter clean
flutter pub get
start cmd /k "flutter run -d chrome"
