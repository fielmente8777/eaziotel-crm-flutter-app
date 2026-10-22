part of '../whatsappController.dart';

// ============================================================
// WHATSAPP STATE MIXIN
//
// All state (Rx variables) in one place. The other mixins read / change these.
// ============================================================

mixin WhatsappStateMixin on GetxController {
  /// It is in the main class (WhatsappController)
  String get hid;

  /// It is in WhatsappChatMixin (the list needs it when deleting a conversation)
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

  /// The full API response is stored here.
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

  /// Stays true while a flow is being sent
  final RxBool isFlowSending = false.obs;

  /// All flows from the API (empty list if nothing loaded)
  List<FlowItemModel> get flows => flow.value?.result?.docs?.flows ?? [];

  /// The flow picked in the dropdown (null if none)
  FlowItemModel? get selectedFlow {
    final id = selectedFlowId.value;
    if (id.isEmpty) return null;
    return flows.firstWhereOrNull((f) => f.flowId == id);
  }

  /// All NDIDs taken from the lead response (cache).
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

  /// A new incoming message arrived (and that chat is not open).
  /// The app's notifications (bell + banner) listen to this.
  void Function(
    WhatsappConversationModel chat,
    WhatsappSocketMessageModel message,
  )?
  onIncomingMessage;

  // ============================================================
  // API MESSAGES
  // ============================================================

  final RxBool isMessagesLoading = false.obs;

  final RxString messagesErrorMessage = ''.obs;

  final Rxn<WhatsappMessagesResponseModel> messagesResponse =
      Rxn<WhatsappMessagesResponseModel>();
}
