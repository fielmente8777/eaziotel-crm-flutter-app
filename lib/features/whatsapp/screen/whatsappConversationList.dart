import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/addcontect/addContect.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/whatsapp_ui.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ================================================================
// CONFIRM + DELETE CONVERSATIONS
// ================================================================

Future<void> confirmAndDeleteConversations(
  BuildContext context,
  WhatsappController controller,
) async {
  final int count = controller.selectedConversationIds.length;
  if (count == 0) return;

  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete conversations?'),
      content: Text(
        count == 1
            ? 'Are you sure you want to delete conversations?.'
            : 'Are you sure you want to delete $count conversations?.',
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

  final bool ok = await controller.deleteSelectedConversations();

  if (!ok) {
    Get.snackbar(
      'Error',
      'Conversations delete nahi ho payi. Dobara try karo.',
    );
  }
}

// ================================================================
// WHATSAPP SCREEN
// ================================================================

class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key});

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> {
  late final WhatsappController controller;

  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<WhatsappController>()) {
      Get.put<WhatsappController>(
        WhatsappController(hid: dashboardController.selectedHotelId.string),
      );
    }

    controller = Get.find<WhatsappController>();
  }

  // NOTE: dispose me WhatsappController ab delete nahi hota.
  // Wo app khulte hi ban jaata hai (NotificationController) taaki socket
  // hamesha jude rahe aur dusre tab par bhi naye message ki notification aaye.
  // Hotel badalne / logout par wahi use band karta hai.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = WaPalette(context);

    return Obx(() {
      // ------------------------------------------------------------
      // INTEGRATION LOADING (gol loader nahi, shimmer)
      // ------------------------------------------------------------
      if (controller.isIntegrationLoading.value ||
          controller.whatsappIntegration.value == null) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: const SafeArea(child: WaConversationShimmer(withHeader: true)),
        );
      }

      // ------------------------------------------------------------
      // NOT CONNECTED
      // ------------------------------------------------------------
      if (!controller.whatsappIntegrationSuccess) {
        return const Scaffold(body: _ConnectWhatsappCard());
      }

      // ------------------------------------------------------------
      // CONNECTED
      // ------------------------------------------------------------
      final bool selectionMode = controller.isConversationSelectMode.value;
      final bool deleting = controller.isDeletingConversations.value;
      final int selectedCount = controller.selectedConversationIds.length;

      return PopScope(
        // Selection mode me back dabane par pehle selection clear hoga
        canPop: !selectionMode,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) controller.clearConversationSelection();
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          // ==================== APP BAR ====================
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: selectionMode
                ? p.tint(WaPalette.green)
                : theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: selectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: deleting
                        ? null
                        : controller.clearConversationSelection,
                  )
                : null,
            titleSpacing: selectionMode ? 0 : 16,
            title: selectionMode
                ? Text(
                    '$selectedCount selected',
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: p.tint(WaPalette.green),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.chat_rounded,
                          color: p.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: p.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3,
                              ),
                            ),
                            Text(
                              '${controller.conversations.length} conversations',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: p.subText, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            actions: [
              if (deleting)
                // Delete ho raha hai: chhota hourglass (gol loader nahi)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 20,
                    color: p.accent,
                  ),
                )
              else if (selectionMode) ...[
                IconButton(
                  tooltip: 'Select all',
                  icon: const Icon(Icons.select_all_outlined),
                  onPressed: controller.selectAllConversations,
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: selectedCount == 0
                      ? null
                      : () =>
                            confirmAndDeleteConversations(context, controller),
                ),
              ] else if (deleting)
                IconButton(
                  tooltip: 'Delete chats',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: controller.startConversationSelection,
                ),
            ],
          ),

          // ==================== BODY ====================
          body: Column(
            children: [
              Search(controller: controller),
              const SizedBox(height: 4),
              ActionTab(controller: controller, theme: theme),
              const SizedBox(height: 12),
              Expanded(
                child: ConversationList(controller: controller, theme: theme),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            tooltip: 'New chat',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return const AddContect();
                },
              );
            },
            backgroundColor: WaPalette.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add_comment_rounded),
          ),
        ),
      );
    });
  }
}

// ================================================================
// CONNECT WHATSAPP CARD (integration nahi hai)
// ================================================================

class _ConnectWhatsappCard extends StatelessWidget {
  const _ConnectWhatsappCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF17251F)
        : const Color(0xFFE8F7EF);
    final Color borderColor = isDark
        ? const Color(0xFF28553F)
        : const Color(0xFFB7E4C7);
    final Color iconBackgroundColor = isDark
        ? const Color(0xFF203F30)
        : const Color(0xFFD2F1DF);
    final Color titleColor = isDark
        ? const Color(0xFFE8F5EE)
        : const Color(0xFF163A2A);
    final Color subTextColor = isDark
        ? const Color(0xFFA9C5B6)
        : const Color(0xFF527064);

    // Phone par 82% chaudai, tablet / desktop par 420 se bada nahi
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    size: 36,
                    color: WaPalette.green,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Connect WhatsApp',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Connect with our team to connect '
                  'your WhatsApp account and start '
                  'managing conversations.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CONVERSATION LIST
// ================================================================

class ConversationList extends StatelessWidget {
  const ConversationList({
    super.key,
    required this.controller,
    required this.theme,
  });

  final WhatsappController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ----------------------------------------------------------
      // LOADING
      // ----------------------------------------------------------

      if (controller.isLoading.value) {
        return const WaConversationShimmer();
      }

      // ----------------------------------------------------------
      // ERROR
      // ----------------------------------------------------------
      if (controller.errorMessage.value.isNotEmpty) {
        return _StateMessage(
          icon: Icons.cloud_off_rounded,
          color: TAppColors.error,
          title: 'Failed to reload',
          message: controller.errorMessage.value,
          action: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: WaPalette.green,
              foregroundColor: Colors.white,
            ),
            onPressed: controller.getConversations,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        );
      }

      // ----------------------------------------------------------
      // FILTERED + SOCKET SORTED CHATS
      // ----------------------------------------------------------
      final chats = controller.filteredChats.toList();

      chats.sort((a, b) {
        final socketA = controller.latestSocketMessagesByConversation[a.id];
        final socketB = controller.latestSocketMessagesByConversation[b.id];

        if (socketA == null && socketB == null) return 0;
        if (socketA == null) return 1;
        if (socketB == null) return -1;

        final dateA =
            DateTime.tryParse(socketA.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final dateB =
            DateTime.tryParse(socketB.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dateB.compareTo(dateA);
      });

      // ----------------------------------------------------------
      // EMPTY
      // ----------------------------------------------------------
      if (chats.isEmpty) {
        final int tab = controller.selectedTab.value;

        return _StateMessage(
          icon: Icons.forum_outlined,
          color: WaPalette.green,
          title: tab == 0
              ? 'No active conversations'
              : tab == 1
              ? 'No inactive conversations'
              : 'No converted conversations',
          message: controller.searchText.value.isNotEmpty
              ? 'Try a different name or number.'
              : 'New chats will show up here.',
        );
      }

      // ----------------------------------------------------------
      // SELECTION STATE (itemBuilder lazy hai, isliye yahan read)
      // ----------------------------------------------------------
      final bool selectionMode = controller.isConversationSelectMode.value;
      final Set<String> selectedIds = controller.selectedConversationIds
          .toSet();

      // ----------------------------------------------------------
      // LIST
      // ----------------------------------------------------------
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final WhatsappConversationModel chat = chats[index];

          final bool isSelected = selectedIds.contains(chat.id);

          // NAME
          final String name = chat.name?.trim().isNotEmpty == true
              ? chat.name!
              : chat.phone;

          // SOCKET MESSAGE
          final socketMessage =
              controller.latestSocketMessagesByConversation[chat.id];

          // MESSAGE
          String message;

          if (socketMessage != null &&
              socketMessage.body?.trim().isNotEmpty == true) {
            message = socketMessage.body!;
          } else if (chat.lastMessage?.text?.trim().isNotEmpty == true) {
            message = chat.lastMessage!.text!;
          } else {
            message = 'No message';
          }

          // TIME
          String time = '';

          final createdAt =
              socketMessage?.updatedAt ?? chat.lastMessage?.updatedAt;
          final createdDate = DateTime.tryParse(createdAt.toString());

          if (createdDate != null) {
            final localDate = createdDate.toLocal();
            final difference = DateTime.now().difference(localDate);

            if (difference.inHours >= 24) {
              time =
                  '${localDate.day.toString().padLeft(2, '0')}/'
                  '${localDate.month.toString().padLeft(2, '0')}/'
                  '${localDate.year}';
            } else {
              time = TimeOfDay.fromDateTime(localDate).format(context);
            }
          }

          // UNREAD
          final int unreadCount =
              socketMessage?.unreadCount ?? chat.unreadCount;

          return _ChatTile(
            name: name,
            phone: chat.phone,
            message: message,
            time: time,
            status: chat.status,
            unreadCount: unreadCount,
            isLive: socketMessage != null,
            isSelected: isSelected,
            onLongPress: () => controller.toggleConversationSelection(chat.id),
            onTap: () {
              // Selection mode me tap = select / unselect
              if (selectionMode) {
                controller.toggleConversationSelection(chat.id);
                return;
              }

              controller.getConversationMessages(conversationId: chat.id);
              controller.markConversationAsReadLocally(chat.id);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WhatsappConversationMesseg(
                    chat: chat,
                    whatsapptemplate: controller.templateController,
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}

// ================================================================
// ACTION TAB
// ================================================================

class ActionTab extends StatelessWidget {
  const ActionTab({super.key, required this.controller, required this.theme});

  final WhatsappController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final int selectedTab = controller.selectedTab.value;

        return Row(
          children: [
            Expanded(
              child: _TabButton(
                title: 'Active',
                count: controller.activeCount,
                selected: selectedTab == 0,
                theme: theme,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TabButton(
                title: 'Inactive',
                count: controller.inactiveCount,
                selected: selectedTab == 1,
                theme: theme,
                onTap: () => controller.changeTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TabButton(
                title: 'Converted',
                count: controller.convertedCount,
                selected: selectedTab == 2,
                theme: theme,
                onTap: () => controller.changeTab(2),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ================================================================
// TAB BUTTON
// ================================================================

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.count,
    required this.selected,
    required this.theme,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool selected;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? WaPalette.green : p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? WaPalette.green : p.border),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: WaPalette.green.withValues(alpha: .3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : p.text,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .25)
                      : p.tint(WaPalette.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : p.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SEARCH
// ================================================================

class Search extends StatelessWidget {
  const Search({super.key, required this.controller});

  final WhatsappController controller;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: TextField(
        onChanged: controller.search,
        style: TextStyle(color: p.text, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search name or number...',
          hintStyle: TextStyle(color: p.subText, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: p.subText),
          filled: true,
          fillColor: p.card,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: border(p.border),
          enabledBorder: border(p.border),
          focusedBorder: border(WaPalette.green, 1.5),
        ),
      ),
    );
  }
}

// ================================================================
// CHAT TILE (ek conversation ka card)
//
//   (R)  Rahul Sharma                       10:42 AM
//        +91 98765 43210
//        Hello, room available hai?            (3)
//        [● Active]
// ================================================================

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.name,
    required this.phone,
    required this.message,
    required this.time,
    required this.status,
    required this.unreadCount,
    required this.isLive,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final String name;
  final String phone;
  final String message;
  final String time;
  final String status;
  final int unreadCount;
  final bool isLive;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);
    final unread = unreadCount > 0;
    final statusColor = WaStatus.color(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected ? p.tint(WaPalette.green) : p.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: onLongPress,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? WaPalette.green
                    : unread
                    ? WaPalette.green.withValues(alpha: .45)
                    : p.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= AVATAR (+ tick jab select ho) =================
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    WaAvatar(name: name),
                    if (isSelected || isLive)
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: isSelected ? 20 : 13,
                          height: isSelected ? 20 : 13,
                          decoration: BoxDecoration(
                            color: WaPalette.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.card, width: 2),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // ================= DETAILS =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME / TIME
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              time,
                              style: TextStyle(
                                color: unread ? p.accent : p.subText,
                                fontSize: 11.5,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // PHONE (naam alag ho tab hi)
                      if (phone.isNotEmpty && phone != name) ...[
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.subText, fontSize: 12),
                        ),
                      ],

                      const SizedBox(height: 6),

                      // MESSAGE / UNREAD
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: unread ? p.text : p.subText,
                                fontSize: 13.5,
                                fontWeight: unread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              constraints: const BoxConstraints(minWidth: 22),
                              height: 22,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: WaPalette.green,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // STATUS
                      if (status.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: p.tint(statusColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.onTint(statusColor),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STATE MESSAGE (khali list / error)
// ================================================================

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = WaPalette(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: p.tint(color),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: p.onTint(color)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 13, height: 1.4),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
