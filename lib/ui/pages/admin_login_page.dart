import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glow_card.dart';
import '../../core/theme/app_theme.dart';

/// Admin login page
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    print('\n🚀 Login button clicked - Email: ${_emailController.text.trim()}');
    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      print('📞 Calling authNotifier.signIn...');
      await authNotifier.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('✅ Login successful, waiting for state to settle...');
      if (mounted) {
        // Wait for the auth state to propagate to the router
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Verify we're authenticated before navigating
        final authState = ref.read(authNotifierProvider);
        final isAuthenticated = authState.maybeWhen(
          data: (admin) => admin != null,
          orElse: () => false,
        );
        
        print('🔍 Auth state check - isAuthenticated: $isAuthenticated');
        
        if (isAuthenticated) {
          context.go('/admin/dashboard');
          print('🎯 Navigation to /admin/dashboard executed');
        } else {
          print('⚠️ Still not authenticated, staying on login page');
        }
      }
    } catch (e) {
      print('❌ Login error caught: $e');
      if (mounted) {
        // Show detailed error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        print('📢 Error SnackBar shown');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('⏹️ Loading state set to false\n');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: GlowCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Admin icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 64,
                        color: AppTheme.primaryBlue,
                      ),
                    )
                        .animate()
                        .scale(duration: 400.ms)
                        .fadeIn(),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      l10n.adminTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 32),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 16),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.requiredField;
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 24),
                    
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.login,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    const SizedBox(height: 16),
                    
                    // Back to home button
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.homeTitle),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
