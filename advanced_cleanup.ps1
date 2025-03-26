Write-Host "Stopping related processes..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -match "dart|flutter|java|gradle|adb"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Cleaning Flutter project..." -ForegroundColor Cyan
flutter clean

Write-Host "Manually removing problematic directories..." -ForegroundColor Cyan
$directories = @(
    "build",
    ".dart_tool",
    ".gradle",
    "android\.gradle",
    "android\app\build"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path -Path $PSScriptRoot -ChildPath $dir
    if (Test-Path -Path $fullPath) {
        Write-Host "Removing $fullPath" -ForegroundColor Yellow
        Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Getting packages..." -ForegroundColor Cyan
flutter pub get

Write-Host "Invalidating caches..." -ForegroundColor Cyan
flutter pub cache repair

Write-Host "Clean up complete! Try building your app now." -ForegroundColor Green
Write-Host "Run: flutter run" -ForegroundColor Green
