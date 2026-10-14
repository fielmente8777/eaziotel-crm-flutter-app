// ============================================================
// SEO GEO GRID  (Map Coverage)
//
// Property ke aas-paas 5x5 = 25 jagah se Google Maps par rank.
//   Grid : har point ek gol dabba (rank ke rang me). Har device par chalta
//          hai (Windows par bhi). Tap karo -> us point ka detail.
//   Map  : asli Google Map par wahi point (sirf Android / iOS).
//   Scan chal raha ho -> upar "Please wait" parda.
// ============================================================

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/seo_intelligence_response.dart';
import 'seo_common.dart';

/// Google Map sirf phone app me (Windows / web par nahi)
bool get seoMapSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

class SeoGeoGrid extends StatefulWidget {
  const SeoGeoGrid({
    super.key,
    required this.points,
    required this.size,
    required this.centerLat,
    required this.centerLng,
    required this.radiusKm,
    required this.scanning,
    this.businessName = '',
    this.area = '',
    this.lastScanned,
  });

  final List<SeoGridPoint> points;
  final int size;
  final double centerLat;
  final double centerLng;
  final int radiusKm;
  final bool scanning;
  final String businessName;
  final String area;
  final DateTime? lastScanned;

  @override
  State<SeoGeoGrid> createState() => _SeoGeoGridState();
}

class _SeoGeoGridState extends State<SeoGeoGrid> {
  bool _showMap = false;
  SeoGridPoint? _selected;

  int get _center => widget.size ~/ 2;

  bool _isCenter(SeoGridPoint p) => p.row == _center && p.col == _center;

  @override
  void didUpdateWidget(SeoGeoGrid old) {
    super.didUpdateWidget(old);
    // Naya scan aaya to purana chuna point hatao
    if (old.points != widget.points) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final hasPoints = widget.points.isNotEmpty;

    if (!hasPoints && !widget.scanning) {
      return const SeoEmptyState(
        icon: Icons.my_location,
        title: 'Geo-grid not scanned yet',
        message: 'Tap Re-scan above to run your first map coverage scan.',
        color: SeoColors.emerald,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (seoMapSupported && hasPoints) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                selectedBackgroundColor: SeoColors.emerald.withValues(
                  alpha: .15,
                ),
                selectedForegroundColor: SeoColors.emerald,
                foregroundColor: p.subText,
                side: BorderSide(color: p.border),
              ),
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.grid_view_rounded, size: 16),
                  label: Text('Grid'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.map_outlined, size: 16),
                  label: Text('Map'),
                ),
              ],
              selected: {_showMap},
              onSelectionChanged: (s) => setState(() => _showMap = s.first),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _showMap ? 900 : 440),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _showMap && hasPoints
                        ? _SeoGridMap(
                            key: const ValueKey('map'),
                            points: widget.points,
                            centerLat: widget.centerLat,
                            centerLng: widget.centerLng,
                            radiusKm: widget.radiusKm,
                            isCenter: _isCenter,
                            businessName: widget.businessName,
                          )
                        : _gridView(p),
                  ),
                  if (widget.scanning)
                    Positioned.fill(
                      child: _ScanningOverlay(count: widget.size * widget.size),
                    ),
                  if (widget.lastScanned != null && !widget.scanning)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _Badge(
                        text: 'Updated ${SeoFormat.date(widget.lastScanned)}',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _selectedDetail(p),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (final tone in SeoRankTone.gridLegend)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: tone.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tone.label,
                    style: TextStyle(color: p.subText, fontSize: 11.5),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // GRID (har device)
  // ============================================================

  Widget _gridView(SettingPalette p) {
    final n = widget.size;
    final byCell = {for (final pt in widget.points) (pt.row, pt.col): pt};

    return AspectRatio(
      key: const ValueKey('grid'),
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.inner,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final cell = box.maxWidth / n;

            return Stack(
              children: [
                // Halki lines (map jaisa ehsaas)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridLinesPainter(n: n, color: p.border),
                  ),
                ),
                for (var r = 0; r < n; r++)
                  for (var c = 0; c < n; c++)
                    Positioned(
                      left: c * cell,
                      top: r * cell,
                      width: cell,
                      height: cell,
                      child: _cell(byCell[(r, c)], r, c, cell),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cell(SeoGridPoint? point, int row, int col, double cell) {
    final center = row == _center && col == _center;
    final tone = SeoRankTone.grid(point?.rank);
    final selected = point != null && _selected == point;
    final top = point?.rank != null && point!.rank! <= 3;
    final dot =
        cell *
        (center
            ? .78
            : top
            ? .7
            : .6);
    final index = row * widget.size + col;

    return Center(
      child: TweenAnimationBuilder<double>(
        // Ek ke baad ek ubharte hain
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + index * 25),
        curve: Curves.easeOutBack,
        builder: (context, t, child) => Transform.scale(scale: t, child: child),
        child: Tooltip(
          message: point == null
              ? 'No data'
              : center
              ? '${widget.businessName.isEmpty ? 'Your property' : widget.businessName} · ${point.label}'
              : 'Rank ${point.label}',
          child: GestureDetector(
            onTap: point == null
                ? null
                : () => setState(() => _selected = selected ? null : point),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? dot * 1.12 : dot,
              height: selected ? dot * 1.12 : dot,
              decoration: BoxDecoration(
                color: point?.rank == null
                    ? tone.color.withValues(alpha: .45)
                    : tone.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: center || selected ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tone.color.withValues(alpha: selected ? .7 : .35),
                    blurRadius: selected ? 14 : 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (center)
                        const Icon(Icons.location_on, color: Colors.white),
                      Text(
                        point?.label ?? '—',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(blurRadius: 3)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedDetail(SettingPalette p) {
    final point = _selected;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: point == null
          ? Text(
              seoMapSupported
                  ? 'Tap a point to see its rank. Switch to Map for the real area.'
                  : 'Tap a point to see its rank.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 12),
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SeoRankTone.grid(point.rank).color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SeoRankTone.grid(
                    point.rank,
                  ).color.withValues(alpha: .35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCenter(point) ? Icons.location_on : Icons.place_outlined,
                    color: SeoRankTone.grid(point.rank).color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCenter(point)
                              ? (widget.businessName.isEmpty
                                    ? 'Your property'
                                    : widget.businessName)
                              : point.rank == null
                              ? 'Not ranked here'
                              : 'Rank ${point.label} on Google Maps',
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_isCenter(point) && widget.area.isNotEmpty ? '${widget.area} · ' : ''}'
                          'Row ${point.row + 1}, Col ${point.col + 1} · '
                          '${point.lat.toStringAsFixed(4)}, '
                          '${point.lng.toStringAsFixed(4)}',
                          style: TextStyle(color: p.subText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _selected = null),
                    icon: Icon(Icons.close, size: 18, color: p.subText),
                  ),
                ],
              ),
            ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  _GridLinesPainter({required this.n, required this.color});

  final int n;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .6)
      ..strokeWidth = 1;
    final step = size.width / n;

    for (var i = 0; i < n; i++) {
      final c = step * i + step / 2;
      canvas.drawLine(
        Offset(c, step / 2),
        Offset(c, size.height - step / 2),
        paint,
      );
      canvas.drawLine(
        Offset(step / 2, c),
        Offset(size.width - step / 2, c),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridLinesPainter old) => old.n != n || old.color != color;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ScanningOverlay extends StatelessWidget {
  const _ScanningOverlay({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF090B14).withValues(alpha: .82),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SeoSpin(
            child: Icon(Icons.radar, size: 42, color: Color(0xFF00D4AA)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please wait',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scanning geo-grid across all $count points.\n'
            'This takes a few minutes.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAP (sirf Android / iOS)
// ============================================================

class _SeoGridMap extends StatefulWidget {
  const _SeoGridMap({
    super.key,
    required this.points,
    required this.centerLat,
    required this.centerLng,
    required this.radiusKm,
    required this.isCenter,
    required this.businessName,
  });

  final List<SeoGridPoint> points;
  final double centerLat;
  final double centerLng;
  final int radiusKm;
  final bool Function(SeoGridPoint) isCenter;
  final String businessName;

  @override
  State<_SeoGridMap> createState() => _SeoGridMapState();
}

class _SeoGridMapState extends State<_SeoGridMap> {
  final Map<String, BitmapDescriptor> _icons = {};

  @override
  void initState() {
    super.initState();
    _buildIcons();
  }

  @override
  void didUpdateWidget(_SeoGridMap old) {
    super.didUpdateWidget(old);
    if (old.points != widget.points) _buildIcons();
  }

  /// Har point ka gol icon (rang + "#4" likha hua)
  Future<void> _buildIcons() async {
    for (final point in widget.points) {
      final center = widget.isCenter(point);
      final key = '${point.label}-$center';
      if (_icons.containsKey(key)) continue;

      _icons[key] = await _markerIcon(
        label: point.label,
        color: SeoRankTone.grid(point.rank).color,
        center: center,
      );
    }
    if (mounted) setState(() {});
  }

  static Future<BitmapDescriptor> _markerIcon({
    required String label,
    required Color color,
    required bool center,
  }) async {
    final size = center ? 120.0 : 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final c = Offset(size / 2, size / 2);
    final r = size / 2 - 6;

    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = center ? 9 : 6,
    );

    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: label.length > 3 ? 26 : 32,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, c - Offset(text.width / 2, text.height / 2));

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: center ? 44 : 34,
    );
  }

  double get _zoom => switch (widget.radiusKm) {
    <= 2 => 14,
    <= 5 => 12.6,
    _ => 11.6,
  };

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      for (final point in widget.points)
        Marker(
          markerId: MarkerId('${point.row}-${point.col}'),
          position: LatLng(point.lat, point.lng),
          anchor: const Offset(.5, .5),
          zIndexInt: widget.isCenter(point) ? 2 : 1,
          icon:
              _icons['${point.label}-${widget.isCenter(point)}'] ??
              BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: widget.isCenter(point)
                ? (widget.businessName.isEmpty
                      ? 'Your property'
                      : widget.businessName)
                : 'Rank ${point.label}',
            snippet: 'Row ${point.row + 1}, Col ${point.col + 1}',
          ),
        ),
    };

    return SizedBox(
      height: 420,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.centerLat, widget.centerLng),
          zoom: _zoom,
        ),
        markers: markers,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        // Page scroll ke andar bhi map ghoome
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }
}
