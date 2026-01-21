/// Contact message model
class ContactMessage {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  /// Create ContactMessage from JSON
  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  /// Convert ContactMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  /// Create a copy with modified fields
  ContactMessage copyWith({
    String? id,
    String? name,
    String? email,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ContactMessage(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
