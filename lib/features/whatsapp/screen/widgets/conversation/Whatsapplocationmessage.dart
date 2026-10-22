import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappLocationMessage extends StatelessWidget {
  final dynamic location;
  final String? body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const WhatsappLocationMessage({
    super.key,
    required this.location,
    required this.body,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  static final RegExp _mapsLinkRegex = RegExp(
    r'https?://(?:www\.)?(?:maps\.google\.com/(?:maps)?\?q=|google\.com/maps/search/\?api=1&query=)'
    r'(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)',
  );

  /// A text message that is only a Google Maps link (+ a short label)
  /// is turned into a location map. null for normal text.
  static Map<String, dynamic>? parseMapsLink(String body) {
    final match = _mapsLinkRegex.firstMatch(body);
    if (match == null) return null;

    final latitude = double.tryParse(match.group(1)!);
    final longitude = double.tryParse(match.group(2)!);
    if (latitude == null || longitude == null) return null;

    // If there is long text besides the link, it is a normal message
    final rest = body.replaceFirst(match.group(0)!, '').trim();
    if (rest.contains('\n') || rest.length > 80) return null;

    var name = rest.replaceFirst('📍', '').trim();
    if (name == 'Location' || name == 'My location') name = '';

    return {'latitude': latitude, 'longitude': longitude, 'name': name};
  }

  dynamic _field(String key) {
    final l = location;
    if (l == null) return null;
    if (l is Map) return l[key];

    try {
      switch (key) {
        case 'name':
          return l.name;
        case 'address':
          return l.address;
        case 'latitude':
          return l.latitude;
        case 'longitude':
          return l.longitude;
      }
    } catch (_) {}

    return null;
  }

  String _getString(String key) => _field(key)?.toString() ?? '';

  double? _getDouble(String key) {
    final value = _field(key);
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  Future<void> _openMap(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    var opened = false;

    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open maps')),
      );
    }
  }

  // Small Google map (touch disabled — the tap belongs to the whole card).
  // liteMode: a light static map on Android, right for the chat list.
  Widget _mapPreview(double latitude, double longitude) {
    final point = LatLng(latitude, longitude);

    return IgnorePointer(
      child: GoogleMap(
        key: ValueKey('$latitude,$longitude'),
        initialCameraPosition: CameraPosition(target: point, zoom: 15),
        liteModeEnabled: true,
        markers: {
          Marker(markerId: const MarkerId('location'), position: point),
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final name = _getString('name');
    final address = _getString('address');
    final latitude = _getDouble('latitude');
    final longitude = _getDouble('longitude');

    final hasCoordinates = latitude != null && longitude != null;

    // Same colors as the text bubble (light / dark theme)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isIncoming
        ? (isDark ? TAppColors.darkCard : Colors.white)
        : (isDark ? const Color(0xff005c4b) : const Color(0xffd9fdd3));

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final linkColor = isDark
        ? const Color(0xff7fe3cf)
        : const Color(0xff00a884);

    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        margin: EdgeInsets.only(
          left: isIncoming ? 0 : 40,
          right: isIncoming ? 40 : 0,
          top: 3,
          bottom: 3,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: hasCoordinates
              ? () => _openMap(context, latitude, longitude)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: hasCoordinates
                    ? _mapPreview(latitude, longitude)
                    : Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.map_outlined,
                          size: 65,
                          color: Colors.grey.shade600,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    if (address.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ),
                    if (hasCoordinates)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          '$latitude, $longitude',
                          style: TextStyle(
                            fontSize: 10,
                            color: subTextColor,
                          ),
                        ),
                      ),
                    if (hasCoordinates)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Tap to open in Maps',
                          style: TextStyle(
                            fontSize: 12,
                            color: linkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: WhatsappMessageTime(
                        createdAt: createdAt,
                        status: status,
                        isIncoming: isIncoming,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}