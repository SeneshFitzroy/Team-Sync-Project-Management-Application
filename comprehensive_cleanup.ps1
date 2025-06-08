# PowerShell script to clean up unused .dart files
Write-Host "Starting comprehensive Flutter project cleanup..."

# Change to project directory
Set-Location "c:\Users\senes\OneDrive\Desktop\MAD\Team-Sync-Project-Management-Application"

# Files to remove
$filesToRemove = @(
    "lib\utils\auth_helper.dart",
    "lib\utils\error_handler.dart", 
    "lib\utils\firebase_debug.dart",
    "lib\utils\firebase_helpers.dart",
    "lib\utils\firestore_extensions.dart",
    "lib\Services\auth_service.dart",
    "lib\models\user_data.dart",
    "lib\models\pigeon_user_details.dart",
    "lib\Screens\login-page-new.dart",
    "lib\Screens\login-page-bypass.dart",
    "lib\widgets\your_widget.dart",
    "icon_test.dart"
)

# Remove each file
foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        try {
            Remove-Item $file -Force
            Write-Host "✓ Removed: $file"
        }
        catch {
            Write-Host "✗ Failed to remove: $file - $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "◦ Not found: $file"
    }
}

# Remove empty directories
$dirsToCheck = @("lib\utils", "lib\Services", "lib\models")
foreach ($dir in $dirsToCheck) {
    if (Test-Path $dir) {
        $files = Get-ChildItem $dir -File
        if ($files.Count -eq 0) {
            try {
                Remove-Item $dir -Force
                Write-Host "✓ Removed empty directory: $dir"
            }
            catch {
                Write-Host "◦ Directory not empty or failed to remove: $dir"
            }
        }
    }
}

Write-Host "Cleanup completed!"
