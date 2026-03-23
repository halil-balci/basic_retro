import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
/// Loads configuration from the .env file.
class Environment {
  /// Gemini API key for AI features
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Check if Gemini API key is configured
  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;
}
