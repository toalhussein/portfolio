import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/responsive_layout.dart';
import 'dart:math' as math;

/// Home page with Hero section matching design spec
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _HeroSection(l10n: l10n, isMobile: true),
        tablet: _HeroSection(l10n: l10n, isMobile: false),
        desktop: _HeroSection(l10n: l10n, isMobile: false),
      ),
    );
  }
}

/// Hero section with animated floating icons
class _HeroSection extends StatefulWidget {
  final AppLocalizations l10n;
  final bool isMobile;

  const _HeroSection({required this.l10n, required this.isMobile});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0F1D),
            Color(0xFF0D1425),
            Color(0xFF0A0F1D),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating animated icons
          ..._buildFloatingIcons(),
          
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(widget.isMobile ? 24 : 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Greeting text
                    Text(
                      widget.l10n.heroGreeting,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 20 : 28,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Name with blue glow effect
                    _GlowText(
                      text: widget.l10n.heroName,
                      fontSize: widget.isMobile ? 40 : 72,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 800.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    
                    const SizedBox(height: 24),
                    
                    // Subtitle
                    Text(
                      widget.l10n.heroSubtitle,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 18 : 28,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Description
                    Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        widget.l10n.heroDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 16 : 20,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 48),
                    
                    // CTA Buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _HoverButton(
                          text: widget.l10n.viewMyWork,
                          isPrimary: true,
                          onPressed: () => context.go('/projects'),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 400.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        
                        _HoverButton(
                          text: widget.l10n.contactMe,
                          isPrimary: false,
                          onPressed: () => context.go('/contact'),
                        )
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 400.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingIcons() {
    final icons = [
      Icons.flutter_dash,
      Icons.code,
      Icons.smartphone,
      Icons.devices,
      Icons.bug_report,
      Icons.design_services,
      Icons.api,
      Icons.cloud,
    ];

    return List.generate(icons.length, (index) {
      final angle = (index * 45.0) * math.pi / 180;
      final radius = widget.isMobile ? 150.0 : 250.0;
      
      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + math.cos(angle) * radius - 24,
        top: MediaQuery.of(context).size.height / 2 + math.sin(angle) * radius - 24,
        child: _FloatingIcon(
          icon: icons[index],
          delay: index * 100,
        ),
      );
    });
  }
}

/// Floating animated icon widget
class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final int delay;

  const _FloatingIcon({required this.icon, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: AppTheme.primaryBlue.withOpacity(0.6),
        size: 24,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(delay: delay.ms)
        .moveY(
          begin: 0,
          end: -20,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .moveY(
          begin: -20,
          end: 0,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Text with glow effect
class _GlowText extends StatelessWidget {
  final String text;
  final double fontSize;

  const _GlowText({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layer 1 (outer)
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..color = AppTheme.primaryBlue.withOpacity(0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 20),
          ),
        ),
        // Glow layer 2 (inner)
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = AppTheme.primaryBlue.withOpacity(0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          ),
        ),
        // Main text
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Hover button with animation
class _HoverButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _HoverButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.05 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary
                ? AppTheme.primaryBlue
                : Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            elevation: _isHovered ? 8 : 0,
            shadowColor: AppTheme.primaryBlue.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: widget.isPrimary
                  ? BorderSide.none
                  : BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
            ),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
