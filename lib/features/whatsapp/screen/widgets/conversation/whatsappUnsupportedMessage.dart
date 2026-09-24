import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:flutter/material.dart';

class WhatsappUnsupportedMessage extends StatelessWidget {
  final String messageType;
  final String? body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const WhatsappUnsupportedMessage({
    super.key,
    required this.messageType,
    required this.body,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isIncoming
        ? (isDark
            ? const Color(0xff202c33)
            : Colors.white)
        : (isDark
            ? const Color(0xff005c4b)
            : const Color(0xffd9fdd3));

    return Align(
      alignment:
          isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.78,
        ),
        margin: EdgeInsets.only(
          left: isIncoming ? 0 : 35,
          right: isIncoming ? 35 : 0,
          top: 3,
          bottom: 3,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            const Icon(
              Icons.help_outline,
              color: Colors.grey,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unsupported message',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    messageType,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                  ),
                  if ((body ?? '').isNotEmpty)
                    Text(
                      body!,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            WhatsappMessageTime(
              createdAt: createdAt,
              status: status,
              isIncoming: isIncoming,
            ),
          ],
        ),
      ),
    );
  }
}