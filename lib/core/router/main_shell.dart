import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/providers/locale_provider.dart';
import 'package:portfolio/providers/auth_provider.dart';

/// Main shell with navigation bar matching design spec
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authNotifierProvider);
    final isLoggedIn = authState.asData?.value != null;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _CustomNavBar(
          currentPath: currentPath,
          locale: locale,
          isLoggedIn: isLoggedIn,
          onLanguageToggle: () {
            ref.read(localeProvider.notifier).toggleLocale();
          },
          onLogout: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/');
            }
          },
        ),
      ),
      body: child,
    );
  }
}

/// Custom navbar matching design spec
class _CustomNavBar extends StatelessWidget {
  final String currentPath;
  final Locale locale;
  final bool isLoggedIn;
  final VoidCallback onLanguageToggle;
  final VoidCallback onLogout;

  const _CustomNavBar({
    required this.currentPath,
    required this.locale,
    required this.isLoggedIn,
    required this.onLanguageToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isArabic = locale.languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo / Username
          _buildLogo(context),
          
          if (!isMobile) ...[
            // Desktop Navigation Links
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavLink(
                    label: isArabic ? 'الرئيسية' : 'Home',
                    path: '/',
                    isActive: currentPath == '/',
                  ),
                  const SizedBox(width: 32),
                  _NavLink(
                    label: isArabic ? 'أعمالي' : 'Projects',
                    path: '/projects',
                    isActive: currentPath == '/projects',
                  ),
                  const SizedBox(width: 32),
                  _NavLink(
                    label: isArabic ? 'تواصل معي' : 'Contact',
                    path: '/contact',
                    isActive: currentPath == '/contact',
                  ),
                  if (isLoggedIn) const SizedBox(width: 32),
                  if (isLoggedIn)
                    _NavLink(
                      label: isArabic ? 'لوحة التحكم' : 'Dashboard',
                      path: '/admin/dashboard',
                      isActive: currentPath.startsWith('/admin'),
                    ),
                ],
              ),
            ),
          ],
          
          // Right side actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Language toggle
              _LanguageToggle(
                isArabic: isArabic,
                onToggle: onLanguageToggle,
              ),
              
              // Logout button (if logged in)
              if (isLoggedIn) ...[
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: onLogout,
                  tooltip: isArabic ? 'تسجيل الخروج' : 'Logout',
                ),
              ],
              
              // Mobile menu
              if (isMobile) ...[
                const SizedBox(width: 8),
                _MobileMenu(
                  currentPath: currentPath,
                  isArabic: isArabic,
                  isLoggedIn: isLoggedIn,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'toalhussein',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation link widget
class _NavLink extends StatefulWidget {
  final String label;
  final String path;
  final bool isActive;

  const _NavLink({
    required this.label,
    required this.path,
    required this.isActive,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive || _isHovered
                    ? AppTheme.primaryBlue
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isActive || _isHovered
                  ? Colors.white
                  : AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Language toggle button
class _LanguageToggle extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onToggle;

  const _LanguageToggle({
    required this.isArabic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'EN',
            isActive: !isArabic,
            onTap: isArabic ? onToggle : null,
          ),
          _LanguageButton(
            label: 'AR',
            isActive: isArabic,
            onTap: !isArabic ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

/// Individual language button
class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _LanguageButton({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Mobile menu drawer
class _MobileMenu extends StatelessWidget {
  final String currentPath;
  final bool isArabic;
  final bool isLoggedIn;

  const _MobileMenu({
    required this.currentPath,
    required this.isArabic,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF0A0F1D),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MobileNavItem(
                  label: isArabic ? 'الرئيسية' : 'Home',
                  icon: Icons.home,
                  path: '/',
                  isActive: currentPath == '/',
                ),
                _MobileNavItem(
                  label: isArabic ? 'أعمالي' : 'Projects',
                  icon: Icons.work,
                  path: '/projects',
                  isActive: currentPath == '/projects',
                ),
                _MobileNavItem(
                  label: isArabic ? 'تواصل معي' : 'Contact',
                  icon: Icons.message,
                  path: '/contact',
                  isActive: currentPath == '/contact',
                ),
                if (isLoggedIn)
                  _MobileNavItem(
                    label: isArabic ? 'لوحة التحكم' : 'Dashboard',
                    icon: Icons.dashboard,
                    path: '/admin/dashboard',
                    isActive: currentPath.startsWith('/admin'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Mobile navigation item
class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String path;
  final bool isActive;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.path,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primaryBlue : Colors.white,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.primaryBlue : Colors.white,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}
