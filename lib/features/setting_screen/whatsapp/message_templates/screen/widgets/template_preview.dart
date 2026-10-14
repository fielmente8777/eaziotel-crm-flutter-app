// ============================================================
// TEMPLATE PREVIEW
// Template WhatsApp par kaisa dikhega: chat ki background par
// ek message (header, body, footer, time) aur neeche buttons.
// {{1}} ki jagah sample dikhta hai (sample na ho to {{1}} hi).
// ============================================================

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:flutter/material.dart';

class TemplatePreviewButton {
  const TemplatePreviewButton(this.text, this.icon);
  final String text;
  final IconData icon;
}

class TemplatePreview extends StatelessWidget {
  /// Server wale (saved) template se preview. {{1}} ki jagah Meta ke
  /// sample (example) dikhte hain.
  factory TemplatePreview.ofTemplate(WhatsappTemplate template) {
    TemplateComponent? part(String type) => template.components
        ?.where((c) => c.type?.toUpperCase() == type)
        .firstOrNull;

    final head = part('HEADER');
    final main = part('BODY');
    final foot = part('FOOTER');
    final btns = part('BUTTONS');

    String fill(String text, List<String> samples) {
      var out = text;
      for (var i = 0; i < samples.length; i++) {
        if (samples[i].trim().isNotEmpty) {
          out = out.replaceAll('{{${i + 1}}}', samples[i]);
        }
      }
      return out;
    }

    final format = head?.format?.toUpperCase();

    return TemplatePreview(
      headerText: format == 'TEXT'
          ? fill(head?.text ?? '', head?.example?.headerText ?? const [])
          : null,
      showImageHeader: format == 'IMAGE',
      headerImageUrl: head?.example?.headerHandle?.firstOrNull,
      body: fill(
        main?.text ?? '',
        main?.example?.bodyText?.firstOrNull ?? const [],
      ),
      footer: foot?.text ?? '',
      buttons: [
        for (final b in btns?.buttons ?? <TemplateButton>[])
          TemplatePreviewButton(
            b.text ?? '',
            b.type == 'URL'
                ? Icons.open_in_new
                : b.type == 'PHONE_NUMBER'
                ? Icons.call
                : Icons.reply,
          ),
      ],
    );
  }

  const TemplatePreview({
    super.key,
    required this.body,
    this.headerText,
    this.headerImagePath,
    this.headerImageUrl,
    this.showImageHeader = false,
    this.footer = '',
    this.buttons = const [],
  });

  final String body;
  final String? headerText;
  final String? headerImagePath;
  final String? headerImageUrl;
  final bool showImageHeader;
  final String footer;
  final List<TemplatePreviewButton> buttons;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final chatBg = dark ? const Color(0xFF0B141A) : const Color(0xFFEFE7DD);
    final bubble = dark ? const Color(0xFF1F2C34) : Colors.white;
    final text = dark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21);
    final muted = dark ? const Color(0xFF8696A0) : const Color(0xFF667781);
    const link = Color(0xFF00A5F4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: chatBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bubble,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 2),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showImageHeader) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 1.9,
                          child: _image(muted),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((headerText ?? '').trim().isNotEmpty) ...[
                            Text(
                              headerText!,
                              style: TextStyle(
                                color: text,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            body.trim().isEmpty
                                ? 'Your message will appear here…'
                                : body,
                            style: TextStyle(
                              color: body.trim().isEmpty ? muted : text,
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                          if (footer.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              footer,
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '12:30',
                              style: TextStyle(color: muted, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              for (final b in buttons) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: bubble,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(b.icon, size: 16, color: link),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          b.text.isEmpty ? 'Button' : b.text,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: link,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _image(Color muted) {
    if (headerImagePath != null) {
      return Image.file(File(headerImagePath!), fit: BoxFit.cover);
    }
    if (headerImageUrl != null && headerImageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: headerImageUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _placeholder(muted),
      );
    }
    return _placeholder(muted);
  }

  Widget _placeholder(Color muted) => Container(
    color: muted.withValues(alpha: .15),
    alignment: Alignment.center,
    child: Icon(Icons.image_outlined, size: 36, color: muted),
  );
}
