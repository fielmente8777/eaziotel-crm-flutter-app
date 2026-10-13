// ============================================================
// ACCOUNT CARDS
//
// Is file me do card hain. Dono controller.info se data padhte hain:
//   1. WhatsappAccountCard : naam, WABA ID, Business ID
//   2. WhatsappPhoneCard   : number, quality rating, platform, mode
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';

/// "WhatsApp Business Account" card: naam, WABA ID, Business ID
class WhatsappAccountCard extends StatelessWidget {
  const WhatsappAccountCard({super.key, required this.controller});

  final WhatsappSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Obx(() {
        final info = controller.info.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_outlined, size: 14, color: p.subText),
                const SizedBox(width: 6),
                Text(
                  'WHATSAPP BUSINESS ACCOUNT',
                  style: TextStyle(
                    color: p.subText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              info.accountName,
              style: TextStyle(
                color: p.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            _line(p, 'WABA ID', info.wabaId),
            _line(p, 'Business ID', info.businessId),
          ],
        );
      }),
    );
  }

  Widget _line(SettingPalette p, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label:  ',
              style: TextStyle(color: p.subText),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: p.text),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 12.5),
      ),
    );
  }
}

/// "Phone Number" card: number, quality rating, platform, account mode
class WhatsappPhoneCard extends StatelessWidget {
  const WhatsappPhoneCard({super.key, required this.controller});

  final WhatsappSettingController controller;

  Color _qualityColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'green':
      case 'high':
        return TAppColors.success;
      case 'yellow':
      case 'medium':
        return TAppColors.warning;
      case 'red':
      case 'low':
        return TAppColors.error;
      default:
        return TAppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Obx(() {
        final info = controller.info.value;

        final quality = info.qualityRating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: p.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Phone Number',
                      style: TextStyle(color: p.primary, fontSize: 12.5),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Quality Rating: ',
                      style: TextStyle(color: p.subText, fontSize: 12),
                    ),
                    _Pill(label: quality, color: _qualityColor(quality)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              info.phoneNumber,
              style: TextStyle(
                color: p.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              info.verifiedName,
              style: TextStyle(color: p.subText, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Box(
                  label: 'Cloud API',
                  // Ye card tabhi dikhta hai jab WhatsApp juda ho
                  value: 'Connected',
                  color: TAppColors.success,
                ),
                _Box(
                  label: 'Platform',
                  value: info.platform,
                  color: TAppColors.success,
                ),
                _Box(
                  label: 'Account Mode',
                  value: info.accountMode,
                  color: TAppColors.success,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.border),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label:  ',
              style: TextStyle(color: p.primary),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
