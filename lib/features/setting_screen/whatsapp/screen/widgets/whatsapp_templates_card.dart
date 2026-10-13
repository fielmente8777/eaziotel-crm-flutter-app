// ============================================================
// TEMPLATES CARD
//
// "WhatsApp Templates" wala card. controller.templates ki list dikhata hai.
//   - Tablet / window : table  (_TemplateHeaderRow + _TemplateRow)
//   - Phone           : card   (_TemplateTile)
// Har template par teen button: Delete, Edit, View (_Actions).
// ============================================================

import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';

class WhatsappTemplatesCard extends StatelessWidget {
  const WhatsappTemplatesCard({
    super.key,
    required this.controller,
    required this.r,
  });

  final WhatsappSettingController controller;
  final TResponsive r;

  void _view(BuildContext context, WhatsappTemplate template) {
    final p = SettingPalette(context);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: p.card,
        title: Text(
          template.name ?? 'Template',
          style: TextStyle(color: p.text, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Text(
            controller.bodyOf(template) ?? 'This template has no body text.',
            style: TextStyle(color: p.text, fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'WhatsApp Templates',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: settingSmallButton().copyWith(
                  backgroundColor: const WidgetStatePropertyAll(
                    TAppColors.success,
                  ),
                  foregroundColor: const WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: controller.createTemplate,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Template'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final templates = controller.templates.toList();

            if (templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No templates found',
                  style: TextStyle(color: p.subText, fontSize: 13),
                ),
              );
            }

            if (r.isPhone) {
              return Column(
                children: [
                  for (final template in templates)
                    _TemplateTile(
                      template: template,
                      controller: controller,
                      onView: () => _view(context, template),
                    ),
                ],
              );
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.border),
              ),
              child: Column(
                children: [
                  const _TemplateHeaderRow(),
                  for (final template in templates)
                    _TemplateRow(
                      template: template,
                      controller: controller,
                      onView: () => _view(context, template),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED':
      return TAppColors.success;
    case 'REJECTED':
      return TAppColors.error;
    default:
      return TAppColors.warning;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.template,
    required this.controller,
    required this.onView,
  });

  final WhatsappTemplate template;
  final WhatsappSettingController controller;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    Widget button(String tip, IconData icon, Color color, VoidCallback onTap) {
      return IconButton(
        tooltip: tip,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(icon, size: 17, color: color),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(
          'Delete',
          Icons.delete_outline,
          TAppColors.error,
          () => controller.deleteTemplate(template),
        ),
        button(
          'Edit',
          Icons.edit_outlined,
          TAppColors.success,
          () => controller.editTemplate(template),
        ),
        button('View', Icons.visibility_outlined, TAppColors.success, onView),
      ],
    );
  }
}

/// Table ke column ki chaudai. Heading aur har line me yahi use hoti hai,
/// isliye dono hamesha seedh me rehte hain.
const int _nameFlex = 4;
const int _otherFlex = 2;
const double _actionsWidth = 120;

/// Table ki sabse upar wali line: Name | Category | Language | Status | Actions
class _TemplateHeaderRow extends StatelessWidget {
  const _TemplateHeaderRow();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final style = TextStyle(
      color: p.primary,
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: _nameFlex,
            child: Text('Name', style: style),
          ),
          Expanded(
            flex: _otherFlex,
            child: Text('Category', style: style),
          ),
          Expanded(
            flex: _otherFlex,
            child: Text('Language', style: style),
          ),
          Expanded(
            flex: _otherFlex,
            child: Text('Status', style: style),
          ),
          SizedBox(
            width: _actionsWidth,
            child: Text('Actions', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

/// Table me ek template ki line (tablet / window)
class _TemplateRow extends StatelessWidget {
  const _TemplateRow({
    required this.template,
    required this.controller,
    required this.onView,
  });

  final WhatsappTemplate template;
  final WhatsappSettingController controller;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget text(String value, {bool isName = false}) {
      return Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isName ? p.text : p.subText,
          fontSize: 12.5,
          fontWeight: isName ? FontWeight.w600 : FontWeight.w400,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _nameFlex,
            child: text(template.name ?? '-', isName: true),
          ),
          Expanded(flex: _otherFlex, child: text(template.category ?? '-')),
          Expanded(flex: _otherFlex, child: text(template.language ?? '-')),
          Expanded(
            flex: _otherFlex,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(status: template.status ?? ''),
            ),
          ),
          SizedBox(
            width: _actionsWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: _Actions(
                template: template,
                controller: controller,
                onView: onView,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone par ek template ka card
class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.controller,
    required this.onView,
  });

  final WhatsappTemplate template;
  final WhatsappSettingController controller;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  template.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusPill(status: template.status ?? ''),
              const SizedBox(width: 8),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${template.category ?? '-'}  •  ${template.language ?? '-'}',
                  style: TextStyle(color: p.subText, fontSize: 11.5),
                ),
              ),
              _Actions(
                template: template,
                controller: controller,
                onView: onView,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
