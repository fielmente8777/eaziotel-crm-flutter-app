import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappErrorView.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageBubble.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageMerger.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappMessageList extends StatefulWidget {
  final WhatsappConversationDetailController controller;

  const WhatsappMessageList({super.key, required this.controller});

  @override
  State<WhatsappMessageList> createState() => _WhatsappMessageListState();
}

class _WhatsappMessageListState extends State<WhatsappMessageList> {
  final GlobalKey _dividerKey = GlobalKey();

  WhatsappConversationDetailController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
      // MESSAGES
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

      final unread = controller.totalUnreadCount;

      // ============================================================
      // NO UNREAD
      // ============================================================
      if (unread <= 0) {
        return ListView.builder(
          controller: controller.scrollController,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return WhatsappMessageBubble(
              message: messages[index],
              ndid: controller.chat.ndid,
            );
          },
        );
      }

      // ============================================================
      // SPLIT NEW / OLD
      // ============================================================

      final newCount = unread.clamp(0, messages.length);

      /*
       * messages:
       *
       * 0 = newest
       * 1
       * 2
       * 3
       * ...
       *
       * First `unread` messages are NEW.
       */

      final newMessages = messages.take(newCount).toList().reversed.toList();

      final oldMessages = messages.skip(newCount).toList();

      // ============================================================
      // CENTERED NEW MESSAGE VIEW
      // ============================================================
      //
      // IMPORTANT:
      // NO reverse:true here.
      //
      // The divider itself is the center anchor.
      //
      return CustomScrollView(
        controller: controller.scrollController,

        center: _dividerKey,

        slivers: [
          // ========================================================
          // OLD MESSAGES
          // ========================================================
          //
          // These are displayed ABOVE the divider.
          //
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final message = oldMessages[index];

              return WhatsappMessageBubble(
                message: message,
                ndid: controller.chat.ndid,
              );
            }, childCount: oldMessages.length),
          ),

          // ========================================================
          // CENTER DIVIDER
          // ========================================================
          //
          // Flutter places this anchor in the CENTER
          // when the screen first opens.
          //
          SliverToBoxAdapter(
            key: _dividerKey,
            child: _NewMessageDivider(
              count: unread,
              onTap: () {
                controller.clearUnread();
                controller.scrollToBottom();
              },
            ),
          ),

          // ========================================================
          // NEW MESSAGES
          // ========================================================
          //
          // Divider ke neeche:
          //
          // oldest new
          // newer
          // newest
          //
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final message = newMessages[index];

              return WhatsappMessageBubble(
                message: message,
                ndid: controller.chat.ndid,
              );
            }, childCount: newMessages.length),
          ),
        ],
      );
    });
  }
}

// ==================================================================
// NEW MESSAGE DIVIDER
// ==================================================================

class _NewMessageDivider extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NewMessageDivider({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
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

            const SizedBox(width: 10),

            Text(
              '$count new message${count == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TAppColors.primary,
              ),
            ),

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
