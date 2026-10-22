// ============================================================
// BUSINESS PROFILE CARD
//
// The "WhatsApp Business Profile" card. It has two modes:
//
//   View mode (_ProfileView)  : about, email, address ... read only
//   Edit mode (_ProfileForm)  : the same things in text fields + Save / Cancel
//
// Pressing "Edit" sets controller.isEditingProfile to true and shows the form.
// On Save, controller.saveBusinessProfile() calls the API.
// ============================================================

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';
import '../../models/whatsapp_account_info.dart';

class WhatsappBusinessProfileCard extends StatelessWidget {
  const WhatsappBusinessProfileCard({super.key, required this.controller});

  final WhatsappSettingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SettingSectionCard(
      child: Obx(() {
        final info = controller.info.value;
        final isEditing = controller.isEditingProfile.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Title + Edit button ----------
            Row(
              children: [
                Expanded(
                  child: Text(
                    'WhatsApp Business Profile',
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isEditing)
                  TextButton.icon(
                    onPressed: controller.startEditingProfile,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            if (isEditing)
              _ProfileForm(info: info, controller: controller)
            else
              _ProfileView(info: info),
          ],
        );
      }),
    );
  }
}

// ============================================================
// VIEW MODE
// ============================================================

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.info});

  final WhatsappAccountInfo info;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget item(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: p.subText, fontSize: 10.5)),
            const SizedBox(height: 1),
            SelectableText(
              value,
              style: TextStyle(color: p.text, fontSize: 12.5),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item('About', info.about),
              item('Email', info.email),
              item('Address', info.address),
              item('Industry', info.industry),
              item(
                'Website',
                info.websites.isEmpty ? '-' : info.websites.join('\n'),
              ),
              item('Platform', 'WhatsApp'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 24,
          backgroundColor: p.primary.withValues(alpha: 0.15),
          foregroundImage: info.profilePicture.startsWith('http')
              ? NetworkImage(info.profilePicture)
              : null,
          child: Icon(Icons.storefront_outlined, color: p.primary),
        ),
      ],
    );
  }
}

// ============================================================
// EDIT MODE
// ============================================================

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.info, required this.controller});

  final WhatsappAccountInfo info;
  final WhatsappSettingController controller;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  /// WhatsApp accepts only these industries (verticals)
  static const List<String> _industries = [
    'UNDEFINED',
    'OTHER',
    'AUTO',
    'BEAUTY',
    'APPAREL',
    'EDU',
    'ENTERTAIN',
    'EVENT_PLAN',
    'FINANCE',
    'GROCERY',
    'GOVT',
    'HOTEL',
    'HEALTH',
    'NONPROFIT',
    'PROF_SERVICES',
    'RETAIL',
    'TRAVEL',
    'RESTAURANT',
    'NOT_A_BIZ',
  ];

  // When the form opens, the old value is filled into the field ('-' = empty)
  late final TextEditingController _about = _field(widget.info.about);
  late final TextEditingController _email = _field(widget.info.email);
  late final TextEditingController _address = _field(widget.info.address);

  // WhatsApp allows up to two websites
  late final TextEditingController _website1 = _field(_websiteAt(0));
  late final TextEditingController _website2 = _field(_websiteAt(1));

  /// Newly picked profile photo (null = keep the old one)
  String? _photoPath;

  Future<void> _pickPhoto() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    final path = file?.path;
    if (file == null || path == null) return;

    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (size > 5 * 1024 * 1024) {
      Get.snackbar(
        'Image too large',
        'Profile photo should be less than 5MB.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _photoPath = path);
  }

  late String _industry = _industries.contains(widget.info.industry)
      ? widget.info.industry
      : 'UNDEFINED';

  TextEditingController _field(String value) {
    return TextEditingController(text: value == '-' ? '' : value);
  }

  String _websiteAt(int index) {
    final websites = widget.info.websites;

    return index < websites.length ? websites[index] : '';
  }

  @override
  void dispose() {
    _about.dispose();
    _email.dispose();
    _address.dispose();
    _website1.dispose();
    _website2.dispose();

    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();

    widget.controller.saveBusinessProfile(
      about: _about.text,
      email: _email.text,
      address: _address.text,
      industry: _industry,
      websites: [_website1.text, _website2.text],
      photoPath: _photoPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final controller = widget.controller;

    Widget label(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(text, style: TextStyle(color: p.subText, fontSize: 11)),
      );
    }

    Widget input(
      TextEditingController field, {
      String? hint,
      int maxLines = 1,
      int? maxLength,
      TextInputType? keyboard,
    }) {
      return TextField(
        controller: field,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboard,
        style: TextStyle(color: p.text, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          counterText: '', // Do not show the "12/139" counter
        ),
      );
    }

    return Obx(() {
      final isSaving = controller.isSavingProfile.value;
      final error = controller.profileError.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Photo (tap = change) ----------
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(44),
              onTap: isSaving ? null : _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: p.primary.withValues(alpha: 0.15),
                    foregroundImage: _photoPath != null
                        ? FileImage(File(_photoPath!))
                        : widget.info.profilePicture.startsWith('http')
                        ? NetworkImage(widget.info.profilePicture)
                        : null,
                    child: Icon(Icons.storefront_outlined, color: p.primary),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: p.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _photoPath == null
                    ? 'Tap to change photo (max 5MB)'
                    : 'New photo selected',
                style: TextStyle(color: p.subText, fontSize: 11),
              ),
            ),
          ),
          label('About'),
          input(_about, hint: 'About your business', maxLength: 139),

          label('Email'),
          input(
            _email,
            hint: 'name@example.com',
            keyboard: TextInputType.emailAddress,
          ),

          label('Address'),
          input(_address, hint: 'Business address', maxLines: 2),

          label('Industry'),
          DropdownButtonFormField<String>(
            initialValue: _industry,
            isExpanded: true,
            isDense: true,
            dropdownColor: p.card,
            style: TextStyle(color: p.text, fontSize: 13),
            decoration: const InputDecoration(isDense: true),
            items: [
              for (final industry in _industries)
                DropdownMenuItem(value: industry, child: Text(industry)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _industry = value);
            },
          ),

          label('Website'),
          input(
            _website1,
            hint: 'https://www.yourhotel.com/',
            keyboard: TextInputType.url,
          ),
          const SizedBox(height: 8),
          input(
            _website2,
            hint: 'Second website (optional)',
            keyboard: TextInputType.url,
          ),

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error,
              style: const TextStyle(color: TAppColors.error, fontSize: 12.5),
            ),
          ],

          const SizedBox(height: 14),

          // ---------- Cancel + Save ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: isSaving ? null : controller.cancelEditingProfile,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  foregroundColor: TAppColors.error,
                  side: const BorderSide(color: TAppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: settingSmallButton(),
                onPressed: isSaving ? null : _save,
                child: Text(isSaving ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ],
      );
    });
  }
}
