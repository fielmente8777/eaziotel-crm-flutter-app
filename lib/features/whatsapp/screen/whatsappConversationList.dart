import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationMesseg.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/addcontect/addContect.dart';
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

  @override
  void dispose() {
    if (Get.isRegistered<WhatsappController>()) {
      Get.delete<WhatsappController>();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      // ------------------------------------------------------------
      // INTEGRATION LOADING
      // ------------------------------------------------------------
      if (controller.isIntegrationLoading.value ||
          controller.whatsappIntegration.value == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            leading: selectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: deleting
                        ? null
                        : controller.clearConversationSelection,
                  )
                : null,
            title: Text(selectionMode ? '$selectedCount selected' : 'WhatsApp'),
            actions: [
              if (deleting)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            child: const Icon(Icons.add),
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

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: AspectRatio(
          aspectRatio: 1.15,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.20 : 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 35,
                  width: 55,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    size: 36,
                    color: TAppColors.success,
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
      final theme = Theme.of(context);

      // ----------------------------------------------------------
      // LOADING
      // ----------------------------------------------------------
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // ----------------------------------------------------------
      // ERROR
      // ----------------------------------------------------------
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to reload', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.getConversations,
                  child: const Text('Retry'),
                ),
              ],
            ),
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

        return Center(
          child: Text(
            tab == 0
                ? 'No active conversations'
                : tab == 1
                ? 'No inactive conversations'
                : 'No converted conversations',
            style: theme.textTheme.bodyMedium,
          ),
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onLongPress: () =>
                  controller.toggleConversationSelection(chat.id),
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
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TAppColors.success.withOpacity(0.20)
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? TAppColors.success
                        : theme.dividerTheme.color ?? TAppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    // ================= CHECKBOX =================
                    // if (selectionMode) ...[
                    //   Checkbox(
                    //     value: isSelected,
                    //     activeColor: TAppColors.success,
                    //     checkColor: Colors.white,
                    //     visualDensity: VisualDensity.compact,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(4),
                    //     ),
                    //     onChanged: (_) =>
                    //         controller.toggleConversationSelection(chat.id),
                    //   ),
                    //   const SizedBox(width: 4),
                    // ],

                    // ================= PROFILE =================
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF1E3A5F) // Dark blue
                            : const Color(0xFFE8F0FE), // Light blue
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF246BFD),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ================= DETAILS =================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAME / TIME / UNREAD
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              if (time.isNotEmpty)
                                Text(time, style: theme.textTheme.bodySmall),

                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 3),

                          // PHONE
                          Text(
                            chat.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),

                          const SizedBox(height: 5),

                          // MESSAGE
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),

                              if (socketMessage != null)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // STATUS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              chat.status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.dividerTheme.color ?? TAppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.onPrimary.withOpacity(0.15)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: TextField(
        onChanged: controller.search,
        decoration: const InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
