# Firebase Retro Board

A Flutter web application for retrospective meetings with Firebase backend.

## Setup Instructions

1. Clone the repository

2. **Setup Firebase Configuration:**
   - Copy `lib/firebase_options.dart.template` to `lib/firebase_options.dart`
   - Replace the placeholder values with your actual Firebase configuration

3. **Get Gemini API Key:**
   - Get your API key from: https://ai.google.dev/
   - You'll need this for deployment

4. Run `flutter pub get`

5. **For local development:**
   ```bash
   flutter run -d chrome --dart-define=GEMINI_API_KEY=your_api_key_here
   ```

## Deployment

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed deployment instructions.

**Quick Deploy (Automatic):**

Scripts automatically read API key from your `.env` file:

```powershell
# Windows - Build and deploy in one command
.\deploy.ps1

# Or just build (then deploy manually)
.\build_web.ps1
firebase deploy --only hosting
```

```bash
# Mac/Linux - Build and deploy in one command
./deploy.sh

# Or just build (then deploy manually)
./build_web.sh
firebase deploy --only hosting
```

## Environment Variables

This project uses compile-time environment variables for API keys:
- API keys are passed during build time using `--dart-define`
- For production deployments, API keys must be included in the build command
- **Never commit API keys to git**

## Firebase Configuration

This project requires Firebase configuration. The `firebase_options.dart` file is ignored by git for security reasons. Please create your own Firebase project and update the configuration accordingly.

## Features

- Create and join retro sessions
- Add thoughts to Start, Stop, Continue categories
- Real-time collaboration
- Anonymous cards (no user identification)

## Built With

- Flutter
- Firebase (Firestore)
- Provider for state management
