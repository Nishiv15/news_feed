import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static GenerativeModel get _model {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.replaceAll('"', '').replaceAll("'", "").trim() ?? '';
    return GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
    );
  }

  static Future<String> generateSummary({required String title, required String description}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.replaceAll('"', '').replaceAll("'", "").trim() ?? '';
    if (apiKey.isEmpty) {
      return "Error: GEMINI_API_KEY is missing from the environment configuration.";
    }

    final prompt = 'Summarize this news article based on the title and description in a brief description of 100-150 words:\nTitle: $title\nDescription: $description';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Could not generate summary.';
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return 'Failed to generate summary: $e';
    }
  }
}
