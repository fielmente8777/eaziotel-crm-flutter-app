// lib/features/googleAnalytis/screen/widgets/top_pages_card.dart

 import 'package:eazotel/features/googleAnalytis/models/topPageModel.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart' show analyticsLoader;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TopPagesCard extends StatefulWidget {
  final List<TopPage> pages;
  final AnalyticsLayout layout;
  final bool isLoading;

  const TopPagesCard({
    super.key,
    required this.pages,
    required this.layout,
    this.isLoading = false,
  });

  @override
  State<TopPagesCard> createState() => _TopPagesCardState();
}

class _TopPagesCardState extends State<TopPagesCard> {
  int? _hover;
  final _fmt = NumberFormat.decimalPattern();

  // Table column widths (wide layout)
  static const _wRank = 34.0;
  static const _wBar = 84.0;
  static const _wViews = 70.0;
  static const _wUsers = 96.0;
  static const _wTime = 120.0;
  static const _wBounce = 120.0;

  void _setHover(int? i) {
    if (_hover == i) return;
    setState(() => _hover = i);
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Color _headerColor(AnalyticsPalette c) =>
      c.isDark ? const Color(0xFF6B8AFD) : const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final l = widget.layout;

    // The API sends it ranked, but still sort by views (stable)
    final pages = [...widget.pages]
      ..sort((a, b) => b.views.compareTo(a.views));
    final maxViews = pages.isEmpty ? 0 : pages.first.views;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(l.isPhone ? 14 : 22),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(l.radius),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Pages',
            style: TextStyle(
              color: c.text,
              fontSize: l.isPhone ? 16 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Performance ranked by total page views',
            style: TextStyle(color: c.subText, fontSize: l.bodyFont),
          ),
          SizedBox(height: l.isPhone ? 14 : 26),
          if (widget.isLoading)
            analyticsLoader()
          else if (pages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No data', style: TextStyle(color: c.subText)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, box) => box.maxWidth < 680
                  ? _compactList(c, pages, maxViews)
                  : _table(c, pages, maxViews),
            ),
        ],
      ),
    );
  }

  // ======================= WIDE: TABLE =======================
  Widget _table(AnalyticsPalette c, List<TopPage> pages, int maxViews) {
    final head = TextStyle(
      color: _headerColor(c),
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );

    Widget h(String t, double w) => SizedBox(
          width: w,
          child: Text(t, textAlign: TextAlign.right, style: head),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(child: Text('PAGE', style: head)),
              const SizedBox(width: _wBar),
              h('VIEWS', _wViews),
              h('USERS', _wUsers),
              h('AVG. TIME', _wTime),
              h('BOUNCE', _wBounce),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: c.subText),
        const SizedBox(height: 6),
        for (int i = 0; i < pages.length; i++)
          _tableRow(c, i, pages[i], maxViews),
      ],
    );
  }

  Widget _tableRow(AnalyticsPalette c, int i, TopPage p, int maxViews) {
    final hovered = _hover == i;
    final num = TextStyle(
      color: c.text.withValues(alpha: 0.85),
      fontSize: widget.layout.isDesktop ? 18 : 16,
      fontWeight: FontWeight.w500,
    );

    Widget cell(String t, double w) => SizedBox(
          width: w,
          child: Text(t, textAlign: TextAlign.right, style: num),
        );

    return MouseRegion(
      onEnter: (_) => _setHover(i),
      onExit: (_) => _setHover(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        decoration: BoxDecoration(
          color: hovered
              ? c.text.withValues(alpha: c.isDark ? 0.04 : 0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            SizedBox(
              width: _wRank,
              child: Text(
                '${i + 1}.',
                style: TextStyle(
                  color: c.subText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: _pageInfo(c, p, hovered, titleSize: 18)),
            const SizedBox(width: 16),
            SizedBox(
              width: _wBar,
              child: _bar(c, p.views, maxViews),
            ),
            cell(_fmt.format(p.views), _wViews),
            cell(_fmt.format(p.users), _wUsers),
            cell(p.avgTimeLabel, _wTime),
            SizedBox(
              width: _wBounce,
              child: Align(
                alignment: Alignment.centerRight,
                child: _bounceChip(p.bouncePercent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= NARROW: CARDS =======================
  Widget _compactList(AnalyticsPalette c, List<TopPage> pages, int maxViews) {
    return Column(
      children: [
        for (int i = 0; i < pages.length; i++) ...[
          if (i > 0) Divider(height: 1, color: c.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${i + 1}.',
                        style: TextStyle(
                          color: c.subText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _pageInfo(c, pages[i], false, titleSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: _bar(c, pages[i].views, maxViews),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _mini(c, 'Views', _fmt.format(pages[i].views)),
                      ),
                      Expanded(
                        child: _mini(c, 'Users', _fmt.format(pages[i].users)),
                      ),
                      Expanded(
                        child: _mini(c, 'Avg. time', pages[i].avgTimeLabel),
                      ),
                      _bounceChip(pages[i].bouncePercent, small: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _mini(AnalyticsPalette c, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: _headerColor(c),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: c.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  // ======================= SHARED PIECES =======================
  Widget _pageInfo(
    AnalyticsPalette c,
    TopPage p,
    bool hovered, {
    required double titleSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.pageName.isEmpty ? p.pagePath : p.pageName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: c.text,
            fontSize: titleSize,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 3),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _open(p.fullUrl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new, size: 13, color: c.subText),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    p.displayUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.subText,
                      fontSize: 13,
                      decoration: hovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: c.subText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar(AnalyticsPalette c, int views, int maxViews) {
    final ratio = maxViews == 0 ? 0.0 : (views / maxViews).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 6,
        color: c.isDark
            ? Colors.white.withValues(alpha: 0.92)
            : const Color(0xFFE5E7EB),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: ratio,
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2F6FED),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  /// <40% green, 40–60% amber, >=60% red (like the screenshot)
  Widget _bounceChip(double pct, {bool small = false}) {
    final Color fg;
    if (pct < 40) {
      fg = const Color(0xFF16A34A);
    } else if (pct < 60) {
      fg = const Color(0xFFD97706);
    } else {
      fg = const Color(0xFFDC2626);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(fg.withValues(alpha: 0.08), Colors.white),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${pct.toStringAsFixed(1)}%',
        style: TextStyle(
          color: fg,
          fontSize: small ? 11 : 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}