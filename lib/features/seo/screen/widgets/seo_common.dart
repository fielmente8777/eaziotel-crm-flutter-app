// ============================================================
// SEO COMMON WIDGETS  (Local SEO + Website SEO dono)
//
//   SeoColors        : rang (light + dark dono me chalte hain)
//   SeoFormat        : 1,234 / ₹12.50 / #3.2
//   SeoRankTone      : rank ke hisaab se rang + label
//   SeoPanel         : icon + title + subtitle wala dabba
//   SeoHeaderIcon    : gradient wala gol-kona icon
//   SeoRankChip      : "#3" chip
//   SeoDifficulty    : 0-100 patti
//   SeoActionBadge   : Target / Optimize / Defend / Research
//   SeoStatCard      : bada number
//   SeoVisibilityGauge: gol meter (animation ke saath)
//   SeoCreditsChip   : AppBar me credits (tap = kis kaam ke kitne)
//   SeoEmptyState / SeoErrorState / SeoShimmer / SeoGrid
// ============================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/seo_token_response.dart';

class SeoColors {
  SeoColors._();

  static const emerald = Color(0xFF10B981);
  static const teal = Color(0xFF14B8A6);
  static const blue = Color(0xFF3B82F6);
  static const indigo = Color(0xFF6366F1);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);
  static const grey = Color(0xFF8A8F98);

  static const localGradient = [emerald, teal];
  static const websiteGradient = [blue, indigo];
}

class SeoFormat {
  SeoFormat._();

  static final NumberFormat _number = NumberFormat.decimalPattern('en_IN');

  static String number(num? v) => v == null ? '—' : _number.format(v.round());

  static String money(num? v) => v == null ? '—' : '₹${v.toStringAsFixed(2)}';

  /// Average rank: "#3.2"
  static String rank(num? v) => v == null ? '—' : '#${v.toStringAsFixed(1)}';

  /// Ek keyword ka rank: "#3"
  static String rankWhole(num? v) => v == null ? '—' : '#${v.round()}';

  static String date(DateTime? d) =>
      d == null ? '' : DateFormat('d MMM').format(d);
}

class SeoRankTone {
  const SeoRankTone(this.color, this.label);

  final Color color;
  final String label;

  /// Google Maps rank (web: rankTone)
  static SeoRankTone maps(num? rank) {
    if (rank == null) return const SeoRankTone(SeoColors.grey, 'Not ranked');
    if (rank <= 3) return const SeoRankTone(SeoColors.emerald, 'Top 3');
    if (rank <= 7) return const SeoRankTone(SeoColors.teal, 'Top 7');
    if (rank <= 15) return const SeoRankTone(SeoColors.amber, 'Page 1–2');
    return const SeoRankTone(SeoColors.rose, 'Low');
  }

  /// Google search rank (web: getOrganicRankStyle)
  static SeoRankTone organic(num? rank) {
    if (rank == null) return const SeoRankTone(SeoColors.grey, 'Not ranked');
    if (rank <= 3) return const SeoRankTone(SeoColors.emerald, 'Top 3');
    if (rank <= 10) return const SeoRankTone(SeoColors.teal, 'Page 1');
    if (rank <= 20) return const SeoRankTone(SeoColors.amber, 'Page 2');
    return const SeoRankTone(SeoColors.rose, 'Low');
  }

  /// Map coverage ka ek point (web: getRankStyle)
  static SeoRankTone grid(num? rank) {
    if (rank == null) return const SeoRankTone(SeoColors.grey, 'Not ranked');
    if (rank <= 3) return const SeoRankTone(Color(0xFF22C55E), '1–3');
    if (rank <= 6) return const SeoRankTone(Color(0xFF84CC16), '4–6');
    if (rank <= 10) return const SeoRankTone(Color(0xFFEAB308), '7–10');
    if (rank <= 15) return const SeoRankTone(Color(0xFFF97316), '11–15');
    return const SeoRankTone(Color(0xFFEF4444), '16+');
  }

  static const gridLegend = [
    SeoRankTone(Color(0xFF22C55E), '1–3'),
    SeoRankTone(Color(0xFF84CC16), '4–6'),
    SeoRankTone(Color(0xFFEAB308), '7–10'),
    SeoRankTone(Color(0xFFF97316), '11–15'),
    SeoRankTone(Color(0xFFEF4444), '16+'),
    SeoRankTone(SeoColors.grey, 'Not ranked'),
  ];
}

// ============================================================
// DABBE
// ============================================================

class SeoPanel extends StatelessWidget {
  const SeoPanel({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.color = SeoColors.emerald,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color color;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.subText, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class SeoHeaderIcon extends StatelessWidget {
  const SeoHeaderIcon({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 48,
  });

  final IconData icon;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: .35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * .5),
    );
  }
}

/// Chhota rangeen label (badge / status)
class SeoTag extends StatelessWidget {
  const SeoTag({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.loading = false,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            SeoSpin(child: Icon(Icons.sync, size: 13, color: color))
          else if (icon != null)
            Icon(icon, size: 13, color: color),
          if (loading || icon != null) const SizedBox(width: 4),
          // Jagah kam ho to "Optim…" (tootega nahi)
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon ghoomta rahe (refresh / scan ke time)
class SeoSpin extends StatefulWidget {
  const SeoSpin({super.key, required this.child, this.spinning = true});

  final Widget child;
  final bool spinning;

  @override
  State<SeoSpin> createState() => _SeoSpinState();
}

class _SeoSpinState extends State<SeoSpin> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _c.repeat();
  }

  @override
  void didUpdateWidget(SeoSpin old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_c.isAnimating) _c.repeat();
    if (!widget.spinning && _c.isAnimating) _c.reset();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _c, child: widget.child);
}

class SeoRankChip extends StatelessWidget {
  const SeoRankChip({
    super.key,
    required this.rank,
    required this.tone,
    this.icon,
    this.large = false,
  });

  final num? rank;
  final SeoRankTone tone;
  final IconData? icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tone.label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 12 : 8,
          vertical: large ? 7 : 4,
        ),
        decoration: BoxDecoration(
          color: tone.color.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: large ? 15 : 13, color: tone.color),
              const SizedBox(width: 4),
            ],
            Text(
              SeoFormat.rankWhole(rank),
              style: TextStyle(
                color: tone.color,
                fontSize: large ? 14 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keyword kitna mushkil hai (0-100)
class SeoDifficulty extends StatelessWidget {
  const SeoDifficulty({super.key, required this.value, this.width = 64});

  final double? value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final v = value;

    if (v == null) return Text('—', style: TextStyle(color: p.subText));

    final color = v >= 70
        ? SeoColors.rose
        : v >= 40
        ? SeoColors.amber
        : SeoColors.emerald;

    return Tooltip(
      message: v >= 70
          ? 'Hard to rank'
          : v >= 40
          ? 'Medium'
          : 'Easy to rank',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (v / 100).clamp(0, 1)),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, t, _) => LinearProgressIndicator(
                  value: t,
                  minHeight: 6,
                  color: color,
                  backgroundColor: p.border,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            v.round().toString(),
            style: TextStyle(
              color: p.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SeoActionBadge extends StatelessWidget {
  const SeoActionBadge({super.key, required this.type});

  final String type;

  static const _config = {
    'TARGET': ('Target', SeoColors.emerald, Icons.track_changes),
    'OPTIMIZE': ('Optimize', SeoColors.amber, Icons.lightbulb_outline),
    'DEFEND': ('Defend', SeoColors.teal, Icons.workspace_premium_outlined),
    'RESEARCH': ('Research', SeoColors.grey, Icons.auto_awesome_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final c = _config[type] ?? _config['RESEARCH']!;
    return SeoTag(text: c.$1, color: c.$2, icon: c.$3);
  }
}

class SeoStatCard extends StatelessWidget {
  const SeoStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.sub,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.subText,
                    fontSize: 10.5,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.subText, fontSize: 11.5),
                  ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Gol meter 0-100 (khulte hi bhar jaata hai)
class SeoVisibilityGauge extends StatelessWidget {
  const SeoVisibilityGauge({super.key, required this.score, this.size = 132});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final pct = score.clamp(0, 100).toDouble();
    final color = pct >= 70
        ? SeoColors.emerald
        : pct >= 40
        ? SeoColors.amber
        : SeoColors.rose;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: pct),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: value / 100,
              color: color,
              track: p.border,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.round().toString(),
                    style: TextStyle(
                      color: p.text,
                      fontSize: size * .26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'VISIBILITY',
                    style: TextStyle(
                      color: p.subText,
                      fontSize: 9.5,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);

    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(arc, 0, math.pi * 2, false, base);

    if (value <= 0) return;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * value, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

// ============================================================
// CREDITS (AppBar)
// ============================================================

class SeoCreditsChip extends StatelessWidget {
  const SeoCreditsChip({
    super.key,
    required this.balance,
    required this.pricing,
    required this.lowAt,
  });

  /// null = pata nahi
  final int? balance;
  final SeoTokenPricing pricing;

  /// Isse kam ho to peela (ek kaam ke liye bhi nahi)
  final int lowAt;

  @override
  Widget build(BuildContext context) {
    final b = balance;
    final color = b == null
        ? SeoColors.indigo
        : b == 0
        ? SeoColors.rose
        : b < lowAt
        ? SeoColors.amber
        : SeoColors.indigo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: 'View credits & pricing',
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showPricing(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: .35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.toll_outlined, size: 16, color: color),
                const SizedBox(width: 5),
                Text(
                  b == null ? '…' : SeoFormat.number(b),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPricing(BuildContext context) {
    final p = SettingPalette(context);

    Widget row(IconData icon, String title, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: SeoColors.indigo),
      title: Text(title, style: TextStyle(color: p.text)),
      trailing: Text(
        value,
        style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
      ),
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: p.card,
        title: Row(
          children: [
            const Icon(Icons.toll_outlined, color: SeoColors.indigo),
            const SizedBox(width: 8),
            Text('SEO Credits', style: TextStyle(color: p.text)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                balance == null
                    ? 'Balance not available right now.'
                    : 'You have ${SeoFormat.number(balance)} credits left.',
                style: TextStyle(color: p.subText),
              ),
              const SizedBox(height: 10),
              row(
                Icons.location_on_outlined,
                'Local keyword (add / refresh)',
                '${pricing.localPerKeyword}',
              ),
              row(
                Icons.public,
                'Website keyword (India)',
                '${SeoTokenPricing.websiteFor('IN')}',
              ),
              row(
                Icons.travel_explore,
                'Website keyword (other countries)',
                '${SeoTokenPricing.websiteFor('US')}',
              ),
              row(
                Icons.grid_on,
                'Map coverage re-scan',
                '${pricing.geoGridScan}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// KHALI / ERROR / LOADING
// ============================================================

class SeoEmptyState extends StatelessWidget {
  const SeoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.subText, fontSize: 13),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: seoButton(color),
              onPressed: onPressed,
              icon: const Icon(Icons.add, size: 18),
              label: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class SeoErrorState extends StatelessWidget {
  const SeoErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SeoEmptyState(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load SEO data",
          message: 'Please check your internet and try again.',
          color: SeoColors.rose,
          buttonLabel: 'Try again',
          onPressed: onRetry,
        ),
      ),
    );
  }
}

/// Barabar chaudai ke dabbe (phone 2, tablet/window 4)
class SeoGrid extends StatelessWidget {
  const SeoGrid({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 12,
  });

  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class SeoShimmer extends StatelessWidget {
  const SeoShimmer({super.key, required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget block(double h) => Container(
      height: h,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: Column(
        children: [
          block(84),
          const SizedBox(height: 12),
          block(220),
          const SizedBox(height: 12),
          SeoGrid(
            columns: columns,
            children: List.generate(4, (_) => block(86)),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < 4; i++) ...[block(64), const SizedBox(height: 8)],
        ],
      ),
    );
  }
}

/// Rangeen chhota button (Row me bhi chalta hai)
ButtonStyle seoButton(Color color) => ElevatedButton.styleFrom(
  backgroundColor: color,
  foregroundColor: Colors.white,
  minimumSize: const Size(0, 42),
  padding: const EdgeInsets.symmetric(horizontal: 18),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
);

/// Dabbe ke andar wala halka button
ButtonStyle seoOutlineButton(BuildContext context) {
  final p = SettingPalette(context);
  return OutlinedButton.styleFrom(
    foregroundColor: p.text,
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    side: BorderSide(color: p.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

/// "Stop tracking?" puchh kar haan/naa
Future<bool> confirmSeoDelete(BuildContext context, String keyword) async {
  final p = SettingPalette(context);

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: p.card,
      title: Text('Stop tracking?', style: TextStyle(color: p.text)),
      content: Text(
        '"$keyword" will be removed from your tracked keywords.',
        style: TextStyle(color: p.subText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: seoButton(SeoColors.rose),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );

  return ok ?? false;
}
