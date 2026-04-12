import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static final _supabase = Supabase.instance.client;

  static Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    required String country,
  }) async {
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': username,
      },
    );

    if (res.user != null) {
      try {
        await _supabase.from('userinfo').insert({
          'id': res.user!.id,
          'country': country,
        });
      } catch (insertError) {
        debugPrint('Error inserting to userinfo table: $insertError');
      }
    } else {
      throw Exception('Registration failed to return a valid user.');
    }
  }

  static Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final AuthResponse res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
        
    if (res.user != null) {
      final userData = await _supabase
          .from('userinfo')
          .select('country')
          .eq('id', res.user!.id)
          .maybeSingle();

      if (userData != null) {
        return userData['country'] as String?;
      }
      return null;
    } else {
      throw Exception('Login failed to return a valid user.');
    }
  }

  static Future<void> updateUserProfile({
    required String newUsername,
    required String newCountry,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    await _supabase.auth.updateUser(
      UserAttributes(
        data: {'display_name': newUsername},
      ),
    );

    await _supabase.from('userinfo').upsert({
      'id': user.id,
      'country': newCountry,
      'updated_at': DateTime.now().toIso8601String(),
      });
  }

  static Future<void> updateUserPassword({required String newPassword}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');
    
    await _supabase.auth.updateUser(UserAttributes(
      password: newPassword,
    ));
  }

  /// Logs out the currently authenticated user
  static Future<void> logoutUser() async {
    await _supabase.auth.signOut();
  }


  static Future<void> toggleSavedArticle(Map<String, dynamic> articleMap, bool isSaving) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Fail gracefully if not logged in.
    if (isSaving) {
      // Insert explicitly
      await _supabase.from('saved_articles').insert({
        'user_id': user.id,
        'title': articleMap['title'],
        'description': articleMap['description'] ?? '',
        'url': articleMap['url'],
        'image_url': articleMap['imageUrl'],
      });
    } else {
      await _supabase.from('saved_articles').delete().match({
        'user_id': user.id,
        'url': articleMap['url'],
      });
    }
  }

  static Future<bool> isArticleSaved(String articleUrl) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final response = await _supabase.from('saved_articles').select('id').match({
      'user_id': user.id,
      'url': articleUrl
    }).maybeSingle();

    return response != null;
  }

  static Future<List<Map<String, dynamic>>> fetchSavedArticles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase.from('saved_articles').select().eq('user_id', user.id).order('created_at', ascending: false);
    
    return response.map<Map<String, dynamic>>((row) {
      return {
        'title': row['title'],
        'description': row['description'],
        'content': '', // Stubbed dynamically as column missing
        'url': row['url'],
        'imageUrl': row['image_url'],
        'sourceName': 'Saved Article', // Stubbed formatting dynamically
        'publishedAt': row['created_at'], 
      };
    }).toList();
  }
}
