import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

/// Supabase client singleton for the entire app
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  /// Get singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Get auth instance
  GoTrueClient get auth => client.auth;

  /// Get storage instance
  SupabaseStorageClient get storage => client.storage;

  /// Check if user is authenticated
  bool get isAuthenticated => auth.currentUser != null;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current user ID
  String? get currentUserId => auth.currentUser?.id;
}
