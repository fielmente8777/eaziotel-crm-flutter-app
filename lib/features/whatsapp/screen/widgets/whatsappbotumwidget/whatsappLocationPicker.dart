import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Map: Google Maps. API key AndroidManifest.xml (aur iOS AppDelegate) me hai.
// Place search: OpenStreetMap Nominatim (key nahi chahiye).
const String _searchUserAgent = 'com.eazotel.app';

// ============================================================
// PICKED LOCATION
// ============================================================

class PickedLocation {
  final double latitude;
  final double longitude;

  /// Search se chuni jagah ka naam (map haath se hilaya ho to khali)
  final String name;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.name = '',
  });
}

class _SearchResult {
  final String name;
  final String address;
  final LatLng point;

  const _SearchResult({
    required this.name,
    required this.address,
    required this.point,
  });
}

// ============================================================
// LOCATION PICKER SCREEN
// ============================================================

/// Map par pin ke neeche wali jagah chuno aur Send dabao.
/// Navigator.pop se [PickedLocation] milta hai (back par null).
class WhatsappLocationPicker extends StatefulWidget {
  const WhatsappLocationPicker({super.key});

  @override
  State<WhatsappLocationPicker> createState() => _WhatsappLocationPickerState();
}

class _WhatsappLocationPickerState extends State<WhatsappLocationPicker> {
  // GPS na mile to India ka center
  static const LatLng _fallbackCenter = LatLng(20.5937, 78.9629);
  static const double _fallbackZoom = 4.5;
  static const double _pickZoom = 16;

  GoogleMapController? _mapController;

  // Camera chalte waqt ka center (rukne par _center me jata hai)
  LatLng _cameraTarget = _fallbackCenter;

  // Search se chuni jagah (naam tabhi tak rehta hai jab tak pin yahin ho)
  LatLng? _namedPoint;

  // Permission mili ho to map par blue dot dikhao
  bool _showMyLocation = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Dio _dio = Dio();

  LatLng _center = _fallbackCenter;
  String _placeName = '';

  bool _locating = false;
  bool _searching = false;

  List<_SearchResult> _results = [];

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _dio.close();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  /// [silent] true ho to permission/GPS ki dikkat par message nahi dikhata
  /// (screen khulte hi apne aap chalta hai).
  Future<void> _goToCurrentLocation({bool silent = false}) async {
    if (_locating) return;

    setState(() => _locating = true);

    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();

      if (!serviceOn) {
        if (!silent) _showSnack('Please turn on GPS');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent) _showSnack('Location permission is required');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() => _showMyLocation = true);

      _moveTo(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint('LOCATION PICKER ERROR: $e');
      if (!silent) _showSnack('Unable to get your location');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _moveTo(LatLng point, {String name = ''}) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(point, _pickZoom),
    );

    setState(() {
      _center = point;
      _placeName = name;
      _namedPoint = name.isEmpty ? null : point;
    });
  }

  // Camera rukne par pin ke neeche wali jagah final karo
  void _onCameraIdle() {
    final named = _namedPoint;

    // Haath se hilaya to search wala naam hata do
    final movedAway = named != null &&
        ((named.latitude - _cameraTarget.latitude).abs() > 0.0003 ||
            (named.longitude - _cameraTarget.longitude).abs() > 0.0003);

    setState(() {
      _center = _cameraTarget;

      if (movedAway) {
        _placeName = '';
        _namedPoint = null;
      }
    });
  }
  // ============================================================
  // SEARCH (OpenStreetMap Nominatim)
  // ============================================================

  Future<void> _search() async {
    final query = _searchController.text.trim();

    if (query.isEmpty || _searching) return;

    _searchFocus.unfocus();

    setState(() => _searching = true);

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': query, 'format': 'json', 'limit': 6},
        options: Options(headers: {'User-Agent': _searchUserAgent}),
      );

      final results = <_SearchResult>[];

      for (final item in (response.data as List? ?? [])) {
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');

        if (lat == null || lon == null) continue;

        final address = item['display_name']?.toString() ?? '';

        results.add(
          _SearchResult(
            name: item['name']?.toString().isNotEmpty == true
                ? item['name'].toString()
                : address.split(',').first.trim(),
            address: address,
            point: LatLng(lat, lon),
          ),
        );
      }

      if (!mounted) return;

      setState(() => _results = results);

      if (results.isEmpty) _showSnack('No place found');
    } catch (e) {
      debugPrint('LOCATION SEARCH ERROR: $e');
      _showSnack('Search failed. Please try again.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectResult(_SearchResult result) {
    _searchController.text = result.name;

    setState(() => _results = []);

    _moveTo(result.point, name: result.name);
  }

  // ============================================================
  // SEND
  // ============================================================

  void _send() {
    Navigator.of(context).pop(
      PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        name: _placeName,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Send location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _fallbackCenter,
                    zoom: _fallbackZoom,
                  ),
                  myLocationEnabled: _showMyLocation,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  onMapCreated: (mapController) {
                    _mapController = mapController;
                    _goToCurrentLocation(silent: true);
                  },
                  onCameraMove: (position) => _cameraTarget = position.target,
                  onCameraIdle: _onCameraIdle,
                ),
                // Center pin (nok map ke center par)
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 44),
                      child: Icon(
                        Icons.location_pin,
                        size: 44,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _buildSearch(theme),
                ),

                Positioned(
                  right: 12,
                  bottom: 36,
                  child: FloatingActionButton.small(
                    heroTag: 'location_picker_my_location',
                    onPressed: _locating ? null : _goToCurrentLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BOX + RESULTS
  // ============================================================

  Widget _buildSearch(ThemeData theme) {
    return Material(
      elevation: 3,
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search a place',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _search,
                    ),
            ),
          ),
          if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _results[index];

                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      result.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      result.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectResult(result),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar(ThemeData theme) {
    final coordinates =
        '${_center.latitude.toStringAsFixed(6)}, '
        '${_center.longitude.toStringAsFixed(6)}';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _placeName.isEmpty ? 'Selected location' : _placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coordinates,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _send,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff00a884),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
