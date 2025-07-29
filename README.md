# Firebase Retro Board

A Flutter web application for retrospective meetings with Firebase backend.

## Setup Instructions

1. Clone the repository
2. Copy `lib/firebase_options.dart.template` to `lib/firebase_options.dart`
3. Replace the placeholder values in `firebase_options.dart` with your actual Firebase configuration
4. Run `flutter pub get`
5. Run `flutter run -d chrome`

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
