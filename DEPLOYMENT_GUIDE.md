# FIREBASE DEPLOYMENT GUIDE

## 🎯 IMMEDIATE ACTION REQUIRED

Your Team Sync app is running successfully, but you're seeing **permission-denied errors** in the console because the Firestore security rules haven't been deployed yet.

## 📋 STEP-BY-STEP DEPLOYMENT

### Option 1: Use the Automated Scripts (Recommended)

1. **Run the PowerShell script** (if you have PowerShell):
   ```
   Right-click on: deploy_rules.ps1
   Select: "Run with PowerShell"
   ```

2. **Or run the Batch script**:
   ```
   Double-click: deploy_rules.bat
   ```

### Option 2: Manual Command Line Deployment

1. **Open Command Prompt** in the project directory
2. **Install Firebase CLI** (if not installed):
   ```
   npm install -g firebase-tools
   ```

3. **Login to Firebase**:
   ```
   firebase login
   ```

4. **Set the Firebase project** (if needed):
   ```
   firebase use --add
   ```
   Select your project from the list

5. **Deploy the Firestore rules**:
   ```
   firebase deploy --only firestore:rules
   ```

### Option 3: Firebase Console (Web Interface)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Firestore Database** → **Rules**
4. Copy the contents from `firestore.rules` file
5. Paste into the web editor
6. Click **Publish**

## 🔧 WHAT THE RULES DO

The deployed rules will:
- ✅ Allow users to access only their own data
- ✅ Enable proper project and activity management
- ✅ Fix all permission-denied errors
- ✅ Maintain security and data isolation

## 🚀 EXPECTED RESULTS

After deployment, your console should show:
- ✅ No more permission-denied errors
- ✅ Activity logging works properly
- ✅ Project loading succeeds
- ✅ All app features function correctly

## 📁 FILES INVOLVED

- `firestore.rules` - Contains the security rules
- `firebase.json` - Firebase configuration (already set up)
- `deploy_rules.bat` - Windows batch deployment script
- `deploy_rules.ps1` - PowerShell deployment script

## 🆘 TROUBLESHOOTING

If deployment fails:
1. Check internet connection
2. Verify Firebase project access
3. Ensure you're logged into the correct Google account
4. Try: `firebase use --add` to select the right project

## 📞 SUPPORT

If you encounter issues:
1. Check the terminal output for specific error messages
2. Verify your Firebase project permissions
3. Ensure the Firebase CLI is properly installed
