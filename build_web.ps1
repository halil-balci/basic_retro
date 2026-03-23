# Build script for web deployment with environment variables
# Automatically reads GEMINI_API_KEY from .env file
# Usage: .\build_web.ps1

# Build the web app with dart-define
flutter build web --release

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
