import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/leads_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/lead_card.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/leads_empty_state.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/leads_filter_screen.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/leads_search.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/leads_tabs.dart';

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsScreen extends StatelessWidget {
  final BottomNavController controller;

  LeadsScreen({super.key, required this.controller});

  final LeadsController leadsController = Get.put(LeadsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _appBar(context),

      body: Column(
        children: [
          LeadsSearch(controller: leadsController),

          LeadsTabs(controller: leadsController),

          const SizedBox(height: 8),

          Expanded(child: _leadsList(context)),
        ],
      ),
    );
  }
  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _appBar(BuildContext context) {
    final theme = Theme.of(context);

    final textColor = Theme.of(context).brightness == Brightness.dark
        ? TAppColors.darkText
        : TAppColors.lightText;

    return AppBar(
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: theme.appBarTheme.elevation ?? 0,
      centerTitle: true,

      leading: IconButton(
        onPressed: () => controller.changeTab(0),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 20,
        ),
      ),

      title: Text(
        'Leads',
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),

      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeadsFilterScreen(controller: leadsController),
              ),
            );
          },
          icon: Icon(Icons.filter_list, color: textColor),
        ),
      ],
    );
  }

  // ============================================================
  // LEADS LIST
  // ============================================================
  Widget _leadsList(BuildContext context) {
    return Obx(() {
      final leads = leadsController.filteredLeads;

      // ==========================================================
      // INITIAL LOADING
      // ==========================================================

      if (leadsController.isLoading && leads.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // ==========================================================
      // EMPTY
      // ==========================================================

      if (leads.isEmpty) {
        return const LeadsEmptyState();
      }

      // ==========================================================
      // LEADS LIST
      // ==========================================================

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 300) {
              leadsController.loadMoreLeads();
            }
          }

          return false;
        },

        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),

          itemCount: leads.length + (leadsController.isLoadingMore ? 1 : 0),

          itemBuilder: (_, index) {
            // ====================================================
            // PAGINATION LOADING
            // ====================================================

            if (index >= leads.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // ====================================================
            // LEAD CARD
            // ====================================================

            return LeadCard(lead: leads[index]);
          },
        ),
      );
    });
  }
}
