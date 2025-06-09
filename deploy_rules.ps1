# Firebase Firestore Rules Deployment Script
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   FIREBASE FIRESTORE RULES DEPLOYMENT" -ForegroundColor Cyan  
Write-Host "============================================" -ForegroundColor Cyan
Write-Host

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI installation..." -ForegroundColor Yellow
try {
    $firebaseVersion = firebase --version 2>$null
    Write-Host "Firebase CLI is installed: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "Firebase CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g firebase-tools
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install Firebase CLI" -ForegroundColor Red
        Write-Host "Please install manually: npm install -g firebase-tools" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host
Write-Host "Checking Firebase login status..." -ForegroundColor Yellow
$loginCheck = firebase projects:list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "You need to login to Firebase first." -ForegroundColor Yellow
    Write-Host "Opening Firebase login..." -ForegroundColor Yellow
    firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Firebase login failed" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host
Write-Host "Current Firebase project:" -ForegroundColor Yellow
firebase use

Write-Host
Write-Host "Deploying Firestore security rules..." -ForegroundColor Yellow
firebase deploy --only firestore:rules

if ($LASTEXITCODE -ne 0) {
    Write-Host
    Write-Host "ERROR: Failed to deploy Firestore rules" -ForegroundColor Red
    Write-Host
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "1. Check your internet connection" -ForegroundColor White
    Write-Host "2. Verify Firebase project is properly initialized" -ForegroundColor White
    Write-Host "3. Ensure you have proper permissions for the project" -ForegroundColor White
    Write-Host "4. Try: firebase use --add (to set project)" -ForegroundColor White
    Write-Host
} else {
    Write-Host
    Write-Host "✅ SUCCESS: Firestore rules deployed successfully!" -ForegroundColor Green
    Write-Host
    Write-Host "The following changes have been applied:" -ForegroundColor Yellow
    Write-Host "- User-specific data access rules" -ForegroundColor White
    Write-Host "- Enhanced security for projects and activities" -ForegroundColor White  
    Write-Host "- Helper functions for permission checking" -ForegroundColor White
    Write-Host
    Write-Host "You can now test your app - the permission-denied errors should be resolved." -ForegroundColor Green
}

Write-Host
Read-Host "Press Enter to exit"
