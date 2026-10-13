part of '../whatsappController.dart';

// ============================================================
// WHATSAPP STATE MIXIN
//
// Saari state (Rx variables) ek jagah. Baaki mixin inhi ko padhte / badalte hain.
// ============================================================

mixin WhatsappStateMixin on GetxController {
  /// Main class (WhatsappController) me hai
  String get hid;

  /// WhatsappChatMixin me hai (conversation delete karte waqt list ko chahiye)
  void clearCurrentConversation();

  final Whatsapptemplatecontroller templateController = Get.put(
    Whatsapptemplatecontroller(),
  );

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  final RxList<WhatsappConversationModel> conversations =
      <WhatsappConversationModel>[].obs;

  final RxInt selectedTab = 0.obs;

  final RxString searchText = ''.obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  final RxBool isIntegrationLoading = false.obs;

  final RxString integrationErrorMessage = ''.obs;

  /// API ka complete response yahan store hoga.
  final Rxn<Map<String, dynamic>> whatsappIntegration =
      Rxn<Map<String, dynamic>>();

  // ============================================================
  // LEAD RESPONSE
  // ============================================================

  final Rxn<LeadResponseModel> leadResponse = Rxn<LeadResponseModel>();

  // ============================================================
  // FLOW
  // ============================================================

  final Rxn<FlowResponseModel> flow = Rxn<FlowResponseModel>();

  final RxBool isFlowLoading = false.obs;
  final RxString flowErrorMessage = ''.obs;
  final RxString selectedFlowId = ''.obs;

  /// Flow bhejte waqt true rehta hai
  final RxBool isFlowSending = false.obs;

  /// All flows from the API (empty list if nothing loaded)
  List<FlowItemModel> get flows => flow.value?.result?.docs?.flows ?? [];

  /// The flow picked in the dropdown (null if none)
  FlowItemModel? get selectedFlow {
    final id = selectedFlowId.value;
    if (id.isEmpty) return null;
    return flows.firstWhereOrNull((f) => f.flowId == id);
  }

  /// Lead response se nikale gaye saare NDID (cache).
  Set<String> _leadNdids = <String>{};

  Worker? _leadWorker;

  // ============================================================
  // SOCKET MESSAGES
  // ============================================================

  final RxList<WhatsappSocketMessageModel> socketMessages =
      <WhatsappSocketMessageModel>[].obs;

  final Rxn<WhatsappSocketMessageModel> latestSocketMessage =
      Rxn<WhatsappSocketMessageModel>();

  final RxMap<String, WhatsappSocketMessageModel>
  latestSocketMessagesByConversation =
      <String, WhatsappSocketMessageModel>{}.obs;

  // ============================================================
  // CURRENT OPEN CONVERSATION
  // ============================================================

  final RxString currentConversationId = ''.obs;

  // ============================================================
  // API MESSAGES
  // ============================================================

  final RxBool isMessagesLoading = false.obs;

  final RxString messagesErrorMessage = ''.obs;

  final Rxn<WhatsappMessagesResponseModel> messagesResponse =
      Rxn<WhatsappMessagesResponseModel>();
}
