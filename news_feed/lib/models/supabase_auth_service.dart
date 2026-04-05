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
    );

    if (res.user != null) {
      try {
        await _supabase.from('users').insert({
          'id': res.user!.id,
          'username': username,
          'email': email,
          'password': 'SUPABASE_AUTH_MANAGED', // Handled by SB Auth securely
          'country': country,
        });
      } catch (insertError) {
        debugPrint('Error inserting to users table: $insertError');
      }
    } else {
      throw Exception('Registration failed to return a valid user.');
    }
  }

  /// Logs a user in and retrieves their specific country choice from DB
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
          .from('users')
          .select('country')
          .eq('email', email)
          .maybeSingle();

      if (userData != null && userData['country'] != null) {
        return userData['country'] as String;
      }
      return null;
    } else {
      throw Exception('Login failed to return a valid user.');
    }
  }
}
