# Web Deployment Guide

## Problem: Gemini API Key Not Found in Production

When deploying Flutter web apps, `.env` files are not included in the build. Environment variables must be passed at build time.

## Solution: Build-Time Environment Variables

### Quick Start (Automatic - Recommended)

The scripts automatically read your API key from `.env` file:

**Windows (PowerShell):**
```powershell
# Build only
.\build_web.ps1

# Build AND deploy in one command
.\deploy.ps1
```

**Mac/Linux:**
```bash
# Make scripts executable (first time only)
chmod +x build_web.sh deploy.sh

# Build only
./build_web.sh

# Build AND deploy in one command
./deploy.sh
```

### Prerequisites

Make sure you have a `.env` file in your project root:
```bash
GEMINI_API_KEY=your_actual_api_key_here
```

This file is already in `.gitignore` so it won't be committed to git.

### Manual Build Command

If you prefer to build manually:

```bash
flutter build web --dart-define=GEMINI_API_KEY=your_actual_api_key_here --release
```

### Manual Firebase Deployment

After building:

```bash
firebase deploy --only hosting
```

### What Changed

1. **Removed `flutter_dotenv` dependency** - Not needed for web deployments
2. **Created `Environment` class** - Reads compile-time variables via `String.fromEnvironment()`
3. **Updated `GeminiDataSource`** - Now uses `Environment.geminiApiKey` instead of dotenv
4. **Removed dotenv from main.dart** - No longer loading `.env` file at runtime
5. **Automated build scripts** - `build_web.ps1` and `deploy.ps1` automatically read from `.env`

### Security Note

- **Never commit API keys to git** - `.env` file is already in `.gitignore`
- The `.env` file stays on your local machine only
- For CI/CD pipelines, store API key in secrets (GitHub Secrets, GitLab CI Variables, etc.)
- Each deployment environment can have its own API key

### CI/CD Integration

For automated deployments, use your CI/CD platform's secret management:

**GitHub Actions example:**
```yaml
- name: Build Flutter Web
  run: flutter build web --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }} --release
```

**GitLab CI example:**
```yaml
build:
  script:
    - flutter build web --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY --release
```

### Verifying the Build

After building, you can test locally:

```bash
# Serve the built files locally
firebase serve --only hosting

# Or use Python's HTTP server
cd build/web
python -m http.server 8000
```

Then open `http://localhost:8000` in your browser and test the Gemini AI features.

### Troubleshooting

**Issue:** "Gemini API key not found" error in production

**Solutions:**
1. Verify you built with `--dart-define=GEMINI_API_KEY=...`
2. Check that the build/web folder contains the latest build
3. Ensure you're deploying the correct build/web directory
4. Clear browser cache and reload

**Issue:** API key exposed in JavaScript

Don't worry - API keys for server APIs are meant to be used client-side. Use Firebase App Check or API key restrictions in Google Cloud Console to secure your Gemini API:
1. Go to Google Cloud Console → API Keys
2. Restrict the key to specific HTTP referrers (your domain)
3. Restrict to only Gemini API

### Get Your Gemini API Key

If you don't have a Gemini API key yet:
1. Visit https://ai.google.dev/
2. Click "Get API key"
3. Create a new project or select existing
4. Copy your API key
