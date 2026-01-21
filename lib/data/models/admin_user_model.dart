/// Admin user model
class AdminUser {
  final String id;
  final String email;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  /// Create AdminUser from JSON
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert AdminUser to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
