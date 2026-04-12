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

  static Future<void> logoutUser() async {
    await _supabase.auth.signOut();
  }
}
