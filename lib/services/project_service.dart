import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/project_model.dart';
import 'supabase_service.dart';

/// Service for managing projects in Supabase
class ProjectService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Get all projects ordered by creation date (newest first)
  Future<List<Project>> getAllProjects() async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Project.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Get a single project by ID
  Future<Project?> getProjectById(String id) async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Project.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch project: $e');
    }
  }

  /// Create a new project
  Future<Project> createProject({
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
      final response = await _client
          .from('projects')
          .insert({
            'title': title,
            'description': description,
            'tech_stack': techStack,
            'image_url': imageUrl,
            'github_url': githubUrl,
            'play_store_url': playStoreUrl,
            'key_features': keyFeatures ?? [],
            'screenshots': screenshots ?? [],
          })
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Update an existing project
  Future<Project> updateProject({
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
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (techStack != null) updateData['tech_stack'] = techStack;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (githubUrl != null) updateData['github_url'] = githubUrl;
      if (playStoreUrl != null) updateData['play_store_url'] = playStoreUrl;
      if (keyFeatures != null) updateData['key_features'] = keyFeatures;
      if (screenshots != null) updateData['screenshots'] = screenshots;

      final response = await _client
          .from('projects')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Project.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    try {
      await _client.from('projects').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Upload project image to Supabase Storage
  Future<String> uploadProjectImage(String filePath, List<int> fileBytes) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      
      await _client.storage
          .from('project-images')
          .uploadBinary(fileName, Uint8List.fromList(fileBytes));

      final imageUrl = _client.storage
          .from('project-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
