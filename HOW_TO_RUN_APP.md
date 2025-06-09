# How to Run the Team Sync Flutter App

## ✅ **COMPILATION ISSUE FIXED!**
The TaskManager constructor error has been resolved. The app should now compile and run successfully.

## 🚀 **Running the App - Multiple Options**

### **Option 1: Using VS Code Debug (Recommended)**
1. Open VS Code
2. Go to the **Run and Debug** panel (Ctrl+Shift+D)
3. Select one of these configurations from the dropdown:
   - **"Flutter (Edge)"** - Runs in Microsoft Edge browser
   - **"Flutter (Chrome)"** - Runs in Chrome browser  
   - **"Flutter (Windows)"** - Runs as Windows desktop app
   - **"Flutter (Any Device)"** - Runs on any available device
4. Press **F5** or click the green play button

### **Option 2: Using Terminal Commands**
```bash
# Navigate to project directory
cd "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

# Run on Chrome (Web)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows

# Run on any available device
flutter run
```

### **Option 3: Using Tasks (In VS Code)**
1. Press **Ctrl+Shift+P**
2. Type "Tasks: Run Task"
3. Select one of the available Flutter tasks:
   - "Flutter Run Chrome"
   - "Flutter Run Windows"
   - "Flutter Run Debug"

## 📱 **For Android Emulator**
If you want to run on Android emulator:

1. **Check available emulators:**
   ```bash
   flutter emulators
   ```

2. **Launch an emulator:**
   ```bash
   flutter emulators --launch [EMULATOR_NAME]
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 🌐 **For Web Browser (Easiest)**
The easiest way to test the app is in a web browser:

```bash
flutter run -d chrome --web-port=3000
```

This will open the app in Chrome at `http://localhost:3000`

## 🔧 **Troubleshooting**

### If you get dependency errors:
```bash
flutter clean
flutter pub get
```

### If you get platform errors:
```bash
flutter doctor
```

### Check available devices:
```bash
flutter devices
```

## ✨ **App Features Available**
Once running, you can test:
- ✅ Login/Signup (with bypass mode for testing)
- ✅ Dashboard with projects
- ✅ Task Manager (fixed constructor issue)
- ✅ Profile Screen
- ✅ Calendar view
- ✅ Chat functionality
- ✅ Navigation between all screens

## 🎯 **Test Credentials**
The app is in "bypass mode" so you can:
- Login with any email/password
- Or leave fields empty and click "Sign In (Bypass Mode)"

---
**Ready to run! Choose any option above to start the Team Sync app.** 🚀
