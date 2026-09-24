import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageItem.dart';

class WhatsappMessageMerger {
  WhatsappMessageMerger._();

  static List<WhatsappMessageItem> merge({
    required List<dynamic> apiMessages,
    required List<WhatsappSocketMessageModel> socketMessages,
  }) {
    final Map<String, WhatsappMessageItem> uniqueMessages = {};

    // API MESSAGES
    for (final message in apiMessages) {
      final item = WhatsappMessageItem.fromApi(message);
      uniqueMessages[item.uniqueKey] = item;
    }

    // SOCKET MESSAGES
    for (final message in socketMessages) {
      final item = WhatsappMessageItem.fromSocket(message);
      uniqueMessages[item.uniqueKey] = item;
    }

    // SORT BY DATE (newest first)
    final result = uniqueMessages.values.toList();

    result.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final bDate = DateTime.tryParse(b.createdAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return result;
  }
}