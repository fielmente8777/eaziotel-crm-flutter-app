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

    return SettingSectionCard(
      icon: Icons.apartment_rounded,
      title: 'Hotels',
      child: Obx(() {
        final hotels = controller.hotels.toList();

        if (hotels.isEmpty) {
          return Text(
            'No hotels found',
            style: TextStyle(color: p.subText, fontSize: 13),
          );
        }

        // Phone 1, tablet 2, window 3 column
        final columns = r.value(phone: 1, tablet: 2, desktop: 3);
        const spacing = 10.0;

        return LayoutBuilder(
          builder: (context, box) {
            final width = (box.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final hotel in hotels)
                  SizedBox(
                    width: width,
                    child: _HotelTile(hotel: hotel, controller: controller),
                  ),
              ],
            );
          },
        );
      }),
    );
  }
}

class _HotelTile extends StatelessWidget {
  const _HotelTile({required this.hotel, required this.controller});

  final HotelModel hotel;
  final ProfileSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final address = [
      hotel.city,
      hotel.state,
      hotel.country,
    ].where((e) => e.trim().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.local.trim().isEmpty ? 'Hotel' : hotel.local,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
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
                    'Pin: ${hotel.pinCode}',
                    style: TextStyle(color: p.subText, fontSize: 11),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            onPressed: () => controller.editHotel(hotel),
            icon: Icon(Icons.edit_outlined, size: 18, color: p.subText),
          ),
          IconButton(
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            onPressed: () => controller.deleteHotel(hotel),
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: TAppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
