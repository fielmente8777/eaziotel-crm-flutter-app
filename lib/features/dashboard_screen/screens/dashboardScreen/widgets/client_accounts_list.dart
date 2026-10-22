// ============================================================
// CLIENT ACCOUNTS  (sirf role = "owner")   web ke LocationSwitcher jaisa
//
//   [🔍 Search client]
//   (S) Sparv Hospitality        Mandrem, Goa, India     ›
//   (P) Peace at Peak            India                   ›
//
// Tap -> "Switch to X?" -> switch-account -> naya token ->
// client ka data khulta hai; original owner session alag rehta hai.
// ============================================================

import 'package:eazotel/core/local_storage/session_cleaner.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/core/navigation/session_navigation.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/auth_user_model.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashbord_botum_nav.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientAccountsList extends StatelessWidget {
  const ClientAccountsList({super.key, required this.controller});

  final LocationController controller;

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
  ];

  Future<void> _switch(BuildContext context, ClientAccountModel client) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to ${client.hotelName}?'),
        content: const Text('Open this client\'s hotels.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    await controller.switchClient(
      client,
      onError: (m) => Get.snackbar(
        'Could not switch',
        m,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TAppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      ),
      // Purane account ka sab data hatao, phir naye token se shuru
      onSwitched: () async {
        if (!context.mounted) return;
        await _restartDashboard(context);
      },
    );
  }

  static Future<void> returnToOwner(BuildContext context) async {
    if (await TokenStorage.restoreOwner()) {
      if (!context.mounted) return;
      await _restartDashboard(context);
    }
  }

  static Future<void> _restartDashboard(BuildContext context) =>
      SessionNavigation.restart(
        context: context,
        clearControllers: SessionCleaner.deleteControllers,
        destination: () => const DashboardBottomNav(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sub = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (v) => controller.clientSearch.value = v,
          decoration: const InputDecoration(
            hintText: 'Search client',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.isClientsLoading.value &&
                controller.clients.isEmpty) {
              return Center(
                child: Icon(Icons.hourglass_top_rounded, color: sub, size: 32),
              );
            }

            final list = controller.visibleClients;
            final switching = controller.switchingClient.value;

            if (list.isEmpty) {
              return Center(
                child: Text(
                  controller.clients.isEmpty
                      ? 'No client accounts found'
                      : 'No client matches your search',
                  style: TextStyle(color: sub),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadClients,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  final name = c.hotelName.isEmpty ? 'Client' : c.hotelName;
                  final color =
                      _colors[name.codeUnits.fold(0, (a, b) => a + b) %
                          _colors.length];
                  final missingEmail = c.hotelEmail.isEmpty;
                  final busy =
                      switching.isNotEmpty && switching == c.hotelEmail;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: switching.isEmpty && !missingEmail,
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: .18),
                      child: Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      missingEmail
                          ? '${c.place.isEmpty ? '' : '${c.place}\n'}Account email missing · Switch unavailable'
                          : c.place.isEmpty
                          ? c.hotelEmail
                          : c.place,
                      maxLines: missingEmail ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      busy
                          ? Icons.hourglass_top_rounded
                          : missingEmail
                          ? Icons.info_outline_rounded
                          : Icons.swap_horiz_rounded,
                      color: busy ? theme.colorScheme.primary : sub,
                    ),
                    onTap: () => _switch(context, c),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
