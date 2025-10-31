/// Environment configuration for the app
/// API keys and sensitive data should be passed as compile-time variables
class Environment {
  /// Gemini API key for AI features
  /// Pass via: flutter build web --dart-define=GEMINI_API_KEY=your_key_here
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Check if Gemini API key is configured
  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;
}
