import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Custom app bar for the portfolio
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.2, end: 0),
      leading: leading,
      actions: actions,
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
