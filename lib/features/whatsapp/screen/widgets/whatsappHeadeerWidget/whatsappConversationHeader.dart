import 'package:eazotel/features/whatsapp/controller/whatsappController.dart'; // apna path
import 'package:eazotel/features/whatsapp/controller/whatsapp_lead_filter_controller.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_lead_filter_widget.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Confirm dialog + delete. Header aur message list dono use karte hain.
Future<void> confirmAndDeleteMessages(
  BuildContext context,
  WhatsappController controller,
  List<String> ids,
) async {
  if (ids.isEmpty) return;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete messages?'),
      content: Text(
        ids.length == 1
            ? 'Are you sure you want to delete conversations?'
            : 'Are you sure you want to delete ${ids.length} conversations?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final ok = await controller.deleteMessages(ids);

  if (!ok) {
    Get.snackbar('Error', 'Messages delete nahi ho paye. Dobara try karo.');
  }
}

class WhatsappConversationHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final WhatsappConversationModel chat;
  final WhatsappController whatsappController;

  const WhatsappConversationHeader({
    super.key,
    required this.chat,
    required this.whatsappController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (whatsappController.isSelectionMode) {
        return _buildSelectionBar(context);
      }
      return _buildNormalBar(context);
    });
  }

  // ------------------------------------------------------------
  // SELECTION BAR (close + count + delete)
  // ------------------------------------------------------------
  Widget _buildSelectionBar(BuildContext context) {
    final count = whatsappController.selectedMessageIds.length;
    final deleting = whatsappController.isDeleting.value;

    return AppBar(
      elevation: 0,
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: deleting ? null : whatsappController.clearSelection,
      ),
      title: Text('$count selected'),
      actions: [
        if (deleting)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: count == 0
                ? null
                : () => confirmAndDeleteMessages(
                    context,
                    whatsappController,
                    whatsappController.selectedMessageIds.toList(),
                  ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------
  // NORMAL BAR
  // ------------------------------------------------------------
  Widget _buildNormalBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Text(
              _firstLetter(chat.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name?.isNotEmpty == true
                      ? chat.name!
                      : chat.phone ?? 'WhatsApp',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  chat.phone ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
        IconButton(
          onPressed: () {
            showWhatsappFilterSheet(
              context: context,
              conversationId: chat.id, // tumhare model mein id pehle se hai
              hid: whatsappController.hid,
              ndid: chat.ndid, // neeche dekho
              contact: chat.phone,
              name: chat.name, // model mein jo name field hai wo
              status: chat.status,
              assignedTo: chat.assignedTo,
            );
          },
          icon: const Icon(Icons.more_vert),
        ),
        // PopupMenuButton<String>(
        //   onSelected: (_) {},
        //   itemBuilder: (context) => const [
        //     PopupMenuItem(value: 'contact', child: Text('Contact info')),
        //     PopupMenuItem(value: 'search', child: Text('Search')),
        //     PopupMenuItem(value: 'clear', child: Text('Clear chat')),
        //   ],
        // ),
      ],
    );
  }

  String _firstLetter(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '?';
    }
    return value.trim()[0].toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

void showWhatsappFilterSheet({
  required BuildContext context,
  required String conversationId,
  required String hid,
  required String ndid,
  required String contact,
  String? name,
  String? status,
  String? assignedTo,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final controller = WhatsappLeadFilterController(
    conversationId: conversationId,
    hid: hid,
    ndid: ndid,
    contact: contact,
    name: name,
    status: status,
  );

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202630) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF566171)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                WhatsappLeadFilterWidget(
                  controller: controller,
                  status: status,
                  assignedTo: assignedTo,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
