// ============================================================
// LOCAL SEO SETUP  (first time, 3 steps)
//
//   1. Business : name, type, website
//   2. Location : tap on the map (Android/iOS) or GPS or by hand
//   3. Keywords : pick suggestions / type your own -> Finish
//
// The Local SEO screen shows this when the setup is incomplete.
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/local_seo_setup_controller.dart';
import 'widgets/seo_common.dart';
import 'widgets/seo_geo_grid.dart';

class LocalSeoSetupView extends StatelessWidget {
  const LocalSeoSetupView({super.key, required this.onDone});

  /// Setup done -> reload Local SEO
  final Future<void> Function() onDone;

  static const _steps = ['Business', 'Location', 'Keywords'];

  Future<void> _finish(LocalSeoSetupController c) async {
    final error = await c.submit();

    if (error != null) {
      Get.snackbar(
        'Setup failed',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SeoColors.rose,
        colorText: Colors.white,
      );
      return;
    }

    await onDone();
    Get.delete<LocalSeoSetupController>();
    Get.snackbar(
      'Local SEO is ready',
      'We are checking your rankings now.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LocalSeoSetupController());
    final p = SettingPalette(context);

    return TResponsiveBuilder(
      builder: (context, r) => SingleChildScrollView(
        padding: EdgeInsets.all(r.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const SeoHeaderIcon(
                  icon: Icons.location_on,
                  colors: SeoColors.localGradient,
                  size: 56,
                ),
                const SizedBox(height: 12),
                Text(
                  'Set up Local SEO',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'One-time setup — takes 2 minutes.',
                  style: TextStyle(color: p.subText),
                ),
                const SizedBox(height: 20),
                Obx(() => _StepBar(step: c.step.value, onTap: c.goTo)),
                const SizedBox(height: 18),
                SeoPanel(
                  padding: EdgeInsets.all(r.isPhone ? 16 : 22),
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: switch (c.step.value) {
                        1 => _BusinessStep(key: const ValueKey(1), c: c),
                        2 => _LocationStep(key: const ValueKey(2), c: c),
                        _ => _KeywordStep(
                          key: const ValueKey(3),
                          c: c,
                          onFinish: () => _finish(c),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STEP BAR (1 — 2 — 3), tap a finished step to go back
// ============================================================

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.onTap});

  final int step;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    // On small screens only the current step's name
    final roomy = MediaQuery.sizeOf(context).width >= 480;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < LocalSeoSetupView._steps.length; i++) ...[
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: i + 1 < step ? () => onTap(i + 1) : null,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step == i + 1
                          ? SeoColors.emerald
                          : step > i + 1
                          ? SeoColors.emerald.withValues(alpha: .2)
                          : p.border,
                    ),
                    child: step > i + 1
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: SeoColors.emerald,
                          )
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: step == i + 1 ? Colors.white : p.subText,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                  ),
                  if (roomy || step == i + 1) ...[
                    const SizedBox(width: 6),
                    Text(
                      LocalSeoSetupView._steps[i],
                      style: TextStyle(
                        color: step == i + 1 ? p.text : p.subText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (i < LocalSeoSetupView._steps.length - 1)
            Container(
              width: 22,
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: step > i + 1 ? SeoColors.emerald : p.border,
            ),
        ],
      ],
    );
  }
}

// ============================================================
// FORM HELPERS
// ============================================================

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.number = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final bool number;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: p.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: p.text),
          keyboardType: number
              ? const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                )
              : TextInputType.text,
          decoration: seoInput(context, hint),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper!, style: TextStyle(color: p.subText, fontSize: 11.5)),
        ],
      ],
    );
  }
}

InputDecoration seoInput(BuildContext context, String? hint) {
  final p = SettingPalette(context);
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: p.subText),
    isDense: true,
    filled: true,
    fillColor: p.inner,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: border(p.border),
    enabledBorder: border(p.border),
    focusedBorder: border(SeoColors.emerald, 1.6),
  );
}

/// Two fields in one row (stacked on very small screens)
class _Pair extends StatelessWidget {
  const _Pair(this.a, this.b);

  final Widget a;
  final Widget b;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth < 300
          ? Column(children: [a, const SizedBox(height: 12), b])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: 12),
                Expanded(child: b),
              ],
            ),
    );
  }
}

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.onNext,
    required this.nextLabel,
    this.onBack,
    this.loading = false,
    this.icon = Icons.chevron_right,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool loading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          Expanded(
            child: OutlinedButton(
              style: seoOutlineButton(context).copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
              ),
              onPressed: onBack,
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            style: seoButton(
              SeoColors.emerald,
            ).copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 46))),
            onPressed: onNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading) ...[
                  const SeoSpin(child: Icon(Icons.sync, size: 18)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(nextLabel, overflow: TextOverflow.ellipsis),
                ),
                if (!loading) ...[
                  const SizedBox(width: 4),
                  Icon(icon, size: 18),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STEP 1: BUSINESS
// ============================================================

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({super.key, required this.c});

  final LocalSeoSetupController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: 'Business / Property name *',
          controller: c.name,
          hint: 'e.g. Hotel Sunrise Indirapuram',
          helper: 'Use the exact name as on Google Business Profile.',
        ),
        const SizedBox(height: 16),
        Text(
          'Business type *',
          style: TextStyle(
            color: p.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in LocalSeoSetupController.businessTypes)
                ChoiceChip(
                  label: Text(type.capitalizeFirst ?? type),
                  selected: c.businessType.value == type,
                  selectedColor: SeoColors.emerald.withValues(alpha: .18),
                  labelStyle: TextStyle(
                    color: c.businessType.value == type
                        ? SeoColors.emerald
                        : p.text,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: c.businessType.value == type
                        ? SeoColors.emerald
                        : p.border,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => c.businessType.value = type,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Field(
          label: 'Your website domain (optional)',
          controller: c.domain,
          hint: 'e.g. hotelsunrise.com',
        ),
        const SizedBox(height: 20),
        Obx(
          () => _NavButtons(
            nextLabel: 'Continue',
            onNext: c.canLeaveStep1 ? () => c.goTo(2) : null,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STEP 2: LOCATION
// ============================================================

class _LocationStep extends StatefulWidget {
  const _LocationStep({super.key, required this.c});

  final LocalSeoSetupController c;

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  GoogleMapController? _map;

  LocalSeoSetupController get c => widget.c;

  LatLng? get _picked => c.latValue != null && c.lngValue != null
      ? LatLng(c.latValue!, c.lngValue!)
      : null;

  Future<void> _detect() async {
    final point = await c.detectLocation();
    if (point == null) return;

    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(point.lat, point.lng), 15),
    );
    if (mounted) setState(() {});
  }

  Future<void> _tapMap(LatLng point) async {
    setState(() {}); // marker right away
    await c.setPoint(point.latitude, point.longitude);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final picked = _picked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (seoMapSupported) ...[
          Text(
            'Tap on the map to pin your property',
            style: TextStyle(
              color: p.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 230,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      // The one already chosen, otherwise Delhi
                      target: picked ?? const LatLng(28.6139, 77.2090),
                      zoom: 13,
                    ),
                    onMapCreated: (m) => _map = m,
                    onTap: _tapMap,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    markers: {
                      if (picked != null)
                        Marker(
                          markerId: const MarkerId('property'),
                          position: picked,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                        ),
                    },
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    },
                  ),
                  if (picked == null)
                    IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: .35),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.ads_click,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tap anywhere to set your location',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'City and district fill in automatically.',
            style: TextStyle(color: p.subText, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SeoColors.emerald.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SeoColors.emerald.withValues(alpha: .25)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  seoMapSupported
                      ? 'Or use your current GPS location'
                      : 'Use your current location, or type it below',
                  style: TextStyle(color: p.text, fontSize: 12.5),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SeoColors.emerald,
                    side: const BorderSide(color: SeoColors.emerald),
                    minimumSize: const Size(0, 38),
                  ),
                  onPressed: c.isLocating.value ? null : _detect,
                  icon: SeoSpin(
                    spinning: c.isLocating.value,
                    child: const Icon(Icons.my_location, size: 16),
                  ),
                  label: const Text('Auto-detect'),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => c.locationError.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    c.locationError.value,
                    style: const TextStyle(color: SeoColors.rose, fontSize: 12),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        _Pair(
          _Field(
            label: 'Latitude',
            controller: c.lat,
            hint: '28.6139',
            number: true,
          ),
          _Field(
            label: 'Longitude',
            controller: c.lng,
            hint: '77.2090',
            number: true,
          ),
        ),
        const SizedBox(height: 12),
        _Pair(
          _Field(
            label: 'District / Area *',
            controller: c.district,
            hint: 'e.g. Indirapuram',
          ),
          _Field(label: 'City *', controller: c.city, hint: 'e.g. Ghaziabad'),
        ),
        const SizedBox(height: 12),
        _Pair(
          _Field(
            label: 'State',
            controller: c.state,
            hint: 'e.g. Uttar Pradesh',
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target radius',
                style: TextStyle(
                  color: p.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => DropdownButtonFormField<int>(
                  initialValue: c.radiusKm.value,
                  dropdownColor: p.card,
                  style: TextStyle(color: p.text),
                  decoration: seoInput(context, null),
                  items: [
                    for (final km in const [2, 5, 10])
                      DropdownMenuItem(value: km, child: Text('$km km')),
                  ],
                  onChanged: (v) => c.radiusKm.value = v ?? 5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _NavButtons(
            onBack: () => c.goTo(1),
            nextLabel: 'Continue',
            onNext: c.canLeaveStep2 ? () => c.goTo(3) : null,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STEP 3: KEYWORDS
// ============================================================

class _KeywordStep extends StatelessWidget {
  const _KeywordStep({super.key, required this.c, required this.onFinish});

  final LocalSeoSetupController c;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: p.subText, fontSize: 13),
            children: [
              const TextSpan(text: 'Select keywords for '),
              TextSpan(
                text: '${c.district.text}, ${c.city.text}',
                style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (c.isSuggesting.value) {
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SeoSpin(
                    child: Icon(Icons.auto_awesome, color: SeoColors.emerald),
                  ),
                  const SizedBox(width: 8),
                  Text('Generating ideas…', style: TextStyle(color: p.subText)),
                ],
              ),
            );
          }

          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kw in c.suggestions)
                    FilterChip(
                      label: Text(kw),
                      selected: c.selected.contains(kw),
                      selectedColor: SeoColors.emerald.withValues(alpha: .18),
                      checkmarkColor: SeoColors.emerald,
                      labelStyle: TextStyle(
                        color: c.selected.contains(kw)
                            ? SeoColors.emerald
                            : p.text,
                        fontSize: 12.5,
                      ),
                      side: BorderSide(
                        color: c.selected.contains(kw)
                            ? SeoColors.emerald
                            : p.border,
                      ),
                      onSelected: (_) => c.toggle(kw),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text(
          'Add a custom keyword',
          style: TextStyle(
            color: p.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: c.custom,
                style: TextStyle(color: p.text),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => c.addCustom(),
                decoration: seoInput(
                  context,
                  '${c.businessType.value} near ${c.district.text}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => IconButton.filledTonal(
                tooltip: 'Add',
                onPressed: c.hasCustomText ? c.addCustom : null,
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => c.selected.isEmpty
              ? Text(
                  'Pick at least one keyword.',
                  style: TextStyle(color: p.subText, fontSize: 12),
                )
              : Text(
                  '✓ ${c.selected.length} keyword'
                  '${c.selected.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    color: SeoColors.emerald,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 18),
        Obx(
          () => _NavButtons(
            onBack: c.isSaving.value ? null : () => c.goTo(2),
            nextLabel: c.isSaving.value ? 'Setting up…' : 'Finish setup',
            icon: Icons.check_circle_outline,
            loading: c.isSaving.value,
            onNext: c.selected.isEmpty || c.isSaving.value ? null : onFinish,
          ),
        ),
      ],
    );
  }
}
