part of '../whatsappController.dart';

// ============================================================
// WHATSAPP FLOW MIXIN
//
// WhatsApp flow (form): load the list and send it in the chat.
// ============================================================

mixin WhatsappFlowMixin
    on WhatsappStateMixin, WhatsappHelpersMixin, WhatsappChatMixin {
  Future<void> getflow() async {
    try {
      isFlowLoading.value = true;
      flowErrorMessage.value = '';

      final dynamic decoded = await WhatsappFlowService.getWhatsappflow(
        hid: hid,
      );

      flow.value = FlowResponseModel.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );

      // The chosen flow is no longer in the list -> clear the choice
      if (selectedFlow == null) selectedFlowId.value = '';
    } catch (e) {
      flowErrorMessage.value = e.toString();
      debugPrint('GET FLOW ERROR: $e');
    } finally {
      isFlowLoading.value = false;
    }
  }

  /// 1. show in the chat right away  2. API  3. temp id -> real id
  /// On failure it removes the local message.
  Future<bool> sendFlowMessage({
    required String conversationId,
    required String phone,
    required String flowId,
    required String body,
    String header = '',
    String footer = '',
    String ctaText = 'Fill Details',
  }) async {
    if (isFlowSending.value) return false;

    final cleanPhone = phone.trim();

    if (conversationId.isEmpty ||
        cleanPhone.isEmpty ||
        flowId.trim().isEmpty ||
        body.trim().isEmpty) {
      return false;
    }

    isFlowSending.value = true;

    final tempId = 'temp_flow_${DateTime.now().microsecondsSinceEpoch}';

    addSentMessageToCurrentConversation(
      phone: cleanPhone,
      text: [
        if (header.trim().isNotEmpty) header.trim(),
        body.trim(),
        if (footer.trim().isNotEmpty) footer.trim(),
      ].join('\n'),
      messageId: tempId,
      conversationId: conversationId,
    );

    try {
      final response = await WhatsappMessageSand.sendWhatsappFlow(
        hid: hid,
        phone: cleanPhone,
        flowId: flowId,
        body: body,
        header: header,
        footer: footer,
        ctaText: ctaText,
      );

      try {
        final realId = jsonDecode(
          response.body,
        )['result']?['docs']?['messageId']?.toString();

        if (realId != null && realId.isNotEmpty) {
          updateMessageId(tempId: tempId, realId: realId);
        }
      } catch (e) {
        debugPrint('FLOW RESPONSE PARSE ERROR: $e');
      }

      return true;
    } catch (e) {
      debugPrint('FLOW SEND ERROR: $e');
      await deleteMessages([tempId]);
      return false;
    } finally {
      isFlowSending.value = false;
    }
  }
}
