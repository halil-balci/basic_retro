import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/constants/environment.dart';

/// Data source for Gemini AI API integration
class GeminiDataSource {
  final DioClient _dioClient;
  
  // Load API key from compile-time environment variables
  String get _apiKey => Environment.geminiApiKey;

  GeminiDataSource(this._dioClient);

  /// Generate action item from thoughts using Gemini AI
  /// 
  /// [thoughtTexts] - List of thought texts from a group
  /// Returns the generated action item suggestion
  Future<String> generateActionItem(List<String> thoughtTexts) async {
    // Check if API key is available
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Please add GEMINI_API_KEY to .env file');
    }
    
    try {
      // Create a prompt from the thoughts
      final prompt = _createPrompt(thoughtTexts);

      // Prepare request body
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };

      // Make API call using Dio instance directly to use full URL
      final response = await _dioClient.dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-goog-api-key': _apiKey,
          },
        ),
      );

      // Parse response
      if (response.data != null && 
          response.data['candidates'] != null && 
          response.data['candidates'].isNotEmpty) {
        final candidate = response.data['candidates'][0];
        if (candidate['content'] != null && 
            candidate['content']['parts'] != null &&
            candidate['content']['parts'].isNotEmpty) {
          return candidate['content']['parts'][0]['text'] as String;
        }
      }

      throw Exception('Invalid response format from Gemini API');
    } on DioException catch (e) {
      // Handle rate limiting specifically
      if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please wait a few seconds and try again.');
      }
      throw NetworkExceptions.fromDioError(e);
    } catch (e) {
      throw Exception('Failed to generate action item: $e');
    }
  }

  /// Create a prompt for Gemini AI from thought texts
  String _createPrompt(List<String> thoughtTexts) {
    final thoughtsList = thoughtTexts.map((text) => '- $text').join('\\n');
    
    return 'Sen bir retrospektif toplantısında ekibe yardımcı olan bir asistansın. Takım üyelerinin paylaştığı aşağıdaki düşüncelere dayanarak, ana sorunu veya iyileştirme önerisini ele alan net, uygulanabilir ve kısa bir aksiyon maddesi oluştur.\\n\\nTakım düşünceleri:\\n$thoughtsList\\n\\nLütfen takımın üzerinde çalışabileceği TEK, spesifik ve uygulanabilir bir aksiyon maddesi sun. Aksiyon maddesi şunları içermelidir:\\n- Net bir eylem fiili ile başlamalı\\n- Spesifik ve ölçülebilir olmalı\\n- Bir sprint veya makul bir zaman diliminde gerçekleştirilebilir olmalı\\n- Temel sorunu veya iyileştirme fırsatını ele almalı\\n\\nSADECE aksiyon maddesini üret, açıklama veya giriş yapmadan. Cevabını TÜRKÇE olarak ver.';
  }
}
