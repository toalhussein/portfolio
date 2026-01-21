import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/project_provider.dart';
import '../../core/theme/app_theme.dart';

/// Dialog for creating/editing projects with all fields
class AdminProjectDialog extends ConsumerStatefulWidget {
  final dynamic project; // null for create, Project for edit

  const AdminProjectDialog({super.key, this.project});

  @override
  ConsumerState<AdminProjectDialog> createState() => _AdminProjectDialogState();
}

class _AdminProjectDialogState extends ConsumerState<AdminProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _techStackController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _githubUrlController;
  late final TextEditingController _playStoreUrlController;
  late final TextEditingController _featureController;
  late final List<String> _keyFeatures;
  late final List<String> _screenshots;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _techStackController = TextEditingController(text: widget.project?.techStack ?? '');
    _imageUrlController = TextEditingController(text: widget.project?.imageUrl ?? '');
    _githubUrlController = TextEditingController(text: widget.project?.githubUrl ?? '');
    _playStoreUrlController = TextEditingController(text: widget.project?.playStoreUrl ?? '');
    _featureController = TextEditingController();
    _keyFeatures = widget.project?.keyFeatures != null 
        ? List<String>.from(widget.project!.keyFeatures) 
        : [];
    _screenshots = widget.project?.screenshots != null 
        ? List<String>.from(widget.project!.screenshots) 
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _imageUrlController.dispose();
    _githubUrlController.dispose();
    _playStoreUrlController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() => _isSubmitting = true);
        
        final notifier = ref.read(projectsNotifierProvider.notifier);
        final imageUrl = await notifier.uploadImage(
          result.files.single.name,
          result.files.single.bytes!,
        );
        
        _imageUrlController.text = imageUrl;
        
        setState(() => _isSubmitting = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickScreenshots() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isSubmitting = true);
        
        final notifier = ref.read(projectsNotifierProvider.notifier);
        
        for (final file in result.files) {
          if (file.bytes != null) {
            final imageUrl = await notifier.uploadImage(
              file.name,
              file.bytes!,
            );
            setState(() => _screenshots.add(imageUrl));
          }
        }
        
        setState(() => _isSubmitting = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.files.length} screenshots uploaded!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading screenshots: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addFeature() {
    if (_featureController.text.trim().isNotEmpty) {
      setState(() {
        _keyFeatures.add(_featureController.text.trim());
        _featureController.clear();
      });
    }
  }

  void _removeFeature(int index) {
    setState(() => _keyFeatures.removeAt(index));
  }

  void _removeScreenshot(int index) {
    setState(() => _screenshots.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(projectsNotifierProvider.notifier);
      final l10n = AppLocalizations.of(context)!;

      if (widget.project == null) {
        // Create new project
        await notifier.createProject(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          techStack: _techStackController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          githubUrl: _githubUrlController.text.trim().isEmpty
              ? null
              : _githubUrlController.text.trim(),
          playStoreUrl: _playStoreUrlController.text.trim().isEmpty
              ? null
              : _playStoreUrlController.text.trim(),
          keyFeatures: _keyFeatures,
          screenshots: _screenshots,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.projectAdded),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing project
        await notifier.updateProject(
          id: widget.project.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          techStack: _techStackController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          githubUrl: _githubUrlController.text.trim().isEmpty
              ? null
              : _githubUrlController.text.trim(),
          playStoreUrl: _playStoreUrlController.text.trim().isEmpty
              ? null
              : _playStoreUrlController.text.trim(),
          keyFeatures: _keyFeatures,
          screenshots: _screenshots,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.projectUpdated),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
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
    final isEdit = widget.project != null;

    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              isEdit ? l10n.editProject : l10n.addProject,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: l10n.title),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: l10n.description),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Tech stack field
                      TextFormField(
                        controller: _techStackController,
                        decoration: InputDecoration(
                          labelText: l10n.techStack,
                          hintText: 'Flutter, Dart, Firebase',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Logo section
                      Text(
                        'App Logo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_imageUrlController.text.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _imageUrlController.text,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _pickLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Logo'),
                      ),
                      const SizedBox(height: 24),
                      
                      // GitHub URL
                      TextFormField(
                        controller: _githubUrlController,
                        decoration: const InputDecoration(
                          labelText: 'GitHub URL',
                          hintText: 'https://github.com/...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Play Store URL
                      TextFormField(
                        controller: _playStoreUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Google Play URL',
                          hintText: 'https://play.google.com/store/apps/...',
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Key Features section
                      Text(
                        'Key Features',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _featureController,
                              decoration: const InputDecoration(
                                hintText: 'Add a feature...',
                              ),
                              onSubmitted: (_) => _addFeature(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                            onPressed: _addFeature,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_keyFeatures.isNotEmpty)
                        ...List.generate(_keyFeatures.length, (index) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle, size: 20),
                            title: Text(_keyFeatures[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _removeFeature(index),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      
                      // Screenshots section
                      Text(
                        'Screenshots',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _pickScreenshots,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Add Screenshots'),
                      ),
                      const SizedBox(height: 8),
                      if (_screenshots.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _screenshots.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: _screenshots[index],
                                        height: 120,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => _removeScreenshot(index),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
