import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_setting_controller.dart';
import '../../../screen/widgets/setting_section_card.dart';

/// User / organization / contact wala upar ka card
class SettingProfileCard extends StatelessWidget {
  const SettingProfileCard({
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
      child: Obx(() {
        final user = controller.currentUser;
        final profile = controller.profile;

        String show(String? value) {
          final text = value?.trim() ?? '';
          return text.isEmpty || text == 'None' ? '-' : text;
        }

        final name = show(user?.displayName);
        final role = show(user?.role);

        final userBlock = Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: p.primary.withValues(alpha: 0.15),
              child: Text(
                name == '-' ? 'U' : name[0].toUpperCase(),
                style: TextStyle(
                  color: p.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Role: ${role == '-' ? '-' : role.capitalizeFirst}',
                    style: TextStyle(color: p.subText, fontSize: 12),
                  ),
                  Text(
                    show(user?.email),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.subText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );

        final organization = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization',
              style: TextStyle(color: p.primary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              show(profile?.hotelName),
              style: TextStyle(
                color: p.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              show(profile?.hotelDescription),
              style: TextStyle(color: p.subText, fontSize: 12),
            ),
          ],
        );

        Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(color: p.primary),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: p.text),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 12.5),
          ),
        );

        final contact = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            line('Domain', show(profile?.domain)),
            line('Email', show(profile?.hotelEmail)),
            line('Phone', show(profile?.hotelPhone)),
          ],
        );

        // Phone: ek ke neeche ek. Tablet / window: teen column.
        if (r.isPhone) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userBlock,
              Divider(height: 28, color: p.border),
              organization,
              const SizedBox(height: 14),
              contact,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: userBlock),
            const SizedBox(width: 16),
            Expanded(child: organization),
            const SizedBox(width: 16),
            Expanded(child: contact),
          ],
        );
      }),
    );
  }
}
