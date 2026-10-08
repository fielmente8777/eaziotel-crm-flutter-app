import 'package:eazotel/features/whatsapp/services/whatsapp_chat_opener.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/calls_controller.dart';
import '../models/call_model.dart';
import 'widgets/call_card.dart';
import 'widgets/make_call_dialog.dart';

class CallsManagementScreen extends StatelessWidget {
  const CallsManagementScreen({super.key});

  // ============================================================
  // ACTIONS
  // ============================================================

  /// App ke andar wali WhatsApp conversation kholta hai.
  /// Is number se conversation na ho to Add Contact sheet (number bhara hua).
  Future<void> _openWhatsapp(
    BuildContext context,
    CallsController controller,
    CallModel call,
  ) async {
    if (controller.openingWhatsappId.value.isNotEmpty) return;

    controller.openingWhatsappId.value = call.id;

    try {
      await WhatsappChatOpener.open(
        context,
        phone: call.customerNumber,
        hid: controller.hotelId,
        onLoaded: () => controller.openingWhatsappId.value = '',
      );
    } finally {
      controller.openingWhatsappId.value = '';
    }
  }


  /// Dropdown se value badli. "Follow Up" par follow-up ki date bhi poochho.
  Future<void> _changeField(
    BuildContext context,
    CallsController controller,
    CallModel call,
    CallField field,
    String value,
  ) async {
    DateTime? followUpDate;

    if (field == CallField.stage && value == 'Follow Up') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      followUpDate = await showDatePicker(
        context: context,
        helpText: 'Follow up date',
        initialDate: today.add(const Duration(days: 1)),
        firstDate: today,
        lastDate: today.add(const Duration(days: 365)),
      );

      // Date nahi chuni -> stage mat badlo
      if (followUpDate == null) return;
    }

    await controller.updateField(
      call,
      field,
      value,
      followUpDate: followUpDate,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls Management'),
        actions: [
          Obx(() {
            if (controller.total.value == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${controller.total.value} calls',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _CallsShimmerList();
          }

          final error = controller.errorMessage.value;
          final calls = controller.calls;

          if (calls.isEmpty) {
            return _Message(
              icon: error != null ? Icons.error_outline : Icons.call_outlined,
              title: error ?? 'No calls found',
              onRetry: controller.loadCalls,
            );
          }

          final loadingMore = controller.isLoadingMore.value;
          final playingId = controller.playingCallId.value;
          final loadingId = controller.loadingRecordingId.value;
          final whatsappId = controller.openingWhatsappId.value;

          return RefreshIndicator(
            onRefresh: controller.loadCalls,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Neeche pahunchne se thoda pehle agla page mangao
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 300) {
                  controller.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: calls.length + (loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= calls.length) {
                    return const _CallShimmerCard();
                  }

                  final call = calls[index];

                  return CallCard(
                    index: index,
                    call: call,
                    isPlaying: playingId == call.id,
                    isRecordingLoading: loadingId == call.id,
                    isWhatsappLoading: whatsappId == call.id,
                    onWhatsapp: () => _openWhatsapp(context, controller, call),
                    onCall: () =>
                        showMakeCallDialog(context, number: call.customerNumber),
                    onToggleRecording: () => controller.toggleRecording(call),
                    onFieldChanged: (field, value) =>
                        _changeField(context, controller, call, field, value),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================
// EMPTY / ERROR
// ============================================================

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SHIMMER (loading)
// ============================================================

class _CallsShimmerList extends StatelessWidget {
  const _CallsShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: 5,
      itemBuilder: (_, __) => const _CallShimmerCard(),
    );
  }
}

class _CallShimmerCard extends StatelessWidget {
  const _CallShimmerCard();

  Widget _bar(double width, {double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TAppColors.darkCard : TAppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Shimmer.fromColors(
        baseColor: border,
        highlightColor: Color.lerp(border, Colors.white, isDark ? 0.12 : 0.7)!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [_bar(90), const Spacer(), _bar(70)]),
            const SizedBox(height: 16),
            Row(
              children: [
                _bar(110, height: 16),
                const Spacer(),
                _bar(110, height: 16),
              ],
            ),
            const SizedBox(height: 16),
            _bar(200),
            const SizedBox(height: 14),
            Row(
              children: [
                _bar(80, height: 24),
                const SizedBox(width: 8),
                _bar(100, height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
