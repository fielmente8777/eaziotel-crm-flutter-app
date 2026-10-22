import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/call_service.dart';

/// Own list for TESTING
final List<UserModel> _testUsers = [
  UserModel(displayName: 'Test User 1', phone: '+919225261746'),
  UserModel(displayName: 'Test User 2', phone: '+919876543210'),
];

/// "Enter Number to make a call!" dialog.
///
/// - First field (From): pick a team user; the call goes from their phone
/// - Second field (To): [number] comes pre-filled; the user can change it
///
/// "Call Now" sends POST /api/v1/call/auth/make-call?hid=..
Future<void> showMakeCallDialog(BuildContext context, {String? number}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _MakeCallDialog(number: number),
  );
}

/// "07838447555" / "7838447555" / "917838447555" -> "+917838447555"
String _formatNumber(String value) {
  final text = value.trim();
  final digits = text.replaceAll(RegExp(r'\D'), '');

  if (digits.isEmpty) return '';

  if (text.startsWith('+')) return '+$digits';
  if (digits.length == 10) return '+91$digits';
  if (digits.length == 11 && digits.startsWith('0')) {
    return '+91${digits.substring(1)}';
  }

  return '+$digits';
}

String _userName(UserModel user) {
  final display = user.displayName?.trim() ?? '';
  if (display.isNotEmpty) return display;

  final name = user.userName?.trim() ?? '';
  if (name.isNotEmpty) return name;

  return user.emailId?.trim() ?? 'User';
}

class _MakeCallDialog extends StatefulWidget {
  const _MakeCallDialog({this.number});

  final String? number;

  @override
  State<_MakeCallDialog> createState() => _MakeCallDialogState();
}

class _MakeCallDialogState extends State<_MakeCallDialog> {
  final CallService _service = CallService();

  late final TextEditingController _toController = TextEditingController(
    text: _formatNumber(widget.number ?? ''),
  );

  late final DashboardController _dashboard =
      Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  UserModel? _from;
  bool _isCalling = false;
  String? _error;

  @override
  void dispose() {
    _toController.dispose();
    super.dispose();
  }

  Future<void> _call() async {
    final from = _from;

    if (from == null) {
      setState(() => _error = 'Please select who is making the call');
      return;
    }

    final fromNumber = _formatNumber(from.phone ?? '');

    if (fromNumber.isEmpty) {
      setState(
        () => _error = '${_userName(from)} does not have a phone number',
      );
      return;
    }

    final toNumber = _formatNumber(_toController.text);

    if (toNumber.length < 9) {
      setState(() => _error = 'Please enter a valid number to call');
      return;
    }

    final hid = _dashboard.selectedHotelId.value;

    if (hid.isEmpty) {
      setState(() => _error = 'No hotel selected');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isCalling = true;
      _error = null;
    });

    try {
      await _service.makeCall(
        hid: hid,
        fromNumber: fromNumber,
        toNumber: toNumber,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      Get.snackbar(
        'Calling $toNumber',
        'You will get a call on $fromNumber first.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('MAKE CALL ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isCalling = false;
        _error = e is ApiException
            ? e.message
            : 'Unable to make the call. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? TAppColors.darkCard : TAppColors.lightCard;
    final border = isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
    final text = isDark ? TAppColors.darkText : TAppColors.lightText;
    final subText = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    InputDecoration decoration(String hint) {
      OutlineInputBorder line(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color),
      );

      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subText, fontSize: 14),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: line(border),
        focusedBorder: line(theme.colorScheme.primary),
        border: line(border),
      );
    }

    return Dialog(
      backgroundColor: cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Number to make a call!',
              style: TextStyle(
                color: text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            // ---------- From (a team user) ----------
            Obx(() {
              final users = _dashboard.userNameResponse.value?.data ?? [];

              
              // final users = _testUsers; // TESTING
              return DropdownButtonFormField<UserModel>(
                initialValue: users.contains(_from) ? _from : null,
                isExpanded: true,
                dropdownColor: cardColor,
                borderRadius: BorderRadius.circular(10),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: subText),
                style: TextStyle(color: text, fontSize: 14),
                decoration: decoration(''),
                hint: Text(
                  users.isEmpty ? 'No users found' : 'Select user',
                  style: TextStyle(color: subText, fontSize: 14),
                ),
                items: [
                  for (final user in users)
                    DropdownMenuItem<UserModel>(
                      value: user,
                      child: Text(
                        _userName(user),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _isCalling
                    ? null
                    : (user) => setState(() {
                        _from = user;
                        _error = null;
                      }),
              );
            }),

            const SizedBox(height: 12),

            // ---------- To (who to call) ----------
            TextField(
              controller: _toController,
              enabled: !_isCalling,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                LengthLimitingTextInputFormatter(16),
              ],
              style: TextStyle(color: text, fontSize: 14),
              decoration: decoration('Enter number'),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: TAppColors.error, fontSize: 12.5),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isCalling
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    // The app theme makes buttons full width; that does not work in a Row
                    minimumSize: const Size(0, 42),
                    foregroundColor: TAppColors.error,
                    side: const BorderSide(color: TAppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _isCalling ? null : _call,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.call, size: 16),
                  label: Text(_isCalling ? 'Calling...' : 'Call Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
