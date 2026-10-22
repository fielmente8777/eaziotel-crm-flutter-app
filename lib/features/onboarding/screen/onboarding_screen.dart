// ============================================================
// ONBOARD YOUR PROPERTY  (web: pages/Onboarding/OnboardingForm.jsx)
//
// A new account with no hotel sees this before the dashboard
// (the DashboardBottomNav gate). Only basic details; the rest later.
//
//   Phone        : one column
//   Tablet / Web : card in the middle, two columns
// ============================================================

import 'package:eazotel/features/onboarding/controller/onboarding_controller.dart';
import 'package:eazotel/features/setting_screen/screen/widgets/setting_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Created with the screen and removed with it (so the next account
  // does not get the old form)
  late final OnboardingController c = Get.put(OnboardingController());

  @override
  void dispose() {
    Get.delete<OnboardingController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSignOut = widget.onSignOut;
    final p = SettingPalette(context);

    return Scaffold(
      backgroundColor: p.inner,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 24 : 16,
                vertical: wide ? 40 : 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/image/eazotel.svg',
                        height: 34,
                        colorFilter: p.isDark
                            ? const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(wide ? 28 : 18),
                        decoration: BoxDecoration(
                          color: p.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: p.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: p.isDark ? .25 : .05,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _Form(c: c, wide: wide),
                      ),
                      const SizedBox(height: 18),
                      _SignOutRow(onSignOut: onSignOut),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// FORM
// ============================================================

class _Form extends StatelessWidget {
  const _Form({required this.c, required this.wide});

  final OnboardingController c;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final fields = <Widget>[
      _TextField(
        c: c,
        name: 'hotelName',
        label: 'Hotel name',
        hint: 'e.g. The Grand Palace',
        controller: c.hotelName,
        icon: Icons.apartment_rounded,
      ),
      _Picker(
        c: c,
        name: 'currency',
        label: 'Currency',
        icon: Icons.payments_outlined,
        value: () => c.currency.value,
        options: () => OnboardingController.currencies,
        onPick: c.setCurrency,
      ),
      _TextField(
        c: c,
        name: 'hotelEmail',
        label: 'Hotel email',
        hint: 'reservations@hotel.com',
        controller: c.hotelEmail,
        icon: Icons.mail_outline_rounded,
        keyboard: TextInputType.emailAddress,
      ),
      _TextField(
        c: c,
        name: 'hotelPhone',
        label: 'Hotel phone',
        hint: '+91 98765 43210',
        controller: c.hotelPhone,
        icon: Icons.phone_outlined,
        keyboard: TextInputType.phone,
      ),
      _PlaceField(
        c: c,
        name: 'country',
        label: 'Country',
        icon: Icons.public_rounded,
        list: () => c.countries.value,
        value: () => c.country.value,
        text: c.countryText,
        onPick: c.setCountry,
      ),
      _PlaceField(
        c: c,
        name: 'state',
        label: 'State',
        icon: Icons.map_outlined,
        waitingFor: () =>
            c.country.value.isEmpty && c.countries.value?.isEmpty != true
            ? 'Select a country first'
            : null,
        list: () => c.states.value,
        value: () => c.state.value,
        text: c.stateText,
        onPick: c.setState,
      ),
      _PlaceField(
        c: c,
        name: 'city',
        label: 'City',
        icon: Icons.location_city_rounded,
        waitingFor: () =>
            c.state.value.isEmpty && c.states.value?.isEmpty != true
            ? 'Select a state first'
            : null,
        list: () => c.cities.value,
        value: () => c.city.value,
        text: c.cityText,
        onPick: c.setCity,
      ),
      _TextField(
        c: c,
        name: 'pinCode',
        label: 'PIN / ZIP code',
        hint: '110001',
        controller: c.pinCode,
        icon: Icons.markunread_mailbox_outlined,
        keyboard: TextInputType.number,
        formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z ]'))],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: p.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.rocket_launch_rounded, color: p.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Onboard your property',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Just the basics. You can add everything else later.',
                    style: TextStyle(color: p.subText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TrialBadge(),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, box) {
            final cols = wide ? 2 : 1;
            const gap = 14.0;
            final w = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: 14,
              children: [
                for (final f in fields) SizedBox(width: w, child: f),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Obx(() {
          final busy = c.busy;
          return SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: busy
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      c.submit();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: p.primary.withValues(alpha: .6),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                busy ? Icons.hourglass_top_rounded : Icons.rocket_launch_rounded,
                size: 19,
              ),
              label: Text(
                busy ? c.submitting.value : 'Complete onboarding',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TrialBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    const green = Color(0xFF16A34A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: green.withValues(alpha: p.isDark ? .15 : .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_rounded, size: 18, color: green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your 14-day free trial starts when you finish.',
              style: TextStyle(
                color: p.isDark ? const Color(0xFF86EFAC) : green,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FIELD PARTS
// ============================================================

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: p.text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.text);

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Text(
        text!,
        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
      ),
    );
  }
}

InputDecoration _decoration(
  SettingPalette p, {
  required IconData icon,
  String? hint,
  bool error = false,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
  final errorColor = const Color(0xFFDC2626);
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: TextStyle(color: p.subText.withValues(alpha: .8), fontSize: 14),
    prefixIcon: Icon(icon, size: 19, color: p.subText),
    filled: true,
    fillColor: p.inner,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(error ? errorColor : p.border),
    enabledBorder: border(error ? errorColor : p.border),
    disabledBorder: border(p.border.withValues(alpha: .5)),
    focusedBorder: border(error ? errorColor : p.primary, 1.5),
  );
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.c,
    required this.name,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboard,
    this.formatters,
  });

  final OnboardingController c;
  final String name;
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Obx(() {
      final error = c.errors[name];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          TextField(
            controller: controller,
            enabled: !c.busy,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: p.text, fontSize: 14),
            onChanged: (_) => c.clearError(name),
            decoration: _decoration(
              p,
              icon: icon,
              hint: hint,
              error: error != null,
            ),
          ),
          _Error(error),
        ],
      );
    });
  }
}

/// Dropdown-like box; tapping opens a list from the bottom (with search)
class _Picker extends StatelessWidget {
  const _Picker({
    required this.c,
    required this.name,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onPick,
    this.placeholder,
    this.searchable = false,
    this.disabled,
  });

  final OnboardingController c;
  final String name;
  final String label;
  final IconData icon;
  final String Function() value;
  final List<String>? Function() options;
  final ValueChanged<String> onPick;
  final String? Function()? placeholder;
  final bool searchable;
  final bool Function()? disabled;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Obx(() {
      final error = c.errors[name];
      final current = value();
      final list = options();
      final off = c.busy || (disabled?.call() ?? false) || list == null;
      final hint = placeholder?.call() ?? 'Select ${label.toLowerCase()}';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: off
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final picked = await _showOptions(
                      context,
                      title: label,
                      options: list,
                      selected: current,
                      searchable: searchable,
                    );
                    if (picked != null) onPick(picked);
                  },
            child: InputDecorator(
              isEmpty: current.isEmpty,
              decoration: _decoration(
                p,
                icon: icon,
                hint: list == null ? 'Loading...' : hint,
                error: error != null,
              ).copyWith(
                enabled: !off,
                suffixIcon: Icon(
                  list == null
                      ? Icons.hourglass_top_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: p.subText,
                  size: list == null ? 17 : 22,
                ),
              ),
              child: current.isEmpty
                  ? null
                  : Text(
                      current,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.text, fontSize: 14),
                    ),
            ),
          ),
          _Error(error),
        ],
      );
    });
  }
}

/// Country / state / city: a picker if there is a list, otherwise a text box
class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.c,
    required this.name,
    required this.label,
    required this.icon,
    required this.list,
    required this.value,
    required this.text,
    required this.onPick,
    this.waitingFor,
  });

  final OnboardingController c;
  final String name;
  final String label;
  final IconData icon;
  final List<String>? Function() list;
  final String Function() value;
  final TextEditingController text;
  final ValueChanged<String> onPick;
  final String? Function()? waitingFor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = list();
      final waiting = waitingFor?.call();

      // the places API has nothing: the user types it
      if (waiting == null && items != null && items.isEmpty) {
        return _TextField(
          c: c,
          name: name,
          label: label,
          hint: 'Enter ${label.toLowerCase()}',
          controller: text,
          icon: icon,
        );
      }

      return _Picker(
        c: c,
        name: name,
        label: label,
        icon: icon,
        value: value,
        // previous one not chosen -> no list needed, empty is fine
        options: () => waiting != null ? const [] : list(),
        placeholder: () => waiting,
        disabled: () => waiting != null,
        searchable: true,
        onPick: onPick,
      );
    });
  }
}

// ============================================================
// OPTIONS SHEET
// ============================================================

Future<String?> _showOptions(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String selected,
  required bool searchable,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => _OptionsSheet(
      title: title,
      options: options,
      selected: selected,
      searchable: searchable,
    ),
  );
}

class _OptionsSheet extends StatefulWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchable,
  });

  final String title;
  final List<String> options;
  final String selected;
  final bool searchable;

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? widget.options
        : widget.options.where((o) => o.toLowerCase().contains(q)).toList();
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.searchable ? height * .8 : height * .6,
        ),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select ${widget.title.toLowerCase()}',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: p.subText),
                  ),
                ],
              ),
            ),
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(color: p.text, fontSize: 14),
                  decoration: _decoration(
                    p,
                    icon: Icons.search_rounded,
                    hint: 'Search ${widget.title.toLowerCase()}',
                  ),
                ),
              ),
            Flexible(
              child: shown.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        'No results',
                        style: TextStyle(color: p.subText),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: shown.length,
                      itemBuilder: (_, i) {
                        final option = shown[i];
                        final active = option == widget.selected;
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          selected: active,
                          selectedTileColor: p.primary.withValues(alpha: .1),
                          title: Text(
                            option,
                            style: TextStyle(
                              color: active ? p.primary : p.text,
                              fontSize: 14,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: active
                              ? Icon(Icons.check_rounded, color: p.primary)
                              : null,
                          onTap: () => Navigator.pop(context, option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SIGN OUT
// ============================================================

class _SignOutRow extends StatelessWidget {
  const _SignOutRow({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Signed in with the wrong account?',
          style: TextStyle(color: p.subText, fontSize: 13),
        ),
        TextButton(
          onPressed: onSignOut,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(
            'Sign out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
