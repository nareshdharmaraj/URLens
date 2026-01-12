# Build Release Script for URLens

Write-Host "Building URLens Release..." -ForegroundColor Green

# 1. Clean
Write-Host "Cleaning project..."
flutter clean
flutter pub get

# 2. Build for Windows
Write-Host "Building for Windows..."
flutter build windows --release
if ($LASTEXITCODE -eq 0) {
    Write-Host "Windows Build Success!" -ForegroundColor Green
    Write-Host "Output: build\windows\x64\runner\Release"
} else {
    Write-Host "Windows Build Failed" -ForegroundColor Red
    exit
}

# 3. Build for Android (APK)
Write-Host "Building for Android (APK)..."
flutter build apk --release
if ($LASTEXITCODE -eq 0) {
    Write-Host "Android Build Success!" -ForegroundColor Green
    Write-Host "Output: build\app\outputs\flutter-apk\app-release.apk"
} else {
    Write-Host "Android Build Failed" -ForegroundColor Red
    exit
}

Write-Host "All builds completed successfully!" -ForegroundColor Cyan
Read-Host -Prompt "Press Enter to exit"
