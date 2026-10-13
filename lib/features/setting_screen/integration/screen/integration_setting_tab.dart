// ============================================================
// INTEGRATION SETTING TAB  (Settings > Integration)
//
//   upar   : "Integrations" heading + search + All / Communication / Analytics
//   neeche : cards ka grid
//              phone 1 column, tablet 2, window 4
//
// Data controller/ me, card widgets/ me.
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/integration_setting_controller.dart';
import '../models/integration_item.dart';
import 'widgets/exotel_connect_dialog.dart';
import 'widgets/integration_card.dart';
import 'widgets/search_console_dialog.dart';

class IntegrationSettingTab extends StatelessWidget {
  const IntegrationSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntegrationSettingController());

    return TResponsiveBuilder(
      builder: (context, r) {
        final columns = r.value(phone: 1, tablet: 2, desktop: 4);
        final gap = r.gap + 4;

        return Obx(() {
          if (controller.isLoading.value) {
            return _Loading(columns: columns, padding: r.pagePadding);
          }

          final error = controller.errorMessage.value;

          if (error != null) {
            return _Message(message: error, onRetry: controller.load);
          }

          final cards = <Widget>[
            for (final item in controller.visibleItems)
              IntegrationCard(
                item: item,
                busy: controller.connectingKey.value == item.apiKey,
                // Exotel Connect = form, baaki controller sambhalta hai
                onTap: () => !item.connected && item.apiKey == 'exotel'
                    ? showExotelConnectDialog(context, controller)
                    : controller.onAction(item),
              ),
            if (controller.showSearchConsole)
              SearchConsoleCard(
                settings: controller.gsc.value,
                gaConnected: controller.gaPropertyId.value != null,
                onEdit: () => showSearchConsoleDialog(context, controller),
              ),
          ];

          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              padding: EdgeInsets.all(r.pagePadding),
              children: [
                const _Header(),
                SizedBox(height: gap),
                _SearchAndTabs(controller: controller),
                SizedBox(height: gap),
                if (cards.isEmpty)
                  const _Message(message: 'No integrations found')
                else
                  _Grid(columns: columns, gap: gap, children: cards),
              ],
            ),
          );
        });
      },
    );
  }
}

// ============================================================
// HEADER + SEARCH + TABS
// ============================================================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integrations',
          style: TextStyle(
            color: p.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Connect your favorite apps to bring all your data into one dashboard',
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _SearchAndTabs extends StatelessWidget {
  const _SearchAndTabs({required this.controller});

  final IntegrationSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => controller.search.value = value,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search integrations...',
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in IntegrationCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.label),
                    selected: controller.category.value == category,
                    onSelected: (_) => controller.category.value = category,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      color: controller.category.value == category
                          ? p.primary
                          : p.subText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// GRID  (har line ke card ek barabar unche)
// ============================================================

class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.gap,
    required this.children,
  });

  final int columns;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < children.length; i += columns) {
      final row = children.skip(i).take(columns).toList();

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) SizedBox(width: gap),
                  Expanded(
                    child: j < row.length ? row[j] : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

// ============================================================
// LOADING / MESSAGE
// ============================================================

class _Loading extends StatelessWidget {
  const _Loading({required this.columns, required this.padding});

  final int columns;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget block() => Container(
      height: 170,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(
        p.border,
        Colors.white,
        p.isDark ? 0.12 : 0.7,
      )!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        children: [
          _Grid(
            columns: columns,
            gap: 12,
            children: List.generate(columns * 2, (_) => block()),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.extension_outlined, size: 44, color: p.subText),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
