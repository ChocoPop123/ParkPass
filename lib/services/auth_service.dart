import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Creates an account AND a profile row with the chosen role
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'passenger' or 'conductor'
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Signup failed, no user returned.');
    }

    // Now create their profile row with the extra info
    await supabase.from('profiles').insert({
      'id': userId,
      'full_name': fullName,
      'role': role,
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
}