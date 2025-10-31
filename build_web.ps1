# Build script for web deployment with environment variables
# Automatically reads GEMINI_API_KEY from .env file
# Usage: .\build_web.ps1

Write-Host "Reading API key from .env file..." -ForegroundColor Cyan

# Check if .env file exists
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

Write-Host "API key found! Building Flutter web app..." -ForegroundColor Green

# Build the web app with dart-define
flutter build web --dart-define=GEMINI_API_KEY=$ApiKey --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "Output directory: build/web/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To deploy to Firebase, run:" -ForegroundColor Yellow
    Write-Host "  firebase deploy --only hosting" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
