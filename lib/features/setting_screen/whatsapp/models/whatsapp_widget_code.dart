// ============================================================
// WHATSAPP WIDGET CODE
//
// Builds the code shown in the "WhatsApp Widget Integration" card.
// The hotel's ndid, hid and phone number are filled into the code.
// The user copies it into their website.
// ============================================================

class WhatsappWidgetCode {
  const WhatsappWidgetCode({
    required this.ndid,
    required this.hid,
    required this.phone,
  });

  final String ndid;
  final String hid;

  /// A number like "+919759349941"
  final String phone;

  /// Option 1: a script to put before the closing body tag of the website
  String get script =>
      '''
<script>
window.eazbotConfig = {
  ndid: "$ndid",
  hid: "$hid",
  phoneNumber: "$phone",
  message: "Hello"
};
</script>

<script src="https://whatsapp-widget-tau.vercel.app/widget/whatsapp.js"></script>''';

  /// Option 2: code that makes the API call itself
  String get manualApi =>
      '''
try {
  const payload = {
    widget: "whatsapp",
    ndid: "$ndid",
    hid: "$hid",
    pageUrl: window.location.href,
    websiteName: window.location.hostname,
    phoneNumber: "$phone",
    message: "Hello, I'm interested in your offer."
  };

  const response = await fetch(
    "https://gian-1eve.onrender.com/api/v1/widget/click",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    }
  );

  const data = await response.json();
  const whatsappUrl = data?.result?.doc?.whatsappUrl;

  if (whatsappUrl) {
    window.open(whatsappUrl, "_blank");
  }
} catch (error) {
  console.error("WhatsApp Click Error:", error);
}''';
}
