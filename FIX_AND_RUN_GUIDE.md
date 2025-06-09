# How to Fix and Run the Team Sync App

## The Problem
The Flutter app is encountering a compilation error:
```
Error: Couldn't find constructor 'TaskManager'.
'/taskmanager': (context) => const TaskManager(),
```

## Recommended Solutions

### Solution 1: Use the Web Server Directly
The most reliable way to run the app is using the web server approach:

1. Double-click `RUN_WEB_SERVER.bat` in the project folder
2. Wait for the server to start
3. Open Edge and navigate to `http://localhost:8080`

### Solution 2: Fix the Route Definition
If you want to fix the main issue:

1. Open `lib\main.dart`
2. Find the routes section with `/taskmanager`
3. Replace the TaskManager constructor with a simpler version:
   ```dart
   '/taskmanager': (context) => const Scaffold(
     body: Center(child: Text('Task Manager')),
   ),
   ```
4. Later on, you can expand this with the actual TaskManager implementation

### Solution 3: Use Direct Launch
To bypass the routes system entirely:

1. Double-click `run_direct.bat`
2. This will launch the app directly in Chrome or Edge

### Solution 4: For Development
If you're developing the app, you can:

1. Fix the TaskManager class in `lib\Screens\TaskManager.dart`
2. Ensure it has a proper default constructor
3. Clear the Flutter cache with `flutter clean`
4. Get the dependencies with `flutter pub get`
5. Run the app with `flutter run`

## Technical Details
The error occurs because:
1. The TaskManager class requires specific parameters
2. The route system is trying to instantiate it without all parameters
3. There's an issue with how the constructor is being referenced

By using the web server approach, you can run the app while investigating the issue further.
