import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/LeadsDeatils/leadsDetailsScreen/leads_detail_dropdown_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsDetailsOverviewContent extends StatelessWidget {
  final BuildContext context;
  final LeadModel leads;

  const LeadsDetailsOverviewContent(
    this.context,
    this.leads, {
    super.key,
  });

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Lead information and details are shown above.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: LeadDetailsFilterWidget(
            leads: leads,
          ),
        ),
      ],
    );
  }
}