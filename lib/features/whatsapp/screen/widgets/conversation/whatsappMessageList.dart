import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappErrorView.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageBubble.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageItem.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageMerger.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==================================================================
// LIST ITEM TYPES
// ==================================================================

abstract class _ListEntry {}

class _DateHeaderEntry extends _ListEntry {
  final String label;
  _DateHeaderEntry(this.label);
}

class _UnreadDividerEntry extends _ListEntry {
  final int count;
  _UnreadDividerEntry(this.count);
}

class _MessageEntry extends _ListEntry {
  final WhatsappMessageItem message;
  _MessageEntry(this.message);
}

class WhatsappMessageList extends StatelessWidget {
  final WhatsappConversationDetailController controller;
  final WhatsappConversationModel chatdetail;

  // Unread divider sirf pehli build par dikhega.
  bool _hasShownUnreadDivider = false;

  WhatsappMessageList({
    super.key,
    required this.controller,
    required this.chatdetail,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final whatsappController = controller.whatsappController;

      // ------------------------------------------------------------
      // SELECTION STATE (Obx ke andar read karna zaroori hai)
      // ------------------------------------------------------------
      final bool selectionMode = whatsappController.isSelectionMode;
      final Set<String> selectedIds = whatsappController.selectedMessageIds
          .toSet();

      // ------------------------------------------------------------
      // LOADING
      // ------------------------------------------------------------
      if (whatsappController.isMessagesLoading.value) {
        // Gol loader nahi: chat jaise bubbles ka shimmer
        return const WaChatShimmer();
      }

      // ------------------------------------------------------------
      // ERROR
      // ------------------------------------------------------------
      final error = whatsappController.messagesErrorMessage.value;

      if (error.isNotEmpty) {
        return WhatsappErrorView(
          message: error,
          onRetry: () {
            whatsappController.getConversationMessages(
              conversationId: controller.conversationId,
            );
          },
        );
      }

      // ------------------------------------------------------------
      // MESSAGES (newest first)
      // ------------------------------------------------------------
      final messages = WhatsappMessageMerger.merge(
        apiMessages:
            whatsappController.messagesResponse.value?.result?.messages ?? [],
        socketMessages: whatsappController.socketMessages
            .where(
              (message) => message.conversationId == controller.conversationId,
            )
            .toList(),
      );

      // ------------------------------------------------------------
      // EMPTY
      // ------------------------------------------------------------
      if (messages.isEmpty) {
        return const _EmptyChat();
      }

      // ------------------------------------------------------------
      // BUILD DISPLAY LIST
      // ------------------------------------------------------------
      final unread = controller.totalUnreadCount;
      final showDivider = !_hasShownUnreadDivider;

      final displayItems = _buildDisplayItems(
        messagesNewestFirst: messages,
        unreadCount: unread,
        showDivider: showDivider,
      );

      _hasShownUnreadDivider = true;

      // ------------------------------------------------------------
      // LIST
      // ------------------------------------------------------------
      return PopScope(
        // Selection mode me back dabane par pehle selection clear hoga.
        canPop: !selectionMode,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            whatsappController.clearSelection();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            controller: controller.scrollController,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              return _buildEntryWidget(
                context,
                displayItems[index],
                selectionMode: selectionMode,
                selectedIds: selectedIds,
              );
            },
          ),
        ),
      );
    });
  }

  // ==================================================================
  // BUILD SINGLE LIST ITEM WIDGET
  // ==================================================================

  Widget _buildEntryWidget(
    BuildContext context,
    _ListEntry entry, {
    required bool selectionMode,
    required Set<String> selectedIds,
  }) {
    if (entry is _DateHeaderEntry) {
      return _DateHeader(label: entry.label);
    }

    if (entry is _UnreadDividerEntry) {
      return _NewMessageDivider(
        count: chatdetail.unreadCount,
        onTap: () {
          controller.clearUnread();
          controller.scrollToBottom();
        },
      );
    }

    final message = (entry as _MessageEntry).message;

    // NOTE: API ko wamid... wali ID chahiye. Agar WhatsappMessageItem me
    // field ka naam alag hai (jaise id), to yahan wahi use karo.
    final String id = message.messageId ?? '';
    final bool isSelected = selectedIds.contains(id);
    final wc = controller.whatsappController;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: id.isEmpty ? null : () => wc.toggleMessageSelection(id),
      onTap: selectionMode && id.isNotEmpty
          ? () => wc.toggleMessageSelection(id)
          : null,
      child: Container(
        color: isSelected
            ? TAppColors.success.withOpacity(0.40)
            : Colors.transparent,
        // Selection mode me bubble ke andar ke taps (image, link etc.) band.
        child: IgnorePointer(
          ignoring: selectionMode,
          child: WhatsappMessageBubble(
            message: message,
            ndid: controller.chat.ndid,
          ),
        ),
      ),
    );
  }

  // ==================================================================
  // BUILD DISPLAY ITEMS
  // ==================================================================

  List<_ListEntry> _buildDisplayItems({
    required List<WhatsappMessageItem> messagesNewestFirst,
    required int unreadCount,
    required bool showDivider,
  }) {
    final chronological = messagesNewestFirst.reversed.toList();

    final int newCount = showDivider
        ? unreadCount.clamp(0, chronological.length)
        : 0;

    final int unreadStartIndex = chronological.length - newCount;

    final List<_ListEntry> items = [];

    String? lastDateLabel;

    for (int i = 0; i < chronological.length; i++) {
      final message = chronological[i];

      final dateLabel = _dateLabelFor(message.createdAt);

      if (dateLabel != lastDateLabel) {
        items.add(_DateHeaderEntry(dateLabel));
        lastDateLabel = dateLabel;
      }

      if (newCount > 0 && i == unreadStartIndex) {
        items.add(_UnreadDividerEntry(newCount));
      }

      items.add(_MessageEntry(message));
    }

    return items.reversed.toList();
  }

  // ==================================================================
  // DATE LABEL
  // ==================================================================

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _dateLabelFor(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(createdAt);

    if (date == null) {
      return '';
    }

    final local = date.toLocal();
    final today = DateTime.now();

    final messageDay = DateTime(local.year, local.month, local.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final yesterdayDay = todayDay.subtract(const Duration(days: 1));

    if (messageDay == todayDay) {
      return 'Today';
    }

    if (messageDay == yesterdayDay) {
      return 'Yesterday';
    }

    final monthName = _monthNames[local.month - 1];

    if (local.year == today.year) {
      return '${local.day} $monthName';
    }

    return '${local.day} $monthName ${local.year}';
  }
}

// ==================================================================
// DATE HEADER
// ==================================================================

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff182229) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0 : .06),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xff54656f),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// NEW / UNREAD MESSAGE DIVIDER
// ==================================================================

class _NewMessageDivider extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NewMessageDivider({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: WaPalette.green.withValues(alpha: .4),
              ),
            ),

            if (count > 0) ...[
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: WaPalette.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${count > 99 ? '99+' : count} unread message${count == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 10),

            Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: WaPalette.green.withValues(alpha: .4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY CHAT
// ==================================================================

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: p.isDark ? const Color(0xff182229) : const Color(0xFFFFF5C4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 16, color: p.subText),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'No messages yet. Say hello!',
                style: TextStyle(color: p.subText, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
