// ============================================================
// LOCATIONS CARD  (Settings > Profile)   web dashboard jaisa
//
//   Locations · 3                                  [+ Add location]
//   Each location has its own website, bookings and leads.
//   ┌──────────────────────┐ ┌──────────────────────┐
//   │ 📍 Pouchanki [Current]│ │ 📍 Georgpool     ✎ 🗑 │  <- tap = isi
//   │ Charkhi Dadri, Haryana│ │ South Delhi, India   │     location par
//   └──────────────────────┘ └──────────────────────┘     switch
//
// Add / edit / delete sirf admin. Abhi wali location delete nahi hoti.
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_setting_controller.dart';
import '../../../screen/widgets/setting_section_card.dart';

class SettingHotelsCard extends StatelessWidget {
  const SettingHotelsCard({
    super.key,
    required this.controller,
    required this.r,
  });

  final ProfileSettingController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final hotels = controller.hotels.toList();
      final currentId = controller.currentHotelId;
      final canManage = controller.canManageHotels;

      // Phone 1, tablet 2, window 3 column
      final columns = r.value(phone: 1, tablet: 2, desktop: 3);
      const spacing = 10.0;

      return SettingSectionCard(
        icon: Icons.apartment_rounded,
        title: 'Locations · ${hotels.length}',
        subtitle: 'Each location has its own website, bookings and leads.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canManage)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => HotelFormDialog.open(controller),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add location'),
                ),
              ),
            if (canManage) const SizedBox(height: 10),
            if (hotels.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(Icons.apartment_rounded, size: 34, color: p.subText),
                    const SizedBox(height: 6),
                    Text(
                      'No locations yet.',
                      style: TextStyle(color: p.subText, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, box) {
                  final width =
                      (box.maxWidth - spacing * (columns - 1)) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final hotel in hotels)
                        SizedBox(
                          width: width,
                          child: _HotelTile(
                            hotel: hotel,
                            current: hotel.hotelId == currentId,
                            deleting:
                                controller.deletingHotelId.value ==
                                hotel.hotelId,
                            canManage: canManage,
                            controller: controller,
                          ),
                        ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 8),
            Text(
              'Tap a location to switch the whole app to it.',
              style: TextStyle(color: p.subText, fontSize: 11.5),
            ),
          ],
        ),
      );
    });
  }
}

class _HotelTile extends StatelessWidget {
  const _HotelTile({
    required this.hotel,
    required this.current,
    required this.deleting,
    required this.canManage,
    required this.controller,
  });

  final HotelModel hotel;
  final bool current;
  final bool deleting;
  final bool canManage;
  final ProfileSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final address = [
      hotel.city,
      hotel.state,
      hotel.country,
    ].where((e) => e.trim().isNotEmpty).join(', ');

    return Material(
      color: current ? p.primary.withValues(alpha: .08) : p.inner,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: current || deleting ? null : () => controller.switchHotel(hotel),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: current ? p.primary.withValues(alpha: .5) : p.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: current ? p.primary : p.subText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hotel.local.trim().isEmpty ? 'Hotel' : hotel.local,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (current) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.primary.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Current',
                              style: TextStyle(
                                color: p.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (address.isNotEmpty)
                      Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.subText, fontSize: 12),
                      ),
                    if (hotel.pinCode.trim().isNotEmpty)
                      Text(
                        'PIN ${hotel.pinCode}',
                        style: TextStyle(color: p.subText, fontSize: 11),
                      ),
                  ],
                ),
              ),
              if (canManage) ...[
                IconButton(
                  tooltip: 'Edit ${hotel.local}',
                  visualDensity: VisualDensity.compact,
                  onPressed: deleting
                      ? null
                      : () => HotelFormDialog.open(controller, hotel: hotel),
                  icon: Icon(Icons.edit_outlined, size: 18, color: p.subText),
                ),
                IconButton(
                  tooltip: current
                      ? "You can't remove the location you're using"
                      : 'Remove ${hotel.local}',
                  visualDensity: VisualDensity.compact,
                  onPressed: current || deleting
                      ? null
                      : () => controller.deleteHotel(hotel),
                  icon: Icon(
                    deleting
                        ? Icons.hourglass_top_rounded
                        : Icons.delete_outline,
                    size: 18,
                    color: current
                        ? p.subText.withValues(alpha: .4)
                        : TAppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADD / EDIT FORM (dialog)
//   Name *  |  City  State  |  Country  PIN code
// ============================================================

class HotelFormDialog extends StatefulWidget {
  const HotelFormDialog({super.key, required this.controller, this.hotel});

  final ProfileSettingController controller;

  /// null = naya, warna isi ko badlo
  final HotelModel? hotel;

  static Future<void> open(
    ProfileSettingController controller, {
    HotelModel? hotel,
  }) => Get.dialog<void>(
    HotelFormDialog(controller: controller, hotel: hotel),
    barrierDismissible: false,
  );

  @override
  State<HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<HotelFormDialog> {
  late final Map<String, TextEditingController> _fields = {
    'local': TextEditingController(text: widget.hotel?.local ?? ''),
    'city': TextEditingController(text: widget.hotel?.city ?? ''),
    'state': TextEditingController(text: widget.hotel?.state ?? ''),
    'country': TextEditingController(text: widget.hotel?.country ?? ''),
    'pinCode': TextEditingController(text: widget.hotel?.pinCode ?? ''),
  };

  bool _submitted = false;

  bool get _adding => widget.hotel == null;

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (_fields['local']!.text.trim().isEmpty) return;

    final ok = await widget.controller.saveHotel(widget.hotel, {
      for (final e in _fields.entries) e.key: e.value.text,
    });
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final nameMissing = _submitted && _fields['local']!.text.trim().isEmpty;

    Widget field(
      String key,
      String label,
      String hint, {
      TextInputType? keyboard,
      bool autofocus = false,
      String? error,
    }) => TextField(
      controller: _fields[key],
      autofocus: autofocus,
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      onChanged: key == 'local' ? (_) => setState(() {}) : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        isDense: true,
      ),
    );

    Widget pair(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );

    return AlertDialog(
      backgroundColor: p.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Expanded(child: Text(_adding ? 'Add location' : 'Edit location')),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _adding
                    ? 'A new property under this account. It appears in the '
                          'location switcher once added.'
                    : 'Update the details of this location.',
                style: TextStyle(color: p.subText, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              field(
                'local',
                'Name *',
                'e.g. Lake View Resort, Udaipur',
                autofocus: true,
                error: nameMissing ? "Enter the location's name." : null,
              ),
              const SizedBox(height: 12),
              pair(
                field('city', 'City', 'e.g. Udaipur'),
                field('state', 'State', 'e.g. Rajasthan'),
              ),
              const SizedBox(height: 12),
              pair(
                field('country', 'Country', 'e.g. India'),
                field(
                  'pinCode',
                  'PIN code',
                  'e.g. 313001',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Obx(() {
          final saving = widget.controller.isSavingHotel.value;

          return FilledButton.icon(
            onPressed: saving ? null : _save,
            icon: Icon(
              saving ? Icons.hourglass_top_rounded : Icons.check_rounded,
              size: 18,
            ),
            label: Text(
              saving
                  ? 'Saving…'
                  : _adding
                  ? 'Add location'
                  : 'Save changes',
            ),
          );
        }),
      ],
    );
  }
}
