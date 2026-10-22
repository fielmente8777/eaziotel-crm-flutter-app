import 'package:eazotel/features/whatsapp/controller/WhatsappImageController.dart.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/Whatsappaudiomessage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappImageMessage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappInteractiveMessage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappLocationMessage.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageItem.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappTextBubble.dart';
import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappVideoMessage.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class WhatsappMessageBubble extends StatelessWidget {
  final WhatsappMessageItem message;
  final String? ndid;

  const WhatsappMessageBubble({
    super.key,
    required this.message,
    required this.ndid,
  });

  @override
  Widget build(BuildContext context) {
    final messageId = message.messageId ?? message.id ?? '';

    // TEXT
    if (message.isText) {
      // Show text with a Maps link (location sent from the app) in a map card
      final linkLocation = WhatsappLocationMessage.parseMapsLink(
        message.body ?? '',
      );

      if (linkLocation != null) {
        return WhatsappLocationMessage(
          location: linkLocation,
          body: message.body,
          createdAt: message.createdAt,
          status: message.status,
          isIncoming: message.isIncoming,
        );
      }

      return WhatsappTextBubble(
        body: message.body ?? '',
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
      );
    }

    // IMAGE
    if (message.isImage) {
      return WhatsappImageMessage(
        key: ValueKey('image_${message.uniqueKey}'),
        messageId: messageId,
        media: message.media,
        body: message.body,
        createdAt: message.createdAt,
        isIncoming: message.isIncoming,
        ndid: ndid,
        status: message.status,
      );
    }

    // STICKER
    if (message.isSticker) {
      return WhatsappImageMessage(
        key: ValueKey('sticker_${message.uniqueKey}'),
        messageId: messageId,
        media: message.media,
        body: message.body,
        createdAt: message.createdAt,
        isIncoming: message.isIncoming,
        ndid: ndid,
        type: WhatsappMediaType.sticker,
      );
    }

    // VIDEO
    if (message.isVideo) {
      return WhatsappVideoMessage(
        key: ValueKey('video_${message.uniqueKey}'),
        messageId: messageId,
        media: message.media,
        body: message.body,
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
        ndid: ndid,
      );
    }

    // AUDIO
    if (message.isAudio) {
      return WhatsappAudioMessage(
        key: ValueKey('audio_${message.uniqueKey}'),
        messageId: messageId,
        media: message.media,
        body: message.body,
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
        ndid: ndid,
      );
    }

    // // DOCUMENT
    // if (message.isDocument) {
    //   return WhatsappDocumentMessage(
    //     key: ValueKey('document_${message.uniqueKey}'),
    //     messageId: messageId,
    //     media: message.media,
    //     body: message.body,
    //     createdAt: message.createdAt,
    //     status: message.status,
    //     isIncoming: message.isIncoming,
    //     ndid: ndid,
    //   );
    // }

    // LOCATION
    if (message.isLocation) {
      return WhatsappLocationMessage(
        location: message.location,
        body: message.body,
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
      );
    }

    // CONTACTS
    if (message.isContacts) {
      return WhatsappContactsMessage(
        contacts: message.contacts,
        body: message.body,
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
      );
    }

    // INTERACTIVE
    if (message.isInteractive) {
      return WhatsappInteractiveMessage(
        interactive: message.interactive,
        createdAt: message.createdAt,
        status: message.status,
        isIncoming: message.isIncoming,
      );
    }

    // FALLBACK
    return _WhatsappUnknownMessage(message: message);
  }
}

// ================================================================
// UNKNOWN MESSAGE
// ================================================================
class _WhatsappUnknownMessage extends StatelessWidget {
  final WhatsappMessageItem message;

  const _WhatsappUnknownMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final isIncoming = message.isIncoming;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isIncoming
        ? (isDark ? TAppColors.darkCard : Colors.white)
        : (isDark ? const Color(0xff005c4b) : const Color(0xffd9fdd3));

    final textColor = isDark ? Colors.white : Colors.black87;

    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: EdgeInsets.only(
            left: isIncoming ? 0 : 40,
            right: isIncoming ? 40 : 0,
            top: 2,
            bottom: 2,
          ),
          padding: const EdgeInsets.fromLTRB(10, 7, 8, 6),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(9),
              topRight: const Radius.circular(9),
              bottomLeft: Radius.circular(isIncoming ? 2 : 9),
              bottomRight: Radius.circular(isIncoming ? 9 : 2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 18, color: textColor),

              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  message.body ?? 'Unsupported message',
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CONTACTS MESSAGE
// ================================================================

class WhatsappContactsMessage extends StatelessWidget {
  final dynamic contacts;
  final String? body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const WhatsappContactsMessage({
    super.key,
    required this.contacts,
    required this.body,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  List<dynamic> get contactList {
    if (contacts is List) return contacts;
    if (contacts is Map) return [contacts];
    return [];
  }

  String _value(dynamic contact, String key) {
    if (contact is Map) {
      final value = contact[key];
      if (value != null) return value.toString();
      return '';
    }

    try {
      switch (key) {
        case 'name':
          return contact.name?.toString() ?? '';
        case 'phone':
          return contact.phone?.toString() ?? '';
      }
    } catch (_) {}

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final list = contactList;

    final name = list.isEmpty ? '' : _value(list.first, 'name');
    final phone = list.isEmpty ? '' : _value(list.first, 'phone');

    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        margin: EdgeInsets.only(
          left: isIncoming ? 0 : 40,
          right: isIncoming ? 40 : 0,
          top: 3,
          bottom: 3,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isIncoming
              ? Theme.of(context).cardColor
              : const Color(0xffd9fdd3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xff00a884),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Contact',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (list.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                '${list.length} contacts',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: WhatsappMessageTime(
                createdAt: createdAt,
                status: status,
                isIncoming: isIncoming,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
