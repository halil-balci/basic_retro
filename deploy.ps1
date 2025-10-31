# Full deployment script - Build and deploy to Firebase
# Automatically reads GEMINI_API_KEY from .env file
# Usage: .\deploy.ps1

Write-Host "=== Firebase Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
Write-Host "Step 1: Checking .env file..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "Error: .env file not found!" -ForegroundColor Red
    Write-Host "Please create .env file with GEMINI_API_KEY=your_key" -ForegroundColor Yellow
    exit 1
}

# Read .env file and extract GEMINI_API_KEY
$ApiKey = ""
Get-Content ".env" | ForEach-Object {
    if ($_ -match "^\s*GEMINI_API_KEY\s*=\s*(.+)$") {
        $ApiKey = $matches[1].Trim()
    }
}

# Validate API key was found
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host "Error: GEMINI_API_KEY not found in .env file!" -ForegroundColor Red
    Write-Host "Please add GEMINI_API_KEY=your_key to .env file" -ForegroundColor Yellow
    exit 1
}

Write-Host "API key found" -ForegroundColor Green
Write-Host ""

# Build the app
Write-Host "Step 2: Building Flutter web app..." -ForegroundColor Yellow
flutter build web --dart-define=GEMINI_API_KEY=$ApiKey --release

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
