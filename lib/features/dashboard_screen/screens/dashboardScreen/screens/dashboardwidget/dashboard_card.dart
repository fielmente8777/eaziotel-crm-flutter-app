import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/DashboardStatCard.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

// ============================================================
// DASHBOARD BODY
// ============================================================

Widget dashboardBody() {
  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );
  final docs = dashboardController.analyticsResponse.value?.result?.docs;

  final totalLeads = docs?.totalLeads?.isNotEmpty == true
      ? docs!.totalLeads!.first.count
      : 0;

  final convertedLeads = docs?.convertedLeads?.isNotEmpty == true
      ? docs!.convertedLeads!.first.count
      : 0;

  final convertedRate = totalLeads == 0
      ? 0.0
      : ((convertedLeads ?? 0) / totalLeads!.toInt()) * 100;
  final whatsappConversations = docs?.totalWhatsappConversations ?? 0;

  final todayLeads = docs?.todayLeads ?? 0;

 
  final dashboardCards = [
    {
      'value': totalLeads.toString(),
      'title': 'Total Leads',
      'bottomText': 'Total leads',
      'icon': Icons.person_outline,
      'accentColor': Colors.indigo,
      'iconColor': Colors.indigo,
    },
    {
      'value': convertedLeads.toString(),
      'title': 'Converted Leads',
      'bottomText': 'Converted leads',
      'icon': Icons.calendar_today_outlined,
      'accentColor': Colors.teal,
      'iconColor': Colors.teal,
    },
    if (whatsappConversations > 0)
      {
        'value': whatsappConversations.toString(),
        'title': 'WhatsApp Conversations',
        'bottomText': 'Total conversations',
        'icon': Icons.chat_outlined,
        'accentColor': Colors.orange,
        'iconColor': Colors.orange,
      },
    {
      'value': '${convertedRate.toStringAsFixed(1)}%',
      'title': 'WhatsApp Conversations',
      'bottomText': 'Total conversations',
      'icon': Icons.chat_outlined,
      'accentColor': Colors.orange,
      'iconColor': Colors.orange,
    },
    {
      'value': todayLeads.toString(),
      'title': 'Today Leads',
      'bottomText': 'Today',
      'icon': Icons.today_outlined,
      'accentColor': Colors.purple,
      'iconColor': Colors.purple,
      'valueColor': TAppColors.success,
    },
  ];

  return GridView.builder(
    padding: const EdgeInsets.all(16),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: dashboardCards.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.25,
    ),
    itemBuilder: (context, index) {
      final card = dashboardCards[index];

      return DashboardStatCard(
        value: card['value'].toString(),
        title: card['title'].toString(),
        bottomText: card['bottomText'].toString(),
        icon: card['icon'] as IconData,
        accentColor: card['accentColor'] as Color,
        iconColor: card['iconColor'] as Color,
        valueColor: card['valueColor'] as Color?,
       );
    },
  );
}
