import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/project_service.dart';
import '../data/models/project_model.dart';

/// Project service provider
final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

/// All projects provider
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final projectService = ref.watch(projectServiceProvider);
  return await projectService.getAllProjects();
});

/// Single project provider by ID
final projectByIdProvider = FutureProvider.family<Project?, String>((ref, id) async {
  final projectService = ref.watch(projectServiceProvider);
  return await projectService.getProjectById(id);
});

/// Projects state notifier for managing projects
class ProjectsNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectService _projectService;

  ProjectsNotifier(this._projectService) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  /// Load all projects
  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _projectService.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Create a new project
  Future<void> createProject({
    required String title,
    required String description,
    required String techStack,
    String? imageUrl,
    String? githubUrl,
    String? playStoreUrl,
    List<String>? keyFeatures,
    List<String>? screenshots,
  }) async {
    try {
      await _projectService.createProject(
        title: title,
        description: description,
        techStack: techStack,
        imageUrl: imageUrl,
        githubUrl: githubUrl,
        playStoreUrl: playStoreUrl,
        keyFeatures: keyFeatures,
        screenshots: screenshots,
      );
      await loadProjects(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Update a project
  Future<void> updateProject({
    required String id,
    String? title,
    String? description,
    String? techStack,
    String? imageUrl,
    String? githubUrl,
    String? playStoreUrl,
    List<String>? keyFeatures,
    List<String>? screenshots,
  }) async {
    try {
      await _projectService.updateProject(
        id: id,
        title: title,
        description: description,
        techStack: techStack,
        imageUrl: imageUrl,
        githubUrl: githubUrl,
        playStoreUrl: playStoreUrl,
        keyFeatures: keyFeatures,
        screenshots: screenshots,
      );
      await loadProjects(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    try {
      await _projectService.deleteProject(id);
      await loadProjects(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Upload project image
  Future<String> uploadImage(String filePath, List<int> fileBytes) async {
    try {
      return await _projectService.uploadProjectImage(filePath, fileBytes);
    } catch (e) {
      rethrow;
    }
  }
}

/// Projects state provider
final projectsNotifierProvider =
    StateNotifierProvider<ProjectsNotifier, AsyncValue<List<Project>>>((ref) {
  final projectService = ref.watch(projectServiceProvider);
  return ProjectsNotifier(projectService);
});
