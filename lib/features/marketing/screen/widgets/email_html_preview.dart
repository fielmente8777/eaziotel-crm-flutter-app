// ============================================================
// EMAIL HTML PREVIEW  (shows the email as it will look)
//
// Marketing emails are made about 600px wide. On phones we build them at 600
// and scale them down, like Gmail does.
// The email is always on white paper (even in dark theme), because
// that is how emails are designed.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';

class EmailHtmlPreview extends StatelessWidget {
  const EmailHtmlPreview({
    super.key,
    required this.html,
    this.maxHeight,
    this.designWidth = 600,
  });

  final String html;

  /// If given, scroll within this height (like a thumbnail in a card)
  final double? maxHeight;
  final double designWidth;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final page = LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth.isFinite ? box.maxWidth : designWidth;
        final content = HtmlWidget(
          html.isEmpty ? '<p></p>' : html,
          textStyle: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
        );

        // Not enough space -> build at 600 and scale down
        if (width < designWidth) {
          return FittedBox(
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            child: SizedBox(width: designWidth, child: content),
          );
        }
        return content;
      },
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: maxHeight == null
          ? page
          : ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: SingleChildScrollView(child: page),
            ),
    );
  }
}
