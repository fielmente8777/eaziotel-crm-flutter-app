// ============================================================
// TEMPLATE PREVIEW
//
// Chune hue WhatsApp template ka chhota preview:
//   header (mota)  ->  body  ->  footer (chhota)
// ============================================================

import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';

class TemplatePreview extends StatelessWidget {
  const TemplatePreview({super.key, required this.template});

  final WhatsappTemplate template;

  /// HEADER / BODY / FOOTER ka text (na ho to khali)
  String _textOf(String type) {
    final component = template.components?.firstWhereOrNull(
      (c) => c.type?.toUpperCase() == type,
    );

    return component?.text?.replaceAll('\r\n', '\n').trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final header = _textOf('HEADER');
    final body = _textOf('BODY');
    final footer = _textOf('FOOTER');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header.isNotEmpty) ...[
            Text(
              header,
              style: TextStyle(
                color: p.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            body.isEmpty ? 'This template has no text.' : body,
            style: TextStyle(color: p.primary, fontSize: 12, height: 1.4),
          ),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(footer, style: TextStyle(color: p.subText, fontSize: 10.5)),
          ],
        ],
      ),
    );
  }
}
