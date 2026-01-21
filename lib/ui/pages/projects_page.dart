import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/responsive_layout.dart';
import '../../core/theme/app_theme.dart';

/// Projects page displaying all projects from Supabase
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectsNotifierProvider);

    return Scaffold(
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return EmptyState(
              message: l10n.noMessages,
              icon: Icons.work_outline,
            );
          }

          return ResponsiveLayout(
            mobile: _ProjectsGrid(projects: projects, crossAxisCount: 1),
            tablet: _ProjectsGrid(projects: projects, crossAxisCount: 2),
            desktop: _ProjectsGrid(projects: projects, crossAxisCount: 3),
          );
        },
        loading: () => LoadingSpinner(message: l10n.loading),
        error: (error, stack) => ErrorDisplay(
          message: '${l10n.error}: $error',
          onRetry: () => ref.refresh(projectsNotifierProvider),
        ),
      ),
    );
  }
}

/// Grid layout for projects
class _ProjectsGrid extends StatelessWidget {
  final List projects;
  final int crossAxisCount;

  const _ProjectsGrid({
    required this.projects,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Adjust aspect ratio based on screen size
    final aspectRatio = isMobile ? 0.75 : (isTablet ? 0.8 : 0.85);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isMobile ? 12 : 16,
          mainAxisSpacing: isMobile ? 12 : 16,
          childAspectRatio: aspectRatio,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return _ProjectCard(project: project)
              .animate()
              .fadeIn(delay: (index * 100).ms)
              .slideY(begin: 0.2, end: 0);
        },
      ),
    );
  }
}

/// Individual project card
class _ProjectCard extends StatelessWidget {
  final dynamic project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final imageHeight = isMobile ? 120.0 : 150.0;
    final titleStyle = isMobile
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.titleLarge;
    final descriptionLines = isMobile ? 2 : 3;
    
    return GestureDetector(
      onTap: () => _showProjectDetails(context, project),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project image
              if (project.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  child: CachedNetworkImage(
                    imageUrl: project.imageUrl!,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: imageHeight,
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: imageHeight,
                      color: AppTheme.surfaceColor,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                )
              else
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.code,
                      size: isMobile ? 36 : 48,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              SizedBox(height: isMobile ? 8 : 12),
              
              // Project title
              Text(
                project.title,
                style: titleStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 6 : 8),
              
              // Project description
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 13 : null,
                    ),
                maxLines: descriptionLines,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              SizedBox(height: isMobile ? 8 : 12),
              
              // Tech stack
              Wrap(
                spacing: isMobile ? 3 : 4,
                runSpacing: isMobile ? 3 : 4,
                children: project.techStack
                    .split(',')
                    .map<Widget>((tech) => _TechChip(
                          tech: tech.trim(),
                          isMobile: isMobile,
                        ))
                    .toList(),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              
              // View Details button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showProjectDetails(context, project),
                  icon: Icon(Icons.remove_red_eye_outlined, size: isMobile ? 16 : 18),
                  label: Text(
                    'View Details',
                    style: TextStyle(fontSize: isMobile ? 13 : 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 8 : 12,
                      horizontal: isMobile ? 12 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectDetails(BuildContext context, dynamic project) {
    showDialog(
      context: context,
      builder: (context) => _ProjectDetailsDialog(project: project),
    );
  }
}

/// Tech stack chip
class _TechChip extends StatelessWidget {
  final String tech;
  final bool isMobile;

  const _TechChip({required this.tech, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.3),
        ),
      ),
      child: Text(
        tech,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.accentBlue,
              fontSize: isMobile ? 10 : 11,
            ),
      ),
    );
  }
}

/// Project Details Dialog
class _ProjectDetailsDialog extends StatelessWidget {
  final dynamic project;

  const _ProjectDetailsDialog({required this.project});

  void _showFullScreenImage(BuildContext context, String imageUrl, {List<String>? allImages}) {
    showDialog(
      context: context,
      builder: (context) => _FullScreenImageDialog(
        imageUrl: imageUrl,
        allImages: allImages ?? [imageUrl],
        initialIndex: allImages?.indexOf(imageUrl) ?? 0,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final maxWidth = isMobile ? screenWidth - 32 : 800.0;
    final maxHeight = MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.85);
    
    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with logo and close button
              Row(
                children: [
                  // App logo
                  if (project.imageUrl != null)
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, project.imageUrl!),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                          child: CachedNetworkImage(
                            imageUrl: project.imageUrl!,
                            width: isMobile ? 60 : 80,
                            height: isMobile ? 60 : 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: isMobile ? 60 : 80,
                      height: isMobile ? 60 : 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                      ),
                      child: Icon(Icons.code, size: isMobile ? 30 : 40, color: AppTheme.primaryBlue),
                    ),
                  SizedBox(width: isMobile ? 12 : 16),
                  
                  // App name
                  Expanded(
                    child: Text(
                      project.title,
                      style: (isMobile
                              ? Theme.of(context).textTheme.titleLarge
                              : Theme.of(context).textTheme.headlineSmall)
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, size: isMobile ? 24 : 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 24),
              
              // Description
              Text(
                'Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      fontSize: isMobile ? 16 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: isMobile ? 13 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              
              // Technologies
              Text(
                'Technologies',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      fontSize: isMobile ? 16 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Wrap(
                spacing: isMobile ? 6 : 8,
                runSpacing: isMobile ? 6 : 8,
                children: project.techStack
                    .split(',')
                    .map<Widget>((tech) => _TechChip(tech: tech.trim(), isMobile: isMobile))
                    .toList(),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              
              // Key Features
              if (project.keyFeatures.isNotEmpty) ...[
                Text(
                  'Key Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        fontSize: isMobile ? 16 : null,
                      ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                ...project.keyFeatures.map<Widget>((feature) => Padding(
                      padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: isMobile ? 18 : 20),
                          SizedBox(width: isMobile ? 6 : 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: isMobile ? 13 : null,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: isMobile ? 16 : 24),
              ],
              
              // Screenshots
              if (project.screenshots.isNotEmpty) ...[
                Text(
                  'Screenshots',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        fontSize: isMobile ? 16 : null,
                      ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                SizedBox(
                  height: isMobile ? 150 : 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: project.screenshots.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(
                          context,
                          project.screenshots[index],
                          allImages: project.screenshots,
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Padding(
                            padding: EdgeInsets.only(right: isMobile ? 6 : 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                              child: CachedNetworkImage(
                                imageUrl: project.screenshots[index],
                                height: isMobile ? 150 : 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
              ],
              
              // Links
              isMobile
                  ? Column(
                      children: [
                        if (project.githubUrl != null && project.githubUrl!.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(project.githubUrl!),
                              icon: const Icon(Icons.code_rounded, size: 18),
                              label: const Text('GitHub'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(color: AppTheme.primaryBlue),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        if (project.githubUrl != null &&
                            project.githubUrl!.isNotEmpty &&
                            project.playStoreUrl != null &&
                            project.playStoreUrl!.isNotEmpty)
                          const SizedBox(height: 8),
                        if (project.playStoreUrl != null && project.playStoreUrl!.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _launchUrl(project.playStoreUrl!),
                              icon: const Icon(Icons.play_arrow_rounded, size: 18),
                              label: const Text('Google Play'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Row(
                      children: [
                        if (project.githubUrl != null && project.githubUrl!.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrl(project.githubUrl!),
                              icon: const Icon(Icons.code_rounded),
                              label: const Text('GitHub'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(color: AppTheme.primaryBlue),
                              ),
                            ),
                          ),
                        if (project.githubUrl != null &&
                            project.githubUrl!.isNotEmpty &&
                            project.playStoreUrl != null &&
                            project.playStoreUrl!.isNotEmpty)
                          const SizedBox(width: 8),
                        if (project.playStoreUrl != null && project.playStoreUrl!.isNotEmpty)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _launchUrl(project.playStoreUrl!),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Google Play'),
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}

/// Full Screen Image Dialog with navigation
class _FullScreenImageDialog extends StatefulWidget {
  final String imageUrl;
  final List<String> allImages;
  final int initialIndex;

  const _FullScreenImageDialog({
    required this.imageUrl,
    required this.allImages,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageDialog> createState() => _FullScreenImageDialogState();
}

class _FullScreenImageDialogState extends State<_FullScreenImageDialog> {
  late int currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (currentIndex < widget.allImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.allImages.length > 1;

    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Image PageView
          Center(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allImages.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.allImages[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Previous button
          if (hasMultipleImages && currentIndex > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
                  onPressed: _previousImage,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ),
          
          // Next button
          if (hasMultipleImages && currentIndex < widget.allImages.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                  onPressed: _nextImage,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ),
          
          // Close button and counter
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                // Image counter
                if (hasMultipleImages)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${widget.allImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (hasMultipleImages) const SizedBox(width: 8),
                
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
