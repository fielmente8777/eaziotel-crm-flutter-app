// ============================================================
// TEMPLATE LIBRARY (API nahi, web dashboard jaisi fixed list)
//
// Hotel ke liye taiyaar template. "Use Template" dabane par
// Create Template form inse bhar jaata hai.
// ============================================================

class LibraryButton {
  const LibraryButton({required this.type, required this.text, this.url});

  /// URL / QUICK_REPLY / CALL
  final String type;
  final String text;
  final String? url;
}

class LibraryTemplate {
  const LibraryTemplate({
    required this.name,
    required this.category,
    required this.header,
    required this.body,
    required this.footer,
    this.buttons = const [],
  });

  final String name;

  /// UTILITY / MARKETING / AUTHENTICATION
  final String category;
  final String header;
  final String body;
  final String footer;
  final List<LibraryButton> buttons;

  /// Search: naam, header ya body me
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        header.toLowerCase().contains(q) ||
        body.toLowerCase().contains(q);
  }

  static const List<String> categories = [
    'UTILITY',
    'MARKETING',
    'AUTHENTICATION',
  ];

  static const List<LibraryTemplate> all = [
    LibraryTemplate(
      name: 'booking_confirmation',
      category: 'UTILITY',
      header: 'Booking Confirmed',
      body: 'Hi {{1}}, your booking at {{2}} is confirmed from {{3}} to {{4}}.',
      footer: 'We look forward to hosting you!',
      buttons: [LibraryButton(type: 'URL', text: 'View Booking', url: '{{5}}')],
    ),
    LibraryTemplate(
      name: 'pre_arrival',
      category: 'UTILITY',
      header: 'Welcome Soon',
      body: 'Hi {{1}}, we are excited to welcome you to {{2}} tomorrow.',
      footer: 'Safe travels!',
      buttons: [LibraryButton(type: 'QUICK_REPLY', text: 'Share Arrival Time')],
    ),
    LibraryTemplate(
      name: 'welcome_message',
      category: 'UTILITY',
      header: 'Welcome',
      body: 'Welcome {{1}} to {{2}}. Let us know if you need anything.',
      footer: 'Enjoy your stay!',
    ),
    LibraryTemplate(
      name: 'upsell_services',
      category: 'MARKETING',
      header: 'Enhance Stay',
      body: 'Hi {{1}}, explore spa, dining & tours at {{2}}.',
      footer: 'Limited time offers',
      buttons: [
        LibraryButton(type: 'URL', text: 'Explore Offers', url: '{{3}}'),
      ],
    ),
    LibraryTemplate(
      name: 'restaurant_offer',
      category: 'MARKETING',
      header: 'Special Dining Offer',
      body: 'Enjoy {{1}} at {{2}}. Book your table now.',
      footer: 'Limited seats available',
      buttons: [
        LibraryButton(type: 'URL', text: 'Reserve Table', url: '{{3}}'),
      ],
    ),
    LibraryTemplate(
      name: 'seasonal_offer',
      category: 'MARKETING',
      header: 'Exclusive Deal',
      body: 'Get {{1}} off on your next stay at {{2}}.',
      footer: 'Valid till {{3}}',
      buttons: [LibraryButton(type: 'URL', text: 'Book Now', url: '{{4}}')],
    ),
    LibraryTemplate(
      name: 'checkout_reminder',
      category: 'UTILITY',
      header: 'Checkout Reminder',
      body: 'Hi {{1}}, your checkout time is {{2}}.',
      footer: 'Thank you!',
    ),
    LibraryTemplate(
      name: 'feedback_request',
      category: 'UTILITY',
      header: 'Feedback',
      body: 'Hi {{1}}, please share your experience at {{2}}.',
      footer: 'We value your feedback',
      buttons: [
        LibraryButton(type: 'URL', text: 'Give Feedback', url: '{{3}}'),
      ],
    ),
    LibraryTemplate(
      name: 're_engagement',
      category: 'MARKETING',
      header: 'We Miss You',
      body: 'Hi {{1}}, enjoy {{2}} on your next visit to {{3}}.',
      footer: 'Come back soon!',
      buttons: [LibraryButton(type: 'URL', text: 'Book Again', url: '{{4}}')],
    ),
    LibraryTemplate(
      name: 'event_promotion',
      category: 'MARKETING',
      header: 'Celebrate With Us',
      body: 'Plan your {{1}} at {{2}} with exclusive packages.',
      footer: 'Make it memorable',
      buttons: [LibraryButton(type: 'CALL', text: 'Call Us', url: '{{3}}')],
    ),
    LibraryTemplate(
      name: 'early_checkin_offer',
      category: 'MARKETING',
      header: 'Early Check-in',
      body:
          'Hi {{1}}, start your stay earlier at {{2}} with early check-in access.',
      footer: 'Limited availability',
      buttons: [LibraryButton(type: 'URL', text: 'Request Now', url: '{{3}}')],
    ),
    LibraryTemplate(
      name: 'room_upgrade',
      category: 'MARKETING',
      header: 'Upgrade Your Room',
      body: 'Hi {{1}}, move to a premium room at {{2}} for enhanced comfort.',
      footer: 'Upgrade your experience',
      buttons: [LibraryButton(type: 'URL', text: 'Upgrade', url: '{{3}}')],
    ),
    LibraryTemplate(
      name: 'checkin_reminder',
      category: 'UTILITY',
      header: 'Check-in Reminder',
      body: 'Hi {{1}}, your check-in at {{2}} is scheduled for {{3}}.',
      footer: 'See you soon',
    ),
    LibraryTemplate(
      name: 'payment_confirmation',
      category: 'UTILITY',
      header: 'Payment Received',
      body: 'Hi {{1}}, your payment of {{2}} has been successfully processed.',
      footer: 'Thank you',
    ),
    LibraryTemplate(
      name: 'cancellation_confirmation',
      category: 'UTILITY',
      header: 'Booking Cancelled',
      body:
          'Hi {{1}}, your reservation at {{2}} has been cancelled successfully.',
      footer: 'Hope to host you again',
    ),
    LibraryTemplate(
      name: 'loyalty_reward',
      category: 'MARKETING',
      header: 'Reward Unlocked',
      body:
          "Hi {{1}}, you've unlocked exclusive rewards after your stay at {{2}}.",
      footer: 'Enjoy your benefits',
      buttons: [LibraryButton(type: 'URL', text: 'View Rewards', url: '{{3}}')],
    ),
    LibraryTemplate(
      name: 'festival_offer',
      category: 'MARKETING',
      header: 'Festive Experience',
      body: 'Celebrate {{1}} at {{2}} with special themed experiences.',
      footer: 'Celebrate in style',
      buttons: [LibraryButton(type: 'URL', text: 'Explore', url: '{{3}}')],
    ),
    LibraryTemplate(
      name: 'housekeeping_request',
      category: 'UTILITY',
      header: 'Housekeeping Service',
      body: 'Hi {{1}}, request housekeeping service at {{2}} anytime.',
      footer: "We're here to help",
      buttons: [LibraryButton(type: 'QUICK_REPLY', text: 'Request')],
    ),
    LibraryTemplate(
      name: 'wifi_details',
      category: 'UTILITY',
      header: 'WiFi Access',
      body: 'Hi {{1}}, connect to WiFi at {{2}} using provided credentials.',
      footer: 'Stay connected',
    ),
    LibraryTemplate(
      name: 'transport_service',
      category: 'MARKETING',
      header: 'Travel Assistance',
      body: 'Hi {{1}}, arrange your transport to or from {{2}} easily.',
      footer: 'Travel made simple',
      buttons: [LibraryButton(type: 'URL', text: 'Book Ride', url: '{{3}}')],
    ),
    LibraryTemplate(
      name: 'late_checkout_offer',
      category: 'MARKETING',
      header: 'Late Checkout Option',
      body:
          'Hi {{1}}, enjoy extra time at {{2}} with our late checkout option.',
      footer: 'Relax a little longer',
      buttons: [
        LibraryButton(type: 'URL', text: 'Request Late Checkout', url: '{{3}}'),
      ],
    ),
    LibraryTemplate(
      name: 'room_service_order',
      category: 'UTILITY',
      header: 'Room Service Update',
      body: 'Hi {{1}}, your room service order at {{2}} is being prepared.',
      footer: 'Will be delivered shortly',
    ),
    LibraryTemplate(
      name: 'maintenance_alert',
      category: 'UTILITY',
      header: 'Maintenance Notice',
      body:
          'Hi {{1}}, scheduled maintenance at {{2}} may affect some services.',
      footer: 'We appreciate your patience',
    ),
    LibraryTemplate(
      name: 'lost_and_found',
      category: 'UTILITY',
      header: 'Lost & Found Update',
      body: 'Hi {{1}}, an item matching your description was found at {{2}}.',
      footer: 'Contact us to claim',
      buttons: [
        LibraryButton(type: 'CALL', text: 'Call Reception', url: '{{3}}'),
      ],
    ),
    LibraryTemplate(
      name: 'otp_verification',
      category: 'AUTHENTICATION',
      header: 'OTP Verification',
      body:
          'Hi {{1}}, your OTP for verification is {{2}}. It is valid for {{3}} minutes.',
      footer: 'Do not share this code with anyone',
    ),
    LibraryTemplate(
      name: 'login_alert',
      category: 'AUTHENTICATION',
      header: 'New Login Detected',
      body: 'Hi {{1}}, a new login to your account was detected from {{2}}.',
      footer: "If this wasn't you, please secure your account immediately",
    ),
    LibraryTemplate(
      name: 'password_reset',
      category: 'AUTHENTICATION',
      header: 'Password Reset Request',
      body:
          'Hi {{1}}, use this OTP {{2}} to reset your password. Valid for {{3}} minutes.',
      footer: "If you didn't request this, ignore this message",
    ),
    LibraryTemplate(
      name: 'account_verification',
      category: 'AUTHENTICATION',
      header: 'Verify Your Account',
      body: 'Hi {{1}}, please verify your account using code {{2}}.',
      footer: 'Welcome aboard!',
    ),
    LibraryTemplate(
      name: 'two_factor_auth',
      category: 'AUTHENTICATION',
      header: '2-Step Verification',
      body: 'Hi {{1}}, your 2FA code is {{2}}. It expires in {{3}} minutes.',
      footer: 'Keep your account secure',
    ),
    LibraryTemplate(
      name: 'email_verification',
      category: 'AUTHENTICATION',
      header: 'Email Verification',
      body: 'Hi {{1}}, confirm your email using this code: {{2}}.',
      footer: 'This helps us keep your account safe',
    ),
    LibraryTemplate(
      name: 'reservation_payment_link',
      category: 'MARKETING',
      header: 'Reservation Payment',
      body:
          'Hi, thank you for your reservation. Please complete your payment using the secure payment link below:\n\n{{1}}\n\nOnce the payment is successful, your reservation will be confirmed.',
      footer: 'Thank you for choosing us',
      buttons: [LibraryButton(type: 'URL', text: 'Pay Now', url: '{{1}}')],
    ),
  ];
}
