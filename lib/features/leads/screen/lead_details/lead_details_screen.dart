import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/leads/controller/lead_details_filter_controller.dart';
import 'package:eazotel/features/leads/controller/lead_notes_api_controller.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:eazotel/features/leads/screen/lead_details/widgets/lead_details_header.dart';
import 'package:eazotel/features/leads/screen/lead_details/widgets/lead_detail_body.dart';
import 'package:eazotel/features/leads/screen/widgets/lead_card.dart'
    show formatTimelineDate;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LeadsDetails extends StatelessWidget {
  final LeadModel leads;

  LeadsDetails({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final name = leads.name?.trim().isNotEmpty == true
        ? leads.name!.trim()
        : 'Unknown';

    final phone = leads.contact?.trim() ?? '';

    // Header me naam ke neeche: "Added 2 days ago · +91 98765 43210"
    // (pehle yahan " ₹ estimated value" likha aata tha)
    final added = formatTimelineDate(leads.createdAtDate ?? leads.createdAt);
    final estimatedValue = [
      if (added.isNotEmpty) 'Added $added',
      if (phone.isNotEmpty) phone,
    ].join('  ·  ');

    final status = leads.status?.trim().isNotEmpty == true
        ? leads.status!.trim()
        : 'Open Queries';

    // ============================================================
    // STATUS BAR
    // ============================================================

    // Header ke upar ka rang; icon safed (dark header par dark icon nahi dikhte)
    const headerTopColor = Color(0xFF4338CA);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        final dashboardController = Get.find<DashboardController>();

        await dashboardController.refreshLeads();
        if (Get.isRegistered<LeadDetailsNotesController>()) {
          Get.delete<LeadDetailsNotesController>();
        }
        if (Get.isRegistered<LeadFilterController>()) {
          Get.delete<LeadFilterController>();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: headerTopColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // HEADER FIXED
                leads_detail_header(
                  context,
                  name,
                  theme,
                  status,
                  estimatedValue,
                  leads,
                ),

                // ONLY BODY SCROLL
                Expanded(
                  child: SingleChildScrollView(
                    child: leads_detail_body(
                      theme,
                      context,
                      isDark,
                      phone,
                      leads,
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
