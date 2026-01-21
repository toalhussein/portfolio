import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/admin_user_model.dart';
import 'supabase_service.dart';

/// Authentication service for admin login/logout
class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Sign in with email and password
  /// Returns AdminUser if login successful and user is an admin
  Future<AdminUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 AuthService: Attempting Supabase Auth login for $email');
      // Sign in with Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        print('❌ AuthService: No user returned from Supabase Auth');
        throw Exception('Login failed');
      }

      print('✓ AuthService: Supabase Auth successful, checking admins table...');
      // Check if user is an admin
      final adminData = await _client
          .from('admins')
          .select()
          .eq('user_id', response.user!.id)
          .maybeSingle();

      print('📋 AuthService: Admin data: $adminData');

      if (adminData == null) {
        print('❌ AuthService: User ${response.user!.id} not found in admins table');
        // User is not an admin, sign out
        await signOut();
        throw Exception('User is not authorized as admin');
      }

      print('✅ AuthService: User is admin, login complete');
      return AdminUser(
        id: response.user!.id,
        email: response.user!.email!,
        createdAt: DateTime.parse(response.user!.createdAt),
      );
    } catch (e) {
      print('💥 AuthService: Error - $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current admin user
  Future<AdminUser?> getCurrentAdmin() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Verify user is admin
      final adminData = await _client
          .from('admins')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (adminData == null) return null;

      return AdminUser(
        id: user.id,
        email: user.email!,
        createdAt: DateTime.parse(user.createdAt),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    final admin = await getCurrentAdmin();
    return admin != null;
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
