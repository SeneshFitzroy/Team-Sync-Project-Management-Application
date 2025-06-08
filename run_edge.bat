@echo off
echo Starting Flutter app in Microsoft Edge...
flutter run -d web-server --web-port=8080 --web-browser-flag="--new-window"
start msedge http://localhost:8080
