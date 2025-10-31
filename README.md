# Firebase Retro Board

A Flutter web application for retrospective meetings with Firebase backend.

## Setup Instructions

1. Clone the repository

2. **Setup Firebase Configuration:**
   - Copy `lib/firebase_options.dart.template` to `lib/firebase_options.dart`
   - Replace the placeholder values with your actual Firebase configuration

3. **Setup Environment Variables:**
   - Copy `.env.template` to `.env`
   - Add your Gemini API key:
     ```
     GEMINI_API_KEY=your_api_key_here
     ```
   - Get your API key from: https://ai.google.dev/

4. Run `flutter pub get`

5. Run `flutter run -d chrome`

## Environment Variables

This project uses environment variables for sensitive data like API keys. 
- **Never commit the `.env` file to git**
- Always use `.env.template` as a reference for required variables

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
