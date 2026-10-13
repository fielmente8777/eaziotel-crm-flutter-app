// ============================================================
// TEAM ACCESS (model)
//
// User ko kin modules ka access hai ("Access Control" ke checkbox).
//
//   permissions : form me dikhne wale checkbox (API ka naam -> screen ka naam)
//   buildScope  : server ke liye poora accessScope Map banata hai
// ============================================================

class TeamAccess {
  TeamAccess._();

  /// Form me dikhne wale checkbox. key = API ka naam, value = screen ka naam.
  static const Map<String, String> permissions = {
    'cms': 'CMS',
    'frontDesk': 'Front Desk',
    'seoManager': 'Seo Manager',
    'bookingEngine': 'Booking Engine',
    'enquiriesManagement': 'Enquiries Management',
    'usermanagement': 'User Management',
    'gatewayManager': 'Payment Gateway',
  };

  /// Server ko ye saari keys chahiye, chahe form me dikhe ya na dikhe
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

  /// Chuni hui keys true, baaki sab false.
  ///
  /// [botKey]: server Create me "eazobot" aur Edit me "eazbot" maangta hai
  /// (web bhi aisa hi bhejta hai), isliye naam bahar se aata hai.
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
