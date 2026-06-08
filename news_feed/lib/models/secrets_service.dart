import 'package:supabase_flutter/supabase_flutter.dart';

class SecretsService {
  static final _supabase = Supabase.instance.client;

  static Map<String, String>? _cache;
  static bool _fetchAttempted = false;

  static Future<Map<String, String>> _getAll() async {
    if (_cache != null) return _cache!;
    if (_fetchAttempted) return {};

    _fetchAttempted = true;

    try {
      final response = await _supabase.functions.invoke('bright-responder');
      final data = response.data as Map<String, dynamic>;
      _cache = data.map((k, v) => MapEntry(k, v.toString()));
      return _cache!;
    } catch (_) {
      return {};
    }
  }

  static Future<String> get supabaseUrl async =>
      (await _getAll())['SUPA_URL'] ?? '';

  static Future<String> get supabaseAnonKey async =>
      (await _getAll())['SUPA_ANON_KEY'] ?? '';

  static Future<String> get gnewsApiKey async =>
      (await _getAll())['apikey'] ?? '';

  static Future<String> get gnewsBaseUrl async =>
      (await _getAll())['baseurl'] ?? '';

  static Future<String> get corsProxy async =>
      (await _getAll())['corsproxy'] ?? '';

  static Future<String> get geminiApiKey async =>
      (await _getAll())['GEMINI_API_KEY'] ?? '';

  static void clearCache() {
    _cache = null;
    _fetchAttempted = false;
  }
}
