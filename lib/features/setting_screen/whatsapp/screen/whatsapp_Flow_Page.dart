import 'package:eazotel/features/setting_screen/whatsapp/controller/whatsapp_Flow_controller.dart';
import 'package:eazotel/features/setting_screen/whatsapp/flow_builder/screen/flow_builder_view.dart';
import 'package:eazotel/features/whatsapp/models/FlowResponseModel.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screen/widgets/setting_section_card.dart';

class WhatsappFlowPage extends StatelessWidget {
  const WhatsappFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WhatsappFlowPageController());

    return TResponsiveBuilder(
      builder: (context, r) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(r.pagePadding),
          child: TCenteredContent(
            child: SettingSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlowTabs(controller: controller),
                  const SizedBox(height: 16),
                  Obx(() {
                    switch (controller.selectedTab.value) {
                      case FlowTab.flowName:
                        return _FlowListTab(controller: controller);
                      case FlowTab.createFlow:
                        return const FlowBuilderView();
                    }
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// TABS
// ============================================================

class _FlowTabs extends StatelessWidget {
  const _FlowTabs({required this.controller});

  final WhatsappFlowPageController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Obx(() {
        final selected = controller.selectedTab.value;

        return Row(
          children: [
            for (final tab in FlowTab.values)
              InkWell(
                onTap: () => controller.changeTab(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: tab == selected ? p.primary : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: tab == selected ? p.text : p.subText,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ============================================================
// FLOW NAME TAB  (loading / error / empty / table)
// ============================================================

class _FlowListTab extends StatelessWidget {
  const _FlowListTab({required this.controller});

  final WhatsappFlowPageController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final error = controller.errorMessage.value;

      if (error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              children: [
                Text(error, style: TextStyle(color: p.subText)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: controller.loadFlows,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final flows = controller.flows;

      if (flows.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('No flows found', style: TextStyle(color: p.subText)),
          ),
        );
      }

      return _FlowTable(flows: flows);
    });
  }
}

// ============================================================
// TABLE
// ============================================================

class _FlowTable extends StatelessWidget {
  const _FlowTable({required this.flows});

  final List<FlowItemModel> flows;

  static const double _wIndex = 60;
  static const double _wName = 200;
  static const double _wId = 190;
  static const double _wDate = 180;
  static const double _wAction = 80;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              // ---------- Header ----------
              Container(
                color: p.primary.withOpacity(0.15),
                child: Row(
                  children: [
                    _cell('#', _wIndex, p, header: true, center: true),
                    _cell('Flow Name', _wName, p, header: true),
                    _cell('Flow ID', _wId, p, header: true),
                    _cell('Created At', _wDate, p, header: true),
                    _cell('Action', _wAction, p, header: true, center: true),
                  ],
                ),
              ),
              // ---------- Rows ----------
              for (var i = 0; i < flows.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: p.border)),
                  ),
                  child: Row(
                    children: [
                      _cell(
                        (i + 1).toString().padLeft(2, '0'),
                        _wIndex,
                        p,
                        center: true,
                      ),
                      _cell(_capitalize(flows[i].flowName), _wName, p),
                      _cell(flows[i].flowId ?? '-', _wId, p),
                      _cell(_formatDate(flows[i].createdAt), _wDate, p),
                      SizedBox(
                        width: _wAction,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            size: 18,
                            color: p.primary,
                          ),
                          onPressed: () {
                            showFlowPreviewDialog(context, flows[i]);
                          },
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
  }

  Widget _cell(
    String text,
    double width,
    SettingPalette p, {
    bool header = false,
    bool center = false,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: header ? FontWeight.w600 : FontWeight.w400,
            color: header ? p.text : p.subText,
          ),
        ),
      ),
    );
  }

  String _capitalize(String? s) {
    if (s == null || s.isEmpty) return '-';
    return s[0].toUpperCase() + s.substring(1);
  }

  /// "2026-04-04T12:47:17.369Z" -> "04/04/2026, 18:17:17" (local time)
  String _formatDate(String? iso) {
    final date = DateTime.tryParse(iso ?? '')?.toLocal();
    if (date == null) return '-';

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year}, '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }
}

// ============================================================
// FLOW PREVIEW DIALOG  (when the eye icon is pressed)
// ============================================================

void showFlowPreviewDialog(BuildContext context, FlowItemModel flow) {
  showDialog(
    context: context,
    builder: (_) => _FlowPreviewDialog(flow: flow),
  );
}

class _FlowPreviewDialog extends StatelessWidget {
  const _FlowPreviewDialog({required this.flow});

  final FlowItemModel flow;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final screens = flow.screens ?? [];

    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Title + X ----------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flow.flowName ?? '-',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: p.text),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ---------- Screens + fields ----------
              Flexible(
                child: screens.isEmpty
                    ? Text('No screens', style: TextStyle(color: p.subText))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final screen in screens) ...[
                              Text(
                                (screen.title ?? '').trim(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: p.text,
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (final field in screen.fields ?? [])
                                _PreviewField(field: field),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
              ),

              // ---------- Close ----------
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only preview of one field (label + box)
class _PreviewField extends StatelessWidget {
  const _PreviewField({required this.field});

  final FlowFieldModel field;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final type = (field.type ?? 'text').toLowerCase();

    final hint = switch (type) {
      'date' => 'dd/mm/yyyy',
      'email' => 'Email',
      'number' => 'Number',
      _ => field.label ?? '',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${field.label ?? ''}${field.required == true ? ' *' : ''}',
            style: TextStyle(fontSize: 12.5, color: p.subText),
          ),
          const SizedBox(height: 6),
          TextField(
            readOnly: true,
            style: TextStyle(fontSize: 13.5, color: p.text),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(color: p.subText.withOpacity(0.6)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: p.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
