import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static final _supabase = Supabase.instance.client;

  /// Checks if a user exists in userinfo and returns their isActive status.
  static Future<bool?> _checkUserActiveStatus(String userId) async {
    final row = await _supabase
        .from('userinfo')
        .select('isActive')
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null; // User not in userinfo
    return row['isActive'] as bool;
  }

  
  static Future<String> registerUser({
    required String email,
    required String password,
    required String username,
    required String country,
  }) async {
    // Try signing in first to check if this email already exists in auth
    try {
      final loginRes = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (loginRes.user != null) {
        final isActive = await _checkUserActiveStatus(loginRes.user!.id);

        if (isActive == true) {
          // Active user trying to register again
          await _supabase.auth.signOut();
          throw Exception('User already registered. Please login instead.');
        } else if (isActive == false) {
          // Reactivate the soft-deleted account
          await _supabase.from('userinfo').update({
            'isActive': true,
            'country': country,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', loginRes.user!.id);

          await _supabase.auth.updateUser(
            UserAttributes(data: {'display_name': username}),
          );

          return 'reactivated';
        }
      }
    } on AuthException {
    }

    // Normal registration
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
      return 'registered';
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
          .select('country, isActive')
          .eq('id', res.user!.id)
          .maybeSingle();

      if (userData != null) {
        final bool isActive = userData['isActive'] ?? true;
        if (!isActive) {
          await _supabase.auth.signOut();
          throw Exception(
            'Your account has been deactivated. Please register again to reactivate.',
          );
        }
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

  static Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    await _supabase.from('saved_articles').delete().eq('user_id', user.id);

    await _supabase.from('userinfo').update({
      'isActive': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
    
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
