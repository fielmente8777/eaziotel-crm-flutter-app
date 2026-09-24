import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final name = _getString('name');
    final address = _getString('address');
    final latitude = _getDouble('latitude');
    final longitude = _getDouble('longitude');

    final hasCoordinates = latitude != null && longitude != null;

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
          color: isIncoming
              ? Theme.of(context).cardColor
              : const Color(0xffd9fdd3),
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
              Container(
                height: 170,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 65,
                      color: Colors.grey.shade600,
                    ),
                    const Icon(Icons.location_pin, size: 42, color: Colors.red),
                  ],
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (address.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    if (hasCoordinates)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Tap to open in Maps',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff00a884),
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