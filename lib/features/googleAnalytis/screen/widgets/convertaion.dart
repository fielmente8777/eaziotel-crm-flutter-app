// lib/features/googleAnalytis/screen/widgets/conversions_card.dart

 import 'package:eazotel/features/googleAnalytis/models/Conversions%20model.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart' show analyticsLoader;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversionsCard extends StatelessWidget {
  final DashboardMetrics? metrics;
  final List<ConversionItem> conversions;
  final AnalyticsLayout layout;
  final bool isLoading;

  const ConversionsCard({
    super.key,
    required this.metrics,
    required this.conversions,
    required this.layout,
    this.isLoading = false,
  });

  static const _green = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final fmt = NumberFormat.decimalPattern();
    final m = metrics ??
        const DashboardMetrics(
            callClicks: 0, formSubmissions: 0, whatsappClicks: 0);

    final tiles = [
      _TileData('Call clicks', m.callClicks, Icons.call_outlined,
          const Color(0xFF3B82F6)),
      _TileData('WhatsApp clicks', m.whatsappClicks, Icons.chat_outlined,
          const Color(0xFF25D366)),
      _TileData('Form submissions', m.formSubmissions,
          Icons.assignment_turned_in_outlined, const Color(0xFFA855F7)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isPhone ? 14 : 22),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(layout.radius),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Row(
            children: [
              Container(
                width: layout.isPhone ? 36 : 44,
                height: layout.isPhone ? 36 : 44,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: c.isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.flag_outlined,
                    color: _green, size: layout.isPhone ? 18 : 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversions',
                      style: TextStyle(
                        color: c.text,
                        fontSize: layout.isPhone ? 15 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Leads from your website',
                      style:
                          TextStyle(color: c.subText, fontSize: layout.bodyFont),
                    ),
                  ],
                ),
              ),
              if (!isLoading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmt.format(m.total),
                      style: TextStyle(
                        color: c.text,
                        fontSize: layout.isPhone ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('total leads',
                        style: TextStyle(color: c.subText, fontSize: 11)),
                  ],
                ),
            ],
          ),
          SizedBox(height: layout.isPhone ? 14 : 20),

          if (isLoading)
            analyticsLoader()
          else ...[
            // ---------- Tiles ----------
            LayoutBuilder(
              builder: (context, box) {
                final cols = box.maxWidth >= 330 ? 3 : 1;
                const gap = 10.0;
                final w = (box.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final t in tiles)
                      _LeadTile(
                        data: t,
                        width: w,
                        total: m.total,
                        horizontal: cols == 1,
                      ),
                  ],
                );
              },
            ),

            // ---------- Key events list (agar aaye) ----------
            if (conversions.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'KEY EVENTS',
                style: TextStyle(
                  color: c.subText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              for (final cv in conversions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: _green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cv.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: c.text, fontSize: layout.bodyFont + 1),
                        ),
                      ),
                      Text(
                        fmt.format(cv.count),
                        style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w600,
                          fontSize: layout.bodyFont + 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            // ---------- Empty hint ----------
            if (m.total == 0 && conversions.isEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.text.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: c.subText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No leads recorded in this period. Check that call, '
                        'WhatsApp and form-submit events are firing on the website.',
                        style: TextStyle(
                          color: c.subText,
                          fontSize: layout.bodyFont,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TileData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _TileData(this.label, this.value, this.icon, this.color);
}

class _LeadTile extends StatefulWidget {
  final _TileData data;
  final double width;
  final int total;
  final bool horizontal;

  const _LeadTile({
    required this.data,
    required this.width,
    required this.total,
    required this.horizontal,
  });

  @override
  State<_LeadTile> createState() => _LeadTileState();
}

class _LeadTileState extends State<_LeadTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final d = widget.data;
    final share = widget.total == 0 ? 0.0 : d.value / widget.total;
    final fmt = NumberFormat.decimalPattern();

    final icon = Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: d.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(d.icon, size: 16, color: d.color),
    );

    final value = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: d.value.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(
        fmt.format(v.round()),
        style: TextStyle(
          color: d.value == 0 ? c.subText : c.text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );

    final label = Text(
      d.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: c.subText, fontSize: 11.5),
    );

    final shareBar = ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: share,
        minHeight: 4,
        backgroundColor: c.text.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation(d.color),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: widget.width,
        padding: const EdgeInsets.all(12),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: _hover
              ? d.color.withValues(alpha: c.isDark ? 0.10 : 0.06)
              : c.text.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover ? d.color.withValues(alpha: 0.5) : c.border,
          ),
        ),
        child: widget.horizontal
            ? Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [label, const SizedBox(height: 6), shareBar],
                    ),
                  ),
                  const SizedBox(width: 12),
                  value,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  icon,
                  const SizedBox(height: 12),
                  value,
                  const SizedBox(height: 4),
                  label,
                  const SizedBox(height: 10),
                  shareBar,
                ],
              ),
      ),
    );
  }
}