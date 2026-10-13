// ============================================================
// EAZBOT SETTING TAB  (Settings > Eazbot)
//
//   upar   : Publish button + 1-2-3-4 stepper
//   beech  : chuna hua step (widgets/ folder me)
//   neeche : Previous / Next
//
// Data controller/ me, API services/ me.
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/eazbot_setting_controller.dart';
import 'widgets/eazbot_builder_step.dart';
import 'widgets/eazbot_common.dart';
import 'widgets/eazbot_configuration_step.dart';
import 'widgets/eazbot_install_step.dart';
import 'widgets/eazbot_profile_step.dart';

class EazbotSettingTab extends StatelessWidget {
  const EazbotSettingTab({super.key});

  /// Publish purana bot badal deta hai, isliye pehle pooch lo
  Future<void> _confirmPublish(
    BuildContext context,
    EazbotSettingController controller,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Publish chatbot?'),
        content: const Text(
          'This replaces the chatbot currently live on your website '
          'with these settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (ok == true) controller.publish();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EazbotSettingController());

    return TResponsiveBuilder(
      builder: (context, r) {
        final p = SettingPalette(context);
        final wide = !r.isPhone;

        return Obx(() {
          final step = controller.step.value;
          final publishing = controller.isPublishing.value;
          final isFirst = step == EazbotStep.values.first;
          final isLast = step == EazbotStep.values.last;

          final body = switch (step) {
            EazbotStep.builder => EazbotBuilderStep(controller: controller),
            EazbotStep.profile => EazbotProfileStep(
              controller: controller,
              wide: wide,
            ),
            EazbotStep.configuration => EazbotConfigurationStep(
              controller: controller,
              wide: wide,
            ),
            EazbotStep.install => EazbotInstallStep(controller: controller),
          };

          return ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              // ---------- Publish ----------
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: settingSmallButton(),
                  onPressed: publishing
                      ? null
                      : () => _confirmPublish(context, controller),
                  icon: const Icon(Icons.rocket_launch_outlined, size: 16),
                  label: Text(publishing ? 'Publishing...' : 'Publish'),
                ),
              ),
              const SizedBox(height: 12),

              // ---------- Stepper ----------
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: EazbotStepper(current: step, onTap: controller.goTo),
              ),
              const SizedBox(height: 18),

              // ---------- Step ----------
              body,
              const SizedBox(height: 20),

              // ---------- Previous / Next ----------
              Row(
                children: [
                  OutlinedButton(
                    onPressed: isFirst ? null : controller.previous,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Previous'),
                  ),
                  const SizedBox(width: 10),
                  if (!isLast)
                    ElevatedButton(
                      onPressed: controller.next,
                      style: settingSmallButton(),
                      child: const Text('Next'),
                    ),
                ],
              ),
            ],
          );
        });
      },
    );
  }
}
