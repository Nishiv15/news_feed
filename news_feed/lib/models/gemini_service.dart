import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'secrets_service.dart';

class GeminiService {
  static Future<String> generateSummary({
    required String title,
    required String description,
  }) async {
    final apiKey = await SecretsService.geminiApiKey;

    if (apiKey.isEmpty) {
      return 'Error: GEMINI_API_KEY could not be retrieved from the server.';
    }

    final model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: apiKey,
    );

    final prompt =
        'Summarize this news article based on the title and description '
        'in a brief description of 100-150 words:\n'
        'Title: $title\n'
        'Description: $description';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not generate summary.';
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return 'Failed to generate summary: $e';
    }
  }
}
