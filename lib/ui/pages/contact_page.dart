import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../core/theme/app_theme.dart';

/// Contact page with form to send messages
class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showNotification(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _NotificationBox(
        message: message,
        isError: isError,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(contactMessagesNotifierProvider.notifier);
      await notifier.submitMessage(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        
        // Clear form first
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        
        // Then show notification
        _showNotification(
          context,
          message: l10n.messageSent,
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showNotification(
          context,
          message: '${l10n.error}: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResponsiveLayout(
          mobile: _buildForm(l10n, context),
          tablet: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _buildForm(l10n, context),
            ),
          ),
          desktop: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: _buildForm(l10n, context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, BuildContext context) {
    return GlowCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.getInTouch,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: 32),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 100.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 16),
            
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
            
            // Message field
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: l10n.message,
              //  prefixIcon: const Icon(Icons.message_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.send,
                      style: const TextStyle(fontSize: 16),
                    ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }
}

/// Custom notification box that appears on the side
class _NotificationBox extends StatefulWidget {
  final String message;
  final bool isError;

  const _NotificationBox({
    required this.message,
    required this.isError,
  });

  @override
  State<_NotificationBox> createState() => _NotificationBoxState();
}

class _NotificationBoxState extends State<_NotificationBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto-dismiss animation
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Positioned(
      top: 80,
      right: isRTL ? null : 20,
      left: isRTL ? 20 : null,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: widget.isError
                    ? const Color(0xFFDC3545)
                    : const Color(0xFF28A745),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
