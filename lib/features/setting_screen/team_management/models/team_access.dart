// ============================================================
// TEAM ACCESS (model)
//
// Which modules the user can access (the "Access Control" checkboxes).
//
//   permissions : checkboxes shown in the form (API name -> screen name)
//   buildScope  : builds the full accessScope Map for the server
// ============================================================

class TeamAccess {
  TeamAccess._();

  /// Checkboxes shown in the form. key = API name, value = screen name.
  static const Map<String, String> permissions = {
    'cms': 'CMS',
    'frontDesk': 'Front Desk',
    'seoManager': 'Seo Manager',
    'bookingEngine': 'Booking Engine',
    'enquiriesManagement': 'Enquiries Management',
    'usermanagement': 'User Management',
    'gatewayManager': 'Payment Gateway',
  };

  /// The server needs all these keys, whether they show in the form or not
  static const List<String> _allKeys = [
    'analyticsandreporting',
    'bookingEngine',
    'channelManager',
    'cms',
    'conversationaltool',
    'emailmarketing',
    'enquiriesManagement',
    'foodManager',
    'frontDesk',
    'gatewayManager',
    'guestRequestManagement',
    'humanResourceManagement',
    'leadgenform',
    'reservationDesk',
    'seoManager',
    'smsmarketing',
    'socialMedia',
    'themes',
    'usermanagement',
    'whatsapp',
    'whatsappmarketing',
  ];

  /// Chosen keys are true, all others false.
  ///
  /// [botKey]: the server wants "eazobot" on Create and "eazbot" on Edit
  /// (the web sends it the same way), so the name comes from outside.
  static Map<String, bool> buildScope(
    Set<String> selected, {
    required String botKey,
  }) {
    return {
      for (final key in _allKeys) key: selected.contains(key),
      botKey: false,
    };
  }
}
