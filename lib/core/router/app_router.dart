import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/providers/auth_provider.dart';
import 'package:portfolio/ui/pages/home_page.dart';
import 'package:portfolio/ui/pages/projects_page.dart';
import 'package:portfolio/ui/pages/contact_page.dart';
import 'package:portfolio/ui/pages/admin_login_page.dart';
import 'package:portfolio/ui/pages/admin_dashboard_page.dart';
import 'main_shell.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthNotifierListenable(ref),
    redirect: (context, state) {
      print('\n🧭 ROUTER REDIRECT - Location: ${state.matchedLocation}');
      
      // Check if user is trying to access admin routes
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isLoginRoute = state.matchedLocation == '/admin/login';
      
      print('   isAdminRoute: $isAdminRoute, isLoginRoute: $isLoginRoute');
      
      // Get auth state - only check when data is available, skip during loading
      final isAuthenticated = authNotifier.maybeWhen(
        data: (admin) {
          print('   Auth state: data(admin: ${admin?.email ?? 'null'})');
          return admin != null;
        },
        orElse: () {
          print('   Auth state: loading/error (skipping redirect logic)');
          return null;
        },
      );

      print('   isAuthenticated: $isAuthenticated');

      // Skip redirect logic if auth state is still loading
      if (isAuthenticated == null) {
        print('   ➡️ No redirect (auth loading/error)');
        return null;
      }

      // If trying to access admin dashboard without authentication, redirect to login
      if (isAdminRoute && !isLoginRoute && !isAuthenticated) {
        print('   ➡️ Redirect to /admin/login (not authenticated)');
        return '/admin/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (isLoginRoute && isAuthenticated) {
        print('   ➡️ Redirect to /admin/dashboard (already authenticated)');
        return '/admin/dashboard';
      }

      print('   ➡️ No redirect needed\n');
      return null; // No redirect needed
    },
    routes: [
      // Main shell with navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProjectsPage(),
            ),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactPage(),
            ),
          ),
        ],
      ),
      
      // Admin routes (outside main shell)
      GoRoute(
        path: '/admin/login',
        pageBuilder: (context, state) => const MaterialPage(
          child: AdminLoginPage(),
        ),
      ),
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) => const MaterialPage(
          child: AdminDashboardPage(),
        ),
      ),
    ],
  );
});

/// Custom listenable for auth state changes
class _AuthNotifierListenable extends ChangeNotifier {
  final Ref _ref;

  _AuthNotifierListenable(this._ref) {
    _ref.listen(
      authNotifierProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}
