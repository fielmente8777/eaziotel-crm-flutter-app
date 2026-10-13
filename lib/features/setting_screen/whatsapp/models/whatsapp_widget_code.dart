// ============================================================
// WHATSAPP WIDGET CODE
//
// "WhatsApp Widget Integration" card me dikhne wala code banata hai.
// Hotel ki ndid, hid aur phone number code ke andar bhar diye jaate hain.
// User ise copy karke apni website me lagata hai.
// ============================================================

class WhatsappWidgetCode {
  const WhatsappWidgetCode({
    required this.ndid,
    required this.hid,
    required this.phone,
  });

  final String ndid;
  final String hid;

  /// "+919759349941" jaisa number
  final String phone;

  /// Option 1: website ke body tag ke band hone se pehle lagane wala script
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

  /// Option 2: khud API call karne wala code
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
