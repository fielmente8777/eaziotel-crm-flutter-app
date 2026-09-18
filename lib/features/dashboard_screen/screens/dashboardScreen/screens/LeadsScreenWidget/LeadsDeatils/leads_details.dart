import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/lead_details_filter_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/lead_notes_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/LeadsDeatils/leadsDetailsScreen/LeadsDetailsHeader.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/LeadsDeatils/leadsDetailsScreen/leadsDetailBody.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
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
    final estimatedValue = ' ₹ estimated value';

    final status = leads.status?.trim().isNotEmpty == true
        ? leads.status!.trim()
        : 'Open Queries';

    // ============================================================
    // STATUS BAR
    // ============================================================

    const headerTopColor = Color(0xFF3730A3);

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
          statusBarIconBrightness: Brightness.dark,
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
