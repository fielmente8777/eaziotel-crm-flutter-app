import 'package:eazotel/features/whatsapp/models/WhatsappSocketMessageModel.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageItem.dart';

class WhatsappMessageMerger {
  WhatsappMessageMerger._();

  static List<WhatsappMessageItem> merge({
    required List<dynamic> apiMessages,
    required List<WhatsappSocketMessageModel> socketMessages,
  }) {
    final Map<String, WhatsappMessageItem> uniqueMessages = {};

    void addOrKeepBest(WhatsappMessageItem item) {
      final existing = uniqueMessages[item.uniqueKey];

      if (existing == null) {
        uniqueMessages[item.uniqueKey] = item;
        return;
      }

      // ------------------------------------------------------------
      // The status must never go backwards.
      // If the new item's status is "lower" (e.g. new = sent,
      // old = read), keep the old status and take only the other
      // fields (body/media/etc if needed) from the latest.
      // ------------------------------------------------------------

      if (item.statusRank >= existing.statusRank) {
        uniqueMessages[item.uniqueKey] = item;
      } else {
        // keep the new item's data but the old (better) status
        uniqueMessages[item.uniqueKey] = item.copyWith(
          status: existing.status,
          updatedAt: existing.updatedAt,
        );
      }
    }

    // API MESSAGES
    for (final message in apiMessages) {
      addOrKeepBest(WhatsappMessageItem.fromApi(message));
    }

    // SOCKET MESSAGES
    for (final message in socketMessages) {
      addOrKeepBest(WhatsappMessageItem.fromSocket(message));
    }

    // SORT BY DATE (newest first)
    final result = uniqueMessages.values.toList();

    result.sort((a, b) {
      final aDate =
          DateTime.tryParse(a.createdAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final bDate =
          DateTime.tryParse(b.createdAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return result;
  }
}
