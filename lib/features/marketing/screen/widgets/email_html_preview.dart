// ============================================================
// EMAIL HTML PREVIEW  (email jaisa dikhta hai, waisa)
//
// Marketing email ~600px chaude bante hain. Phone par unhe 600 par
// bana kar chhota (scale) karte hain, jaise Gmail dikhata hai.
// Email hamesha safed kagaz par (dark theme me bhi), kyunki
// email isi tarah design hote hain.
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

  /// Diya to itni oonchai ke andar scroll (card me thumbnail jaisa)
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

        // Jagah kam hai -> 600 par bana kar chhota karo
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
