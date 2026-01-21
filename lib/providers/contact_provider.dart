import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contact_service.dart';
import '../data/models/contact_message_model.dart';

/// Contact service provider
final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService();
});

/// All contact messages provider (Admin only)
final contactMessagesProvider = FutureProvider<List<ContactMessage>>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return await contactService.getAllMessages();
});

/// Unread messages count provider
final unreadMessagesCountProvider = FutureProvider<int>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return await contactService.getUnreadCount();
});

/// Contact messages state notifier
class ContactMessagesNotifier extends StateNotifier<AsyncValue<List<ContactMessage>>> {
  final ContactService _contactService;

  ContactMessagesNotifier(this._contactService) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  /// Load all messages
  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _contactService.getAllMessages();
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Submit a new message
  Future<void> submitMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _contactService.submitMessage(
        name: name,
        email: email,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _contactService.markAsRead(messageId);
      await loadMessages(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _contactService.deleteMessage(messageId);
      await loadMessages(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all messages
  Future<void> deleteAllMessages() async {
    try {
      await _contactService.deleteAllMessages();
      await loadMessages(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }
}

/// Contact messages state provider
final contactMessagesNotifierProvider =
    StateNotifierProvider<ContactMessagesNotifier, AsyncValue<List<ContactMessage>>>((ref) {
  final contactService = ref.watch(contactServiceProvider);
  return ContactMessagesNotifier(contactService);
});
