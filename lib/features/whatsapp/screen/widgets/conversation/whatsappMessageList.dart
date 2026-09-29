import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappErrorView.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageBubble.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageItem.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageMerger.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==================================================================
// LIST ITEM TYPES
// ==================================================================
//
// Poori message list ab ek hi flat list hai jisme teen tarah ke
// items ho sakte hain: date header, unread divider, aur actual
// message. Koi Sliver/CustomScrollView nahi — simple ListView.

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

  // Ye flag track karta hai ki unread-divider ek baar dikh chuka hai
  // ya nahi. Screen ke pehle build (mount) pe false hota hai, isliye
  // divider dikhta hai; uske baad har Obx rebuild pe true ho jaata
  // hai, isliye dobara kabhi nahi dikhta — chahe Obx kitni bhi baar
  // rebuild ho. (const constructor hata di gayi hai kyunki ab field
  // mutable hai.)
  bool _hasShownUnreadDivider = false;

  WhatsappMessageList({
    super.key,
    required this.controller,
    required this.chatdetail,
  });

  @override
  Widget build(BuildContext context) {
    print(
      'print: kdkjkjsfkjskfjskjfksjkfjskljfkjakfjlkajflkjakfjlkajflkajlkfjalkjfkaj',
    );
    print(
      'kdkjkjsfkjskfjskjfksjkjjhkfjskljfkjakfjlkajflkjakfjlkajflkajlkfjalkjfkaj',
    );
    return Obx(() {
      print('print: WhatsappMessageList BUILD');

      final whatsappController = controller.whatsappController;

      // ------------------------------------------------------------
      // LOADING
      // ------------------------------------------------------------
      if (whatsappController.isMessagesLoading.value) {
        return const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
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
      // MESSAGES (newest first, jaisa merger deta hai)
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
        return const Center(
          child: Text('No messages', style: TextStyle(fontSize: 13)),
        );
      }

      // ------------------------------------------------------------
      // BUILD DISPLAY LIST (date headers + unread divider + messages)
      // ------------------------------------------------------------

      final unread = controller.totalUnreadCount;

      // Sirf pehli baar (screen mount, jab _hasShownUnreadDivider
      // false hai) hi divider entry dikhayenge. Uske baad, chahe
      // Obx kitni bhi baar rebuild ho, showDivider hamesha false
      // rahega.
      final showDivider = !_hasShownUnreadDivider;

      final displayItems = _buildDisplayItems(
        messagesNewestFirst: messages,
        unreadCount: unread,
        showDivider: showDivider,
      );

      // Is build ke baad flag lock kar do — ab kabhi dobara divider
      // is widget-instance ke liye nahi banega.
      _hasShownUnreadDivider = true;

      // ------------------------------------------------------------
      // LIST
      // ------------------------------------------------------------
      //
      // reverse:true -> index 0 sabse neeche (newest) render hota hai.
      // displayItems already newest-first order mein hai (jaisa
      // messages the), isliye direct render kar sakte hain.
      //
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          controller: controller.scrollController,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            // Ye ab sirf ek call hai — actual entry-type check aur
            // widget banane ka logic _buildEntryWidget() me hai,
            // jo is Obx(() {...}) closure ke BAHAR define hai.
            return _buildEntryWidget(displayItems[index]);
          },
        ),
      );
    });
  }

  // ==================================================================
  // BUILD SINGLE LIST ITEM WIDGET
  // ==================================================================
  //
  // Ye method Obx() ke closure ke bahar (class level pe) defined hai.
  // itemBuilder sirf ise call karta hai — entry-type check aur
  // _NewMessageDivider banane wala part yahan, Obx ke bahar, rehta hai.

  Widget _buildEntryWidget(_ListEntry entry) {
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

    return WhatsappMessageBubble(message: message, ndid: controller.chat.ndid);
  }

  // ==================================================================
  // BUILD DISPLAY ITEMS
  // ==================================================================
  //
  // messagesNewestFirst: index 0 = sabse naya message.
  //
  // Chronological (oldest -> newest) order mein process karte hain
  // taaki date change aur unread boundary sahi se detect ho, phir
  // result ko wapas newest-first mein reverse kar dete hain taaki
  // reverse:true ListView mein sahi jagah render ho.

  List<_ListEntry> _buildDisplayItems({
    required List<WhatsappMessageItem> messagesNewestFirst,
    required int unreadCount,
    required bool showDivider,
  }) {
    final chronological = messagesNewestFirst.reversed.toList();

    // Agar showDivider false hai (matlab ye pehla build nahi hai),
    // to newCount 0 maan lo taaki divider entry kabhi add na ho.
    final int newCount = showDivider
        ? unreadCount.clamp(0, chronological.length)
        : 0;

    // Chronological order mein wahi index jahan se NEW/unread
    // messages shuru hote hain.
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

    // Wapas newest-first order mein (reverse:true ListView ke liye)
    return items.reversed.toList();
  }

  // ==================================================================
  // DATE LABEL (Today / Yesterday / 12 September / 12 September 2025)
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
// DATE HEADER (Today / Yesterday / date pill)
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
            color: isDark ? const Color(0xff182229) : const Color(0xffe1f2fb),
            borderRadius: BorderRadius.circular(8),
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
//
// ✅ Ab yahan text ("X unread messages") ki jagah sirf list screen
// jaisa hi round badge dikhta hai (number ke saath), same style:
// Container + padding(7,3) + borderRadius(20) + primary color.

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
                color: Colors.grey.shade400,
              ),
            ),

            if (count > 0) ...[
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),

                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  count > 99 ? '99+' : '$count  unread Message',

                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 10),

            Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
