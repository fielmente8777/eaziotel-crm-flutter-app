import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_setting_controller.dart';
import '../../../screen/widgets/setting_section_card.dart';

class SettingPasswordCard extends StatelessWidget {
  const SettingPasswordCard({super.key, required this.controller});

  final ProfileSettingController controller;

  @override
  Widget build(BuildContext context) {
    return SettingSectionCard(
      icon: Icons.key_rounded,
      title: 'Change Password',
      subtitle: 'Set a new password for your account.',
      // On big screens the field should not take the full width
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PasswordField(
              label: 'Current Password',
              hint: 'Enter your current password',
              controller: controller.currentPassword,
            ),
            _PasswordField(
              label: 'New Password',
              hint: 'Enter your new password',
              controller: controller.newPassword,
            ),
            _PasswordField(
              label: 'Re-enter Password',
              hint: 'Enter your re-enter password',
              controller: controller.confirmPassword,
              onSubmitted: controller.changePassword,
            ),
            Obx(() {
              final error = controller.passwordError.value;

              if (error == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  error,
                  style: const TextStyle(
                    color: TAppColors.error,
                    fontSize: 12.5,
                  ),
                ),
              );
            }),
            Obx(() {
              final saving = controller.isChangingPassword.value;

              return ElevatedButton(
                style: settingSmallButton(),
                onPressed: saving ? null : controller.changePassword,
                child: Text(saving ? 'Saving...' : 'Confirm'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: p.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.controller,
            obscureText: !_visible,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: widget.onSubmitted == null
                ? TextInputAction.next
                : TextInputAction.done,
            style: TextStyle(color: p.text, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: widget.hint,
              isDense: true,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: p.subText,
                ),
              ),
            ),
            onSubmitted: (_) => widget.onSubmitted?.call(),
          ),
        ],
      ),
    );
  }
}
