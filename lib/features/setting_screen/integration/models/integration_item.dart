// ============================================================
// INTEGRATION ITEM
//
// Integrations page ka ek card (Gmail, WhatsApp, Exotel ...).
// "Connected" hai ya nahi, ye integration/get API ke result.docs se aata hai.
// ============================================================

import 'package:flutter/material.dart';

/// Upar ke tabs: All / Communication / Analytics
enum IntegrationCategory {
  all('All'),
  communication('Communication'),
  analytics('Analytics');

  const IntegrationCategory(this.label);

  final String label;
}

class IntegrationItem {
  const IntegrationItem({
    required this.apiKey,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.connected = false,
  });

  /// integration/get ke docs me iska naam (jaise "metaWhatsapp")
  final String apiKey;
  final String title;
  final String description;
  final IntegrationCategory category;
  final IconData icon;
  final Color color;
  final bool connected;

  IntegrationItem copyWith({required bool connected}) => IntegrationItem(
    apiKey: apiKey,
    title: title,
    description: description,
    category: category,
    icon: icon,
    color: color,
    connected: connected,
  );

  /// Web dashboard jaisa list. Order bhi wahi.
  static const List<IntegrationItem> all = [
    IntegrationItem(
      apiKey: 'gmail',
      title: 'Gmail',
      description:
          'Sync your inbox and manage emails directly from your dashboard.',
      category: IntegrationCategory.communication,
      icon: Icons.mail_outline,
      color: Color(0xFFEA4335),
    ),
    IntegrationItem(
      apiKey: 'gmb',
      title: 'GMB',
      description: 'Manage your Google Business Profile from your dashboard.',
      category: IntegrationCategory.communication,
      icon: Icons.storefront_outlined,
      color: Color(0xFF4285F4),
    ),
    IntegrationItem(
      apiKey: 'googleAdsInsight',
      title: 'Google Ads Insights',
      description: 'Track google ads metrics.',
      category: IntegrationCategory.analytics,
      icon: Icons.bar_chart_rounded,
      color: Color(0xFFF9AB00),
    ),
    IntegrationItem(
      apiKey: 'metaWhatsapp',
      title: 'WhatsApp Business',
      description:
          'Connect WhatsApp to manage your business with our Hotelier WhatsApp Manager.',
      category: IntegrationCategory.communication,
      icon: Icons.chat_outlined,
      color: Color(0xFF25D366),
    ),
    IntegrationItem(
      apiKey: 'meta',
      title: 'Meta Leads',
      description: 'Get leads from your Facebook and Instagram lead forms.',
      category: IntegrationCategory.analytics,
      icon: Icons.all_inclusive_rounded,
      color: Color(0xFF0866FF),
    ),
    IntegrationItem(
      apiKey: 'WebsiteTracking',
      title: 'Website Tracking',
      description:
          'Connect website tracking code to your website and get website engagement.',
      category: IntegrationCategory.analytics,
      icon: Icons.track_changes_rounded,
      color: Color(0xFF7C3AED),
    ),
    IntegrationItem(
      apiKey: 'exotel',
      title: 'Exotel',
      description: 'Connect Exotel to make, receive and record calls.',
      category: IntegrationCategory.communication,
      icon: Icons.call_outlined,
      color: Color(0xFF22C55E),
    ),
    IntegrationItem(
      apiKey: 'otpless',
      title: 'OTP-Less',
      description: 'Let guests log in with WhatsApp or phone, without an OTP.',
      category: IntegrationCategory.communication,
      icon: Icons.verified_user_outlined,
      color: Color(0xFF64748B),
    ),
    IntegrationItem(
      apiKey: 'google_analytics',
      title: 'Google Analytics',
      description:
          'Connect Google Analytics to track website traffic and hotel performance insights.',
      category: IntegrationCategory.analytics,
      icon: Icons.insights_rounded,
      color: Color(0xFFF9AB00),
    ),
  ];

  /// docs me value true ho, ya {"status": true} ho = connected
  static bool isOn(dynamic value) {
    if (value is bool) return value;
    if (value is Map) return value['status'] == true;
    return false;
  }
}

/// Google account (Search Console) ka status: `/google/status/<hid>`
class GoogleConnection {
  const GoogleConnection({this.connected = false, this.email = ''});

  final bool connected;
  final String email;

  factory GoogleConnection.fromJson(Map<String, dynamic> json) =>
      GoogleConnection(
        connected: json['connected'] == true,
        email: json['email']?.toString() ?? '',
      );
}
