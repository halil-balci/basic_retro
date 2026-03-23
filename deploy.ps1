# Full deployment script - Build and deploy to Firebase
# Automatically reads GEMINI_API_KEY from .env file
# Usage: .\deploy.ps1

Write-Host "=== Firebase Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Build the app
Write-Host "Step 2: Building Flutter web app..." -ForegroundColor Yellow
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Build completed" -ForegroundColor Green
Write-Host ""

# Deploy to Firebase
Write-Host "Step 3: Deploying to Firebase Hosting..." -ForegroundColor Yellow
firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Deployment Successful! ===" -ForegroundColor Green
    Write-Host "Your app is now live on Firebase Hosting!" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Deployment failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
