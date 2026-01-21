import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/common_widgets.dart';
import 'admin_projects_tab.dart';
import 'admin_messages_tab.dart';

/// Admin dashboard with tabs for projects and messages
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (admin) {
        if (admin == null) {
          // Not logged in, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/admin/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.dashboard),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: l10n.logout,
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: const Icon(Icons.work_outline),
                    text: l10n.projectsTitle,
                  ),
                  Tab(
                    icon: const Icon(Icons.message_outlined),
                    text: l10n.contactMessages,
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [const AdminProjectsTab(), const AdminMessagesTab()],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: ErrorDisplay(
          message: 'Error: $error',
          onRetry: () => ref.invalidate(authNotifierProvider),
        ),
      ),
    );
  }
}
