import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/common_widgets.dart';
import '../../core/theme/app_theme.dart';

/// Admin tab for viewing contact messages
class AdminMessagesTab extends ConsumerStatefulWidget {
  const AdminMessagesTab({super.key});

  @override
  ConsumerState<AdminMessagesTab> createState() => _AdminMessagesTabState();
}

class _AdminMessagesTabState extends ConsumerState<AdminMessagesTab> {
  bool _sortNewestFirst = true; // Default: newest first
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    final messagesAsync = ref.watch(contactMessagesNotifierProvider);

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return EmptyState(
            message: l10n.noMessages,
            icon: Icons.message_outlined,
          );
        }

        // Filter messages based on search query
        final filteredMessages = messages.where((message) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return message.name.toLowerCase().contains(query) ||
                 message.email.toLowerCase().contains(query) ||
                 message.message.toLowerCase().contains(query);
        }).toList();

        // Sort messages based on selection
        final sortedMessages = List<dynamic>.from(filteredMessages);
        sortedMessages.sort((a, b) {
          if (_sortNewestFirst) {
            return b.createdAt.compareTo(a.createdAt); // Newest first
          } else {
            return a.createdAt.compareTo(b.createdAt); // Oldest first
          }
        });

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: isRTL ? 'بحث في الرسائل...' : 'Search messages...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Sort and Delete All controls
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  // Sort dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<bool>(
                          value: _sortNewestFirst,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                          dropdownColor: AppTheme.cardColor,
                          onChanged: (value) {
                            setState(() {
                              _sortNewestFirst = value ?? true;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: true,
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_downward, size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  Text(isRTL ? 'الأحدث أولاً' : 'Newest First'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_upward, size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  Text(isRTL ? 'الأقدم أولاً' : 'Oldest First'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Delete All button
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteAllConfirmation(context, ref),
                    icon: const Icon(Icons.delete_sweep, size: 20),
                    label: Text(isRTL ? 'حذف الكل' : 'Delete All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results count
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    isRTL 
                        ? 'تم العثور على ${sortedMessages.length} رسالة'
                        : 'Found ${sortedMessages.length} message${sortedMessages.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),

            // Messages list
            Expanded(
              child: sortedMessages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            isRTL ? 'لم يتم العثور على رسائل' : 'No messages found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: sortedMessages.length,
                      itemBuilder: (context, index) {
                        final message = sortedMessages[index];
                        return _MessageCard(message: message)
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideX(begin: -0.2, end: 0);
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => LoadingSpinner(message: l10n.loading),
      error: (error, stack) => ErrorDisplay(
        message: '${l10n.error}: $error',
        onRetry: () => ref.refresh(contactMessagesNotifierProvider),
      ),
    );
  }

  void _showDeleteAllConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'حذف جميع الرسائل' : 'Delete All Messages'),
        content: Text(isRTL 
            ? 'هل أنت متأكد من حذف جميع الرسائل؟ لا يمكن التراجع عن هذا الإجراء.'
            : 'Are you sure you want to delete all messages? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(contactMessagesNotifierProvider.notifier)
                    .deleteAllMessages();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isRTL ? 'تم حذف جميع الرسائل بنجاح!' : 'All messages deleted successfully!'),
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
            child: Text(isRTL ? 'حذف الكل' : 'Delete All'),
          ),
        ],
      ),
    );
  }
}

/// Contact message card
class _MessageCard extends ConsumerWidget {
  final dynamic message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return GlowCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showMessageDetails(context, ref, message),
        borderRadius: BorderRadius.circular(12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name, email, and actions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryBlue,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Read/Unread indicator
              if (!message.isRead)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: AppTheme.accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context, ref, message),
                tooltip: l10n.delete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Message content
          Text(
            message.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(message.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              
              // Mark as read button
              if (!message.isRead)
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(contactMessagesNotifierProvider.notifier)
                          .markAsRead(message.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${l10n.error}: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(Directionality.of(context) == TextDirection.RTL ? 'تعيين كمقروء' : 'Mark as Read'),
                ),
            ],
          ),
        ],
      ),
    )
    );
  }

  void _showMessageDetails(BuildContext context, WidgetRef ref, dynamic message) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm a');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with status and close button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isRTL ? 'تفاصيل الرسالة' : 'Message Details',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      if (!message.isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: AppTheme.accentBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Name
                  Text(
                    isRTL ? 'الاسم' : 'Name',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    message.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  Text(
                    isRTL ? 'البريد الإلكتروني' : 'Email',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    message.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  Text(
                    isRTL ? 'التاريخ' : 'Date',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    dateFormat.format(message.createdAt),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Text(
                    isRTL ? 'الرسالة' : 'Message',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                    ),
                    child: SelectableText(
                      message.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!message.isRead)
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(contactMessagesNotifierProvider.notifier)
                                  .markAsRead(message.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${l10n.error}: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(isRTL ? 'تعيين كمقروء' : 'Mark as Read'),
                        ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(context, ref, message);
                        },
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
          );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, dynamic message) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(isRTL
            ? 'هل أنت متأكد من حذف هذه الرسالة من ${message.name}؟'
            : 'Are you sure you want to delete this message from ${message.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(contactMessagesNotifierProvider.notifier)
                    .deleteMessage(message.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isRTL ? 'تم حذف الرسالة بنجاح!' : 'Message deleted successfully!'),
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
