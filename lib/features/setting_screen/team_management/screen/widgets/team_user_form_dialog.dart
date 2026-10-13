// ============================================================
// TEAM USER FORM DIALOG  (Create / Edit)
//
//   Create : Name, Phone, Email, Password (optional), Location, Access Control
//   Edit   : wahi, par Email badal nahi sakte aur Password nahi dikhta
//
// Save par controller.saveUser chalta hai. Error aaye to form ke neeche
// dikhta hai aur dialog khula rehta hai.
//
// Responsive: chaudai 480 se kam ho to fields ek ke neeche ek,
// aur Access Control 1 column me.
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/team_management_controller.dart';
import '../../models/location_option.dart';
import '../../models/team_access.dart';

/// [existing] null = naya user, warna us user ka Edit
void showTeamUserForm(
  BuildContext context,
  TeamManagementController controller, {
  UserModel? existing,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TeamUserForm(controller: controller, existing: existing),
  );
}

class _TeamUserForm extends StatefulWidget {
  const _TeamUserForm({required this.controller, this.existing});

  final TeamManagementController controller;
  final UserModel? existing;

  @override
  State<_TeamUserForm> createState() => _TeamUserFormState();
}

class _TeamUserFormState extends State<_TeamUserForm> {
  late final _name = TextEditingController(text: widget.existing?.displayName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _email = TextEditingController(text: widget.existing?.emailId);
  final _password = TextEditingController();

  LocationOption? _location;

  /// Chune hue Access Control checkbox
  final _selected = <String>{};

  String? _error;

  bool get _isEdit => widget.existing != null;

  TeamManagementController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();

    if (!_isEdit) {
      // Create: abhi selected hotel pehle se chuna hua
      _location = _controller.selectedLocation;
      return;
    }

    // Edit: user ka wo hotel jo selected hotel se mile, warna uska pehla hotel
    final assigned = widget.existing!.assignedLocation;
    if (assigned.isEmpty) return;

    final target =
        assigned.firstWhereOrNull(
          (a) => a.hid == _controller.selectedHotelId,
        ) ??
        assigned.first;

    _location = _controller.locations.firstWhereOrNull(
      (location) => location.hid == target.hid,
    );

    _loadSavedAccess(target.hid);
  }

  /// Edit: chune hue hotel ke checkbox user ki saved setting se bharo
  void _loadSavedAccess(String? hid) {
    _selected.clear();

    final assigned = widget.existing?.assignedLocation ?? [];
    final match = assigned.firstWhereOrNull((a) => a.hid == hid);
    final scope = match?.accessScope?.toJson() ?? {};

    for (final key in TeamAccess.permissions.keys) {
      if (scope[key] == true) _selected.add(key);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = await _controller.saveUser(
      existing: widget.existing,
      name: _name.text,
      phone: _phone.text,
      email: _email.text,
      password: _password.text,
      location: _location,
      selected: _selected,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = error);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 480;
            final padding = wide ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(p),
                  const SizedBox(height: 16),

                  // ---------- Name + Phone ----------
                  _pair(
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration('Name *', p),
                    ),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _decoration('Phone *', p),
                    ),
                    wide: wide,
                  ),
                  const SizedBox(height: 12),

                  // ---------- Email (Edit me badal nahi sakte) ----------
                  TextField(
                    controller: _email,
                    enabled: !_isEdit,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration('Email *', p),
                  ),
                  const SizedBox(height: 12),

                  // ---------- Password (sirf Create) + Location ----------
                  if (_isEdit)
                    _locationDropdown(p)
                  else
                    _pair(
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: _decoration('Password (optional)', p),
                      ),
                      _locationDropdown(p),
                      wide: wide,
                    ),
                  const SizedBox(height: 20),

                  // ---------- Access Control ----------
                  Text(
                    'Access Control',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _accessGrid(constraints.maxWidth - padding * 2, p),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _errorBox(),
                  ],

                  const SizedBox(height: 20),
                  _buttons(wide: wide),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HISSE
  // ============================================================

  Widget _title(SettingPalette p) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _isEdit ? 'Edit User' : 'Create New User',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close, color: p.subText),
          ),
        ),
      ],
    );
  }

  /// Wide screen par do field ek line me, phone par ek ke neeche ek
  Widget _pair(Widget first, Widget second, {required bool wide}) {
    if (!wide) {
      return Column(children: [first, const SizedBox(height: 12), second]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  Widget _locationDropdown(SettingPalette p) {
    final locations = _controller.locations;

    return DropdownButtonFormField<String>(
      initialValue: _location?.hid,
      isExpanded: true,
      decoration: _decoration('Select Location *', p),
      items: [
        for (final location in locations)
          DropdownMenuItem(value: location.hid, child: Text(location.name)),
      ],
      onChanged: (hid) => setState(() {
        _location = locations.firstWhereOrNull((l) => l.hid == hid);

        // Edit me us hotel ki saved setting dikhao
        if (_isEdit) _loadSavedAccess(hid);
      }),
    );
  }

  /// Checkbox grid: chhoti chaudai par 1 column, warna 2
  Widget _accessGrid(double width, SettingPalette p) {
    final columns = width >= 420 ? 2 : 1;
    const gap = 8.0;
    final itemWidth = (width - gap * (columns - 1)) / columns;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: gap,
        children: [
          for (final permission in TeamAccess.permissions.entries)
            SizedBox(
              width: itemWidth - 16,
              child: CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  permission.value,
                  style: TextStyle(fontSize: 13, color: p.text),
                ),
                value: _selected.contains(permission.key),
                onChanged: (checked) => setState(() {
                  checked == true
                      ? _selected.add(permission.key)
                      : _selected.remove(permission.key);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _error!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
      ),
    );
  }

  /// Phone par dono button barabar chaude, wide par daaye taraf
  Widget _buttons({required bool wide}) {
    final close = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Close'),
    );

    final save = Obx(() {
      final saving = _controller.isSaving.value;

      return FilledButton(
        onPressed: saving ? null : _submit,
        child: Text(
          saving ? 'Saving...' : (_isEdit ? 'Save Changes' : 'Create User'),
        ),
      );
    });

    if (!wide) {
      return Row(
        children: [
          Expanded(child: close),
          const SizedBox(width: 12),
          Expanded(child: save),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [close, const SizedBox(width: 12), save],
    );
  }

  InputDecoration _decoration(String hint, SettingPalette p) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );

    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(color: p.subText.withValues(alpha: 0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: border(p.border),
      enabledBorder: border(p.border),
      focusedBorder: border(p.primary),
    );
  }
}
