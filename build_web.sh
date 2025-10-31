#!/bin/bash
# Build script for web deployment with environment variables
# Automatically reads GEMINI_API_KEY from .env file
# Usage: ./build_web.sh

echo "Reading API key from .env file..."

# Check if .env file exists
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

echo "API key found! Building Flutter web app..."

# Build the web app with dart-define
flutter build web --dart-define=GEMINI_API_KEY=$API_KEY --release

if [ $? -eq 0 ]; then
    echo ""
    echo "Build completed successfully! ✓"
    echo "Output directory: build/web/"
    echo ""
    echo "To deploy to Firebase, run:"
    echo "  firebase deploy --only hosting"
else
    echo ""
    echo "Build failed! ✗"
    exit 1
fi
