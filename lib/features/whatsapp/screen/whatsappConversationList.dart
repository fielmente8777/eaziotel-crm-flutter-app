import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/controller/whatsappController.dart';
import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/features/whatsapp/screen/whatsappConversationMesseg.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      // ============================================================
      // API RESPONSE ABHI NAHI AAYA
      // ============================================================

      if (controller.isIntegrationLoading.value ||
          controller.whatsappIntegration.value == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // ============================================================
      // API RESPONSE AA GAYA
      // ============================================================

      final bool integ = controller.whatsappIntegrationSuccess;

      // ============================================================
      // SUCCESS FALSE
      // CUSTOM SCREEN
      // ============================================================

      if (!integ) {
        return Text('heloeojdfkjafkjakfjlkajflkajlk');
      }

      // ============================================================
      // SUCCESS TRUE
      // EXISTING WHATSAPP SCREEN
      // ============================================================

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('WhatsApp'),
        ),

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
            debugPrint('FAB clicked');
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
      );
    });
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
      // ==========================================================
      // LOADING
      // ==========================================================

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // ==========================================================
      // ERROR
      // ==========================================================

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('faild to relode', style: theme.textTheme.titleMedium),

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

      // ==========================================================
      // FILTERED CHATS
      // ==========================================================

      final chats = controller.filteredChats.toList();

      // ==========================================================
      // SOCKET SORT
      // ==========================================================

      chats.sort((a, b) {
        final socketA = controller.latestSocketMessagesByConversation[a.id];

        final socketB = controller.latestSocketMessagesByConversation[b.id];

        if (socketA == null && socketB == null) {
          return 0;
        }

        if (socketA == null) {
          return 1;
        }

        if (socketB == null) {
          return -1;
        }

        final dateA =
            DateTime.tryParse(socketA.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final dateB =
            DateTime.tryParse(socketB.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dateB.compareTo(dateA);
      });

      // ==========================================================
      // EMPTY
      // ==========================================================

      if (chats.isEmpty) {
        return Center(
          child: Text(
            controller.selectedTab.value == 0
                ? 'No active conversations'
                : 'No inactive conversations',
            style: theme.textTheme.bodyMedium,
          ),
        );
      }

      // ==========================================================
      // LIST
      // ==========================================================

      return ListView.builder(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),

        itemCount: chats.length,

        itemBuilder: (context, index) {
          final WhatsappConversationModel chat = chats[index];

          // ======================================================
          // NAME
          // ======================================================

          final String name = chat.name?.trim().isNotEmpty == true
              ? chat.name!
              : chat.phone;

          // ======================================================
          // FIRST LETTER
          // ======================================================

          final String firstLetter = name.isNotEmpty
              ? name[0].toUpperCase()
              : '+';

          // ======================================================
          // SOCKET MESSAGE
          // ======================================================

          final socketMessage =
              controller.latestSocketMessagesByConversation[chat.id];

          // ======================================================
          // MESSAGE
          // ======================================================

          String message;

          if (socketMessage != null &&
              socketMessage.body?.trim().isNotEmpty == true) {
            message = socketMessage.body!;
          } else if (chat.lastMessage?.text?.trim().isNotEmpty == true) {
            message = chat.lastMessage!.text!;
          } else {
            message = 'No message';
          }

          // ======================================================
          // TIME
          // ======================================================

          String time = '';

          if (socketMessage != null && socketMessage.createdAt != null) {
            final socketDate = DateTime.tryParse(socketMessage.createdAt!);

            if (socketDate != null) {
              time = TimeOfDay.fromDateTime(
                socketDate.toLocal(),
              ).format(context);
            }
          } else {
            final createdDate = DateTime.tryParse(chat.createdAt);

            if (createdDate != null) {
              time = TimeOfDay.fromDateTime(
                createdDate.toLocal(),
              ).format(context);
            }
          }

          // ======================================================
          // UNREAD
          // ======================================================

          final int unreadCount =
              socketMessage?.unreadCount ?? chat.unreadCount;

          // ======================================================
          // ITEM
          // ======================================================

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),

            child: InkWell(
              onTap: () {
                controller.getConversationMessages(conversationId: chat.id);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WhatsappConversationMesseg(chat: chat),
                  ),
                );
              },

              borderRadius: BorderRadius.circular(10),

              child: Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: theme.cardTheme.color,

                  borderRadius: BorderRadius.circular(10),

                  border: Border.all(
                    color: theme.dividerTheme.color ?? TAppColors.lightBorder,
                  ),
                ),

                child: Row(
                  children: [
                    // ==================================================
                    // PROFILE
                    // ==================================================
                    Container(
                      width: 56,
                      height: 56,

                      alignment: Alignment.center,

                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Icon(Icons.person),
                    ),

                    const SizedBox(width: 12),

                    // ==================================================
                    // DETAILS
                    // ==================================================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ==================================================
                          // NAME / TIME / UNREAD
                          // ==================================================
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

                          // ==================================================
                          // PHONE
                          // ==================================================
                          Text(
                            chat.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),

                          const SizedBox(height: 5),

                          // ==================================================
                          // MESSAGE
                          // ==================================================
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

                          // ==================================================
                          // STATUS
                          // ==================================================
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
        final selectedTab = controller.selectedTab.value;

        final int active = controller.activeCount;

        final int inactive = controller.inactiveCount;

        final int convertedCount = controller.convertedCount;

        return Row(
          children: [
            // ======================================================
            // ACTIVE
            // ======================================================
            Expanded(
              child: _TabButton(
                title: 'Active',
                count: active,
                selected: selectedTab == 0,
                theme: theme,

                onTap: () {
                  controller.changeTab(0);
                },
              ),
            ),

            const SizedBox(width: 10),

            // ======================================================
            // INACTIVE
            // ======================================================
            Expanded(
              child: _TabButton(
                title: 'Inactive',
                count: inactive,
                selected: selectedTab == 1,
                theme: theme,

                onTap: () {
                  controller.changeTab(1);
                },
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: _TabButton(
                title: 'converted',
                count: convertedCount,
                selected: selectedTab == 2,
                theme: theme,

                onTap: () {
                  controller.changeTab(2);
                },
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
            Text(
              title,

              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,

                fontWeight: FontWeight.w600,
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
