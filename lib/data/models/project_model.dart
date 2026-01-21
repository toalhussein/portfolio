/// Project model representing a portfolio project
class Project {
  final String id;
  final String title;
  final String description;
  final String techStack;
  final String? imageUrl;
  final String? githubUrl;
  final String? playStoreUrl;
  final List<String> keyFeatures;
  final List<String> screenshots;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.techStack,
    this.imageUrl,
    this.githubUrl,
    this.playStoreUrl,
    this.keyFeatures = const [],
    this.screenshots = const [],
    required this.createdAt,
  });

  /// Create Project from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      techStack: json['tech_stack'] as String,
      imageUrl: json['image_url'] as String?,
      githubUrl: json['github_url'] as String?,
      playStoreUrl: json['play_store_url'] as String?,
      keyFeatures: json['key_features'] != null
          ? List<String>.from(json['key_features'] as List)
          : [],
      screenshots: json['screenshots'] != null
          ? List<String>.from(json['screenshots'] as List)
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Project to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tech_stack': techStack,
      'image_url': imageUrl,
      'github_url': githubUrl,
      'play_store_url': playStoreUrl,
      'key_features': keyFeatures,
      'screenshots': screenshots,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of Project with modified fields
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? techStack,
    String? imageUrl,
    String? githubUrl,
    String? playStoreUrl,
    List<String>? keyFeatures,
    List<String>? screenshots,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      imageUrl: imageUrl ?? this.imageUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      keyFeatures: keyFeatures ?? this.keyFeatures,
      screenshots: screenshots ?? this.screenshots,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
