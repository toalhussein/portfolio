import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/contact_message_model.dart';
import 'supabase_service.dart';

/// Service for managing contact messages in Supabase
class ContactService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Submit a new contact message
  Future<ContactMessage> submitMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final response = await _client
          .from('contact_messages')
          .insert({
            'name': name,
            'email': email,
            'message': message,
          })
          .select()
          .single();

      return ContactMessage.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit message: $e');
    }
  }

  /// Get all contact messages (Admin only)
  Future<List<ContactMessage>> getAllMessages() async {
    try {
      final response = await _client
          .from('contact_messages')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ContactMessage.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  /// Mark message as read (Admin only)
  Future<void> markAsRead(String messageId) async {
    try {
      await _client
          .from('contact_messages')
          .update({'is_read': true})
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// Delete a message (Admin only)
  Future<void> deleteMessage(String messageId) async {
    try {
      await _client
          .from('contact_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Delete all messages (Admin only)
  Future<void> deleteAllMessages() async {
    try {
      await _client
          .from('contact_messages')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all rows
    } catch (e) {
      throw Exception('Failed to delete all messages: $e');
    }
  }

  /// Get unread messages count (Admin only)
  Future<int> getUnreadCount() async {
    try {
      final response = await _client
          .from('contact_messages')
          .select()
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}
