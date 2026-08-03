import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Creates an account AND a profile row with the chosen role
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'passenger', 'conductor', or 'admin'
    String? companyId,    // which company a conductor belongs to
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception(
        'Account created! Please check your email and click the confirmation link, then log in.',
      );
    }

    final userId = response.user!.id;

    await supabase.from('profiles').insert({
      'id': userId,
      'full_name': fullName,
      'role': role,
      'company_id': companyId,
      'approval_status': role == 'conductor' ? 'pending' : 'approved',
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Fetches the logged-in user's role from the profiles table
  Future<String?> getCurrentUserRole() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

    return data['role'] as String?;
  }

  // Fetches the logged-in user's FULL profile row (role, company_id, approval_status).
  //
  // On success, the profile is saved locally. If the live fetch fails (e.g.
  // no internet), the last saved profile is returned instead of null — this
  // is what stops AuthGate from bouncing a logged-in user back to the login
  // screen just because they went offline.
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_profile_$userId';

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        await prefs.setString(cacheKey, jsonEncode(data));
      }

      return data;
    } catch (e) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        return jsonDecode(cached) as Map<String, dynamic>;
      }
      rethrow;
    }
  }
}