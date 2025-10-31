#!/bin/bash
# Full deployment script - Build and deploy to Firebase
# Automatically reads GEMINI_API_KEY from .env file
# Usage: ./deploy.sh

echo "=== Firebase Deployment Script ==="
echo ""

# Check if .env file exists
echo "Step 1: Checking .env file..."
if [ ! -f ".env" ]; then
    echo "Error: .env file not found!"
    echo "Please create .env file with GEMINI_API_KEY=your_key"
    exit 1
fi

# Read API key from .env file
API_KEY=$(grep "^GEMINI_API_KEY=" .env | cut -d '=' -f2- | tr -d '[:space:]')

# Validate API key was found
if [ -z "$API_KEY" ]; then
    echo "Error: GEMINI_API_KEY not found in .env file!"
    echo "Please add GEMINI_API_KEY=your_key to .env file"
    exit 1
fi

echo "✓ API key found"
echo ""

# Build the app
echo "Step 2: Building Flutter web app..."
flutter build web --dart-define=GEMINI_API_KEY=$API_KEY --release

if [ $? -ne 0 ]; then
    echo "✗ Build failed!"
    exit 1
fi

echo "✓ Build completed"
echo ""

# Deploy to Firebase
echo "Step 3: Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Deployment Successful! ==="
    echo "Your app is now live on Firebase Hosting! 🚀"
else
    echo ""
    echo "✗ Deployment failed!"
    exit 1
fi
