// lib/features/googleAnalytis/screen/widgets/geographic_section.dart

 import 'package:eazotel/features/googleAnalytis/models/geoModle.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/AnalyticsUiKit.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_palette.dart';
 import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _allCountries = '__all__';

/// Top Countries + Top Cities — both linked:
/// tap a country → the cities card shows that country
class GeographicSection extends StatefulWidget {
  final GeoModel? data;
  final AnalyticsLayout layout;
  final bool isLoading;

  const GeographicSection({
    super.key,
    required this.data,
    required this.layout,
    this.isLoading = false,
  });

  @override
  State<GeographicSection> createState() => _GeographicSectionState();
}

class _GeographicSectionState extends State<GeographicSection> {
  String? _country; // cities filter

  List<GeoCountry> get _countries {
    final list = [...?widget.data?.countries]
      ..sort((a, b) => b.users.compareTo(a.users));
    return list;
  }

  /// In the order of the countries list, then the ones only in cities
  List<String> get _cityCountries {
    final cities = widget.data?.cities ?? const [];
    final names = <String>[
      for (final c in _countries)
        if (cities.any((x) => x.country == c.country)) c.country,
    ];
    for (final c in cities) {
      if (!names.contains(c.country)) names.add(c.country);
    }
    return names;
  }

  String get _effectiveCountry {
    final opts = _cityCountries;
    if (_country != null &&
        (_country == _allCountries || opts.contains(_country))) {
      return _country!;
    }
    return opts.isNotEmpty ? opts.first : _allCountries;
  }

  @override
  void didUpdateWidget(covariant GeographicSection old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _country = null;
  }

  void _pick(String country) => setState(() => _country = country);

  @override
  Widget build(BuildContext context) {
    final l = widget.layout;
    final countriesCard = _TopCountriesCard(
      countries: _countries,
      selected: _effectiveCountry,
      onSelect: _pick,
      layout: l,
      isLoading: widget.isLoading,
    );
    final citiesCard = _TopCitiesCard(
      cities: widget.data?.cities ?? const [],
      countryOptions: _cityCountries,
      selected: _effectiveCountry,
      onChange: _pick,
      layout: l,
      isLoading: widget.isLoading,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Geographic Insights',
          subtitle: 'Where your visitors come from',
          layout: l,
          accent: const [Color(0xFF06B6D4), Color(0xFF6366F1)],
        ),
        SizedBox(height: l.isPhone ? 12 : 16),
        LayoutBuilder(
          builder: (context, box) {
            final gap = l.gap + 4;
            if (box.maxWidth >= 860) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 400),
                      child: countriesCard,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 400),
                      child: citiesCard,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [countriesCard, SizedBox(height: gap), citiesCard],
            );
          },
        ),
      ],
    );
  }
}

// ===================================================================
// TOP COUNTRIES
// ===================================================================

class _TopCountriesCard extends StatefulWidget {
  final List<GeoCountry> countries;
  final String selected;
  final ValueChanged<String> onSelect;
  final AnalyticsLayout layout;
  final bool isLoading;

  const _TopCountriesCard({
    required this.countries,
    required this.selected,
    required this.onSelect,
    required this.layout,
    required this.isLoading,
  });

  @override
  State<_TopCountriesCard> createState() => _TopCountriesCardState();
}

class _TopCountriesCardState extends State<_TopCountriesCard> {
  String? _hover;
  final _fmt = NumberFormat.decimalPattern();

  void _setHover(String? k) {
    if (_hover == k) return;
    setState(() => _hover = k);
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final countries = widget.countries;
    final total = countries.fold<int>(0, (s, e) => s + e.users);

    return AnalyticsShell(
      title: 'Top Countries',
      accent: const Color(0xFF6366F1),
      icon: Icons.public,
      layout: widget.layout,
      trailing: total == 0 || widget.isLoading
          ? null
          : _chip(c, '${countries.length} countries'),
      child: widget.isLoading
          ? analyticsLoader()
          : total == 0
              ? analyticsEmpty(c)
              : Column(
                  children: [
                    for (int i = 0; i < countries.length; i++)
                      _row(c, i, countries[i], total),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.touch_app_outlined,
                            size: 13, color: c.subText),
                        const SizedBox(width: 5),
                        Text(
                          'Tap a country to see its cities',
                          style: TextStyle(color: c.subText, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _row(AnalyticsPalette c, int i, GeoCountry it, int total) {
    final color = seriesColor(i);
    final isSel = widget.selected == it.country;
    final isHover = _hover == it.country;
    final dimmed = _hover != null && !isHover;
    final pct = it.users / total * 100;

    return MouseRegion(
      key: ValueKey(it.country),
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(it.country),
      onExit: (_) => _setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect(it.country),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: isSel || isHover
                  ? color.withValues(alpha: c.isDark ? 0.09 : 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSel ? color.withValues(alpha: 0.45) : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _codeBadge(it.countryCode, color, isSel || isHover),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        it.country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: widget.layout.bodyFont + 3,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSel)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.location_city,
                            size: 15, color: color),
                      ),
                    Text(
                      _fmt.format(it.users),
                      style: TextStyle(
                        color: color,
                        fontSize: widget.layout.bodyFont + 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 56,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedPercentText(
                          pct,
                          duration: Duration(milliseconds: 700 + i * 90),
                          style: TextStyle(
                            color: c.text,
                            fontSize: widget.layout.bodyFont + 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                GlowBar(
                  ratio: pct / 100,
                  color: color,
                  active: isSel || isHover,
                  index: i,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _codeBadge(String code, Color color, bool on) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? color : color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          code.isEmpty ? '—' : code,
          style: TextStyle(
            color: on ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      );
}

Widget _chip(AnalyticsPalette c, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.text.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c.subText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

// ===================================================================
// TOP CITIES
// ===================================================================

class _CityRow {
  final String label;
  final String country;
  final bool unknown;
  int users;
  _CityRow(this.label, this.country, this.unknown, this.users);
}

class _TopCitiesCard extends StatefulWidget {
  final List<GeoCity> cities;
  final List<String> countryOptions;
  final String selected;
  final ValueChanged<String> onChange;
  final AnalyticsLayout layout;
  final bool isLoading;

  const _TopCitiesCard({
    required this.cities,
    required this.countryOptions,
    required this.selected,
    required this.onChange,
    required this.layout,
    required this.isLoading,
  });

  @override
  State<_TopCitiesCard> createState() => _TopCitiesCardState();
}

class _TopCitiesCardState extends State<_TopCitiesCard>
    with HoverSelect<_TopCitiesCard, String> {
  static const _accent = Color(0xFF06B6D4);
  static const _maxRows = 8;

  final _fmt = NumberFormat.decimalPattern();

  @override
  void didUpdateWidget(covariant _TopCitiesCard old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected || old.cities != widget.cities) {
      resetHoverSelect();
    }
  }

  /// Filter + merge the same city + one bucket for unknown
  List<_CityRow> _rows() {
    final all = widget.selected == _allCountries;
    final map = <String, _CityRow>{};
    for (final c in widget.cities) {
      if (!all && c.country != widget.selected) continue;
      final key = all ? '${c.label}|${c.country}' : c.label;
      map.update(
        key,
        (r) => r..users += c.users,
        ifAbsent: () => _CityRow(c.label, c.country, c.isUnknown, c.users),
      );
    }
    final rows = map.values.toList()
      ..sort((a, b) {
        // Unknown always at the bottom
        if (a.unknown != b.unknown) return a.unknown ? 1 : -1;
        return b.users.compareTo(a.users);
      });
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final c = AnalyticsPalette.of(context);
    final rows = _rows();
    final total = rows.fold<int>(0, (s, r) => s + r.users);
    final maxV = rows.fold<int>(0, (m, r) => r.users > m ? r.users : m);
    final shown = rows.take(_maxRows).toList();

    return AnalyticsShell(
      title: 'Top Cities',
      accent: _accent,
      icon: Icons.location_on_outlined,
      layout: widget.layout,
      trailing: widget.isLoading || widget.countryOptions.isEmpty
          ? null
          : _countryDropdown(c),
      child: widget.isLoading
          ? analyticsLoader()
          : rows.isEmpty
              ? analyticsEmpty(c, 'No city data')
              : KeyedSubtree(
                  // when the country changes the bars animate from 0 again
                  key: ValueKey(widget.selected),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summary(c, rows, total),
                      const SizedBox(height: 14),
                      for (int i = 0; i < shown.length; i++)
                        _bar(c, i, shown[i], total, maxV),
                      if (rows.length > _maxRows)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '+${rows.length - _maxRows} more cities',
                            style: TextStyle(color: c.subText, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _summary(AnalyticsPalette c, List<_CityRow> rows, int total) {
    final known = rows.where((r) => !r.unknown).length;
    final label = widget.selected == _allCountries
        ? 'All countries'
        : widget.selected;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _stat(c, Icons.people_outline, '${_fmt.format(total)} users'),
        _stat(c, Icons.location_city, '$known ${known == 1 ? 'city' : 'cities'}'),
        _stat(c, Icons.flag_outlined, label),
      ],
    );
  }

  Widget _stat(AnalyticsPalette c, IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: _accent),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: c.text,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _bar(AnalyticsPalette c, int i, _CityRow r, int total, int maxV) {
    final key = '${r.label}|${r.country}';
    final color = r.unknown ? kUnknownColor : seriesColor(i);
    final isActive = activeKey == key;
    final dimmed = activeKey != null && !isActive;
    final pct = total == 0 ? 0.0 : r.users / total * 100;
    final labelW = widget.layout.isPhone ? 84.0 : 110.0;
    final all = widget.selected == _allCountries;

    return MouseRegion(
      key: ValueKey(key),
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setHover(key),
      onExit: (_) => setHover(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => toggleSelect(key),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.45 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: labelW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        r.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isActive ? color : c.subText,
                          fontSize: widget.layout.bodyFont + 1.5,
                          fontStyle:
                              r.unknown ? FontStyle.italic : FontStyle.normal,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (all)
                        Text(
                          r.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.subText.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: maxV == 0 ? 0 : (r.users / maxV).clamp(0.0, 1.0),
                    ),
                    duration: Duration(milliseconds: 700 + i * 100),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: v == 0 ? 0.001 : v,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isActive ? 28 : 24,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [darker(color, 0.3), color],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: v > 0.35
                            ? Text(
                                '${pct.toStringAsFixed(1)}%',
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  child: Text(
                    _fmt.format(r.users),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: color,
                      fontSize: widget.layout.bodyFont + 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _countryDropdown(AnalyticsPalette c) {
    final label = widget.selected == _allCountries
        ? 'All countries'
        : widget.selected;

    PopupMenuItem<String> item(String value, String text) {
      final sel = value == widget.selected;
      return PopupMenuItem<String>(
        value: value,
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: sel ? _accent : c.text,
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (sel) const Icon(Icons.check, size: 16, color: _accent),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Filter by country',
      color: c.card,
      elevation: 8,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      onSelected: widget.onChange,
      itemBuilder: (_) => [
        item(_allCountries, 'All countries'),
        const PopupMenuDivider(height: 8),
        for (final name in widget.countryOptions) item(name, name),
      ],
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.layout.isPhone ? 140 : 180,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 14, color: _accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 18, color: c.subText),
          ],
        ),
      ),
    );
  }
}