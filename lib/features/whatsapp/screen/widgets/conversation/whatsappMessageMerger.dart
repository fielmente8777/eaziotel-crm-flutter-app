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
      // Status kabhi peeche nahi jaana chahiye.
      // Agar naye item ka status "chhota" hai (e.g. naya = sent,
      // purana = read), to purana status wahi rakho, sirf baaki
      // fields (body/media/etc agar zaroorat ho) latest se le lo.
      // ------------------------------------------------------------

      if (item.statusRank >= existing.statusRank) {
        uniqueMessages[item.uniqueKey] = item;
      } else {
        // naya item ka data rakho lekin status purane (behtar) wale ka
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
