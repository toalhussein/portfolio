import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/common_widgets.dart';
import '../../core/theme/app_theme.dart';
import 'admin_project_dialog.dart';

/// Admin tab for managing projects (CRUD operations)
class AdminProjectsTab extends ConsumerWidget {
  const AdminProjectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectsNotifierProvider);

    return Scaffold(
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return EmptyState(
              message: 'No projects yet',
              icon: Icons.work_outline,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectListItem(project: project)
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .slideX(begin: -0.2, end: 0);
            },
          );
        },
        loading: () => LoadingSpinner(message: l10n.loading),
        error: (error, stack) => ErrorDisplay(
          message: '${l10n.error}: $error',
          onRetry: () => ref.refresh(projectsNotifierProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addProject),
      )
          .animate()
          .scale(delay: 300.ms),
    );
  }

  void _showProjectDialog(BuildContext context, WidgetRef ref, [dynamic project]) {
    showDialog(
      context: context,
      builder: (context) => AdminProjectDialog(project: project),
    );
  }
}

/// Project list item with edit and delete actions
class _ProjectListItem extends ConsumerWidget {
  final dynamic project;

  const _ProjectListItem({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return GlowCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project image thumbnail
          if (project.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: project.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.surfaceColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.surfaceColor,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.code, color: AppTheme.primaryBlue),
            ),
          const SizedBox(width: 16),
          
          // Project info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  project.techStack,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                onPressed: () => _showEditDialog(context, ref, project),
                tooltip: l10n.editProject,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context, ref, project),
                tooltip: l10n.deleteProject,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, dynamic project) {
    showDialog(
      context: context,
      builder: (context) => AdminProjectDialog(project: project),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, dynamic project) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProject),
        content: Text('Are you sure you want to delete "${project.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(projectsNotifierProvider.notifier)
                    .deleteProject(project.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.projectDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
