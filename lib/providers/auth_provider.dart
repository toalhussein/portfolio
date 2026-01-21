import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../data/models/admin_user_model.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Current admin user provider
final currentAdminProvider = FutureProvider<AdminUser?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentAdmin();
});

/// Is admin provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isAdmin();
});

/// Auth state notifier for handling authentication state
class AuthNotifier extends StateNotifier<AsyncValue<AdminUser?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final admin = await _authService.getCurrentAdmin();
      state = AsyncValue.data(admin);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    print('🔐 AuthNotifier.signIn: Starting login for $email');
    state = const AsyncValue.loading();
    try {
      final admin = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      print('✅ AuthNotifier.signIn: Login successful, admin: ${admin?.email}');
      state = AsyncValue.data(admin);
    } catch (e, stack) {
      print('❌ AuthNotifier.signIn: Login failed - $e');
      // Keep state as data(null) instead of error to prevent router redirects
      state = const AsyncValue.data(null);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh auth status
  Future<void> refresh() async {
    await _checkAuthStatus();
  }
}

/// Auth state provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AdminUser?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
