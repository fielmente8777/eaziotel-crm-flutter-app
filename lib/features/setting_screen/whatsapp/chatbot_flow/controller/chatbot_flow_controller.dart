// ============================================================
// CHATBOT FLOW CONTROLLER  (Settings > WhatsApp > WhatsApp Flow)
//
//   load        : server se nodes + edges
//   addNode     : naya step (chune hue step ke right me)
//   moveNode    : canvas par kheench kar jagah badlo
//   saveNode    : editor ka "Save" (data + kaun sa rasta kahan jaata hai)
//   deleteNode  : step aur uske saare teer hatao
//   publish     : sab kuch server par (web jaisa form-data)
//
// "Publish" tak sab badlav sirf app me rehte hain (hasChanges).
// ============================================================

import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/whatsapp/models/FlowResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/whatsapp_setting_controller.dart';
import '../../models/whatsapp_action_response.dart';
import '../../services/whatsapp_setting_service.dart';
import '../models/chatbot_flow_models.dart';
import '../services/chatbot_flow_service.dart';

enum ChatbotView { canvas, list }

class ChatbotFlowController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;
  String get ndid => dashboard.user.value?.profile.ndid ?? '';

  // ============================================================
  // STATE
  // ============================================================

  final flowResponse = Rxn<ChatbotFlowResponse>();
  final nodes = <ChatbotNode>[].obs;
  final edges = <ChatbotEdge>[].obs;

  final isLoading = true.obs;
  final loadFailed = false.obs;
  final isPublishing = false.obs;
  final hasChanges = false.obs;

  /// Canvas (tablet / window) ya list (phone)
  final view = ChatbotView.canvas.obs;

  /// Abhi chuna hua step (naya step iske right me banta hai)
  final selectedId = RxnString();

  /// Send Message ki nayi files: blockId -> rasta (Publish par upload)
  final Map<String, String> pendingFiles = {};

  /// Form flow ki list (Flow step ke dropdown ke liye)
  final formFlows = <FlowItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (hid.isEmpty) {
      isLoading.value = false;
      loadFailed.value = true;
      return;
    }

    isLoading.value = true;
    try {
      final response = await ChatbotFlowService.getChatbotFlow(hid: hid);
      flowResponse.value = response;
      nodes.assignAll(response.nodes);
      edges.assignAll(response.edges);
      pendingFiles.clear();
      hasChanges.value = false;
      loadFailed.value = false;
    } catch (e) {
      debugPrint('CHATBOT FLOW: load error: $e');
      loadFailed.value = flowResponse.value == null;
    } finally {
      isLoading.value = false;
    }

    _loadFormFlows();
  }

  Future<void> _loadFormFlows() async {
    try {
      final response = await WhatsappSettingService.getFlows(hid: hid);
      formFlows.assignAll(response.result?.docs?.flows ?? []);
    } catch (e) {
      debugPrint('CHATBOT FLOW: form flows error: $e');
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  ChatbotNode? nodeById(String? id) =>
      id == null ? null : nodes.firstWhereOrNull((n) => n.id == id);

  /// Is rasta se kaun sa step juda hai
  String? targetOf(String sourceId, String? handle) => edges
      .firstWhereOrNull(
        (e) => e.source == sourceId && e.handleKey == (handle ?? ''),
      )
      ?.target;

  /// Kisi ne is step par teer nahi lagaya -> yahi se shuru
  bool isStart(String id) => !edges.any((e) => e.target == id);

  /// Dropdown / card par step ka naam: "2. Buttons: Ask a question"
  String titleOf(ChatbotNode node) {
    final index = nodes.indexOf(node) + 1;
    final text = node.summary.split('\n').first.trim();
    final short = text.length > 28 ? '${text.substring(0, 28)}…' : text;
    return '$index. ${node.type.label}${short.isEmpty ? '' : ': $short'}';
  }

  /// Saved photo ka link (Send Message me media.mediaId)
  String mediaUrl(String mediaId) =>
      '${BaseUrl.production2}${WhatsappApiEndpoint.media(mediaId)}?ndid=$ndid';

  void _changed() {
    hasChanges.value = true;
    nodes.refresh();
    edges.refresh();
  }

  // ============================================================
  // STEPS
  // ============================================================

  ChatbotNode addNode(ChatbotNodeType type) {
    final anchor = nodeById(selectedId.value) ?? nodes.lastOrNull;
    final x = anchor == null ? 80.0 : anchor.x + 320;
    final y = anchor == null ? 80.0 : anchor.y;

    final node = ChatbotNode.create(type, x, y);
    nodes.add(node);
    selectedId.value = node.id;
    _changed();
    return node;
  }

  void moveNode(String id, Offset delta) {
    final node = nodeById(id);
    if (node == null) return;
    node.x += delta.dx;
    node.y += delta.dy;
    hasChanges.value = true;
    nodes.refresh();
  }

  void deleteNode(String id) {
    nodes.removeWhere((n) => n.id == id);
    edges.removeWhere((e) => e.source == id || e.target == id);
    if (selectedId.value == id) selectedId.value = null;
    _changed();
  }

  /// Editor ka Save.
  /// [connections]: rasta (handle key) -> kis step par jaana hai (null = kahin nahi)
  Future<void> saveNode({
    required String id,
    required Map<String, dynamic> data,
    required Map<String, String?> connections,
  }) async {
    final node = nodeById(id);
    if (node == null) return;

    // Send Message: nayi files ko Publish ke liye rakh lo
    for (final block in chatbotList(data['blocks'])) {
      if (block is! Map) continue;
      final path = block.remove('_localPath');
      if (path != null) pendingFiles['${block['id']}'] = '$path';
    }

    // Carousel: nayi photo pehle upload karo (web jaisa)
    final cards = chatbotList(
      chatbotMap(chatbotMap(data['interactive'])['action'])['cards'],
    );
    for (final card in cards) {
      if (card is! Map) continue;
      final path = card.remove('_localImage');
      if (path == null) continue;
      final link = await ChatbotFlowService.uploadImage(path: '$path');
      if (link == null) {
        _toast('Image not uploaded', 'Please try the card image again.');
        continue;
      }
      card['header'] = {
        'type': 'image',
        'image': {'link': link},
      };
    }

    node.data = data;

    // Ab jo rasta bache hi nahi, unke teer hatao; baaki naye lagao
    final outputs = node.outputs.map((o) => o.key).toSet();
    edges.removeWhere((e) => e.source == id && !outputs.contains(e.handleKey));
    for (final entry in connections.entries) {
      if (!outputs.contains(entry.key)) continue;
      _connect(id, entry.key.isEmpty ? null : entry.key, entry.value);
    }

    _changed();
  }

  void _connect(String source, String? handle, String? target) {
    edges.removeWhere(
      (e) => e.source == source && e.handleKey == (handle ?? ''),
    );
    if (target == null || target == source || nodeById(target) == null) return;
    edges.add(
      ChatbotEdge.connect(source: source, sourceHandle: handle, target: target),
    );
  }

  // ============================================================
  // PUBLISH
  // ============================================================

  Future<void> publish() async {
    if (isPublishing.value) return;

    final empty = nodes.where(
      (n) =>
          n.type == ChatbotNodeType.sendMessage &&
          chatbotList(n.data['blocks']).isEmpty,
    );
    if (empty.isNotEmpty) {
      _toast('Check the flow', '"${titleOf(empty.first)}" has no content yet.');
      return;
    }

    isPublishing.value = true;
    try {
      final response = await ChatbotFlowService.publishChatbotFlow(
        hid: hid,
        nodes: nodes,
        edges: edges,
        files: Map.of(pendingFiles),
      );

      if (response.isSuccess) {
        _toast('Published', response.message('WhatsApp flow published.'));
        await load();

        // Auto message ke "Flow" dropdown me naya flow aa jaaye
        if (Get.isRegistered<WhatsappSettingController>()) {
          Get.find<WhatsappSettingController>().load();
        }
        return;
      }
      _toast('Not published', response.message('Failed to publish flow.'));
    } catch (e) {
      _toast(
        'Not published',
        WhatsappActionResponse.errorOf(e, 'Failed to publish flow.'),
      );
    } finally {
      isPublishing.value = false;
    }
  }

  void _toast(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
