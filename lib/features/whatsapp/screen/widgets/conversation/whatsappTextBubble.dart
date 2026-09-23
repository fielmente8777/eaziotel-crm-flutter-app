import 'package:eazotel/features/whatsapp/screen/widgets/conversation/whatsappMessageTime.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class WhatsappTextBubble extends StatelessWidget {
  final String body;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const WhatsappTextBubble({
    super.key,
    required this.body,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    final bubbleColor = isIncoming
        ? (isDark
            ? TAppColors.darkCard
            : Colors.white)
        : (isDark
            ? const Color(0xff005c4b)
            : const Color(0xffd9fdd3));

    return Align(
      alignment: isIncoming
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.78,
        ),
        child: Container(
          margin: EdgeInsets.only(
            left: isIncoming ? 0 : 40,
            right: isIncoming ? 40 : 0,
            top: 2,
            bottom: 2,
          ),
          padding:
              const EdgeInsets.fromLTRB(
            10,
            7,
            8,
            6,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius:
                BorderRadius.only(
              topLeft:
                  const Radius.circular(9),
              topRight:
                  const Radius.circular(9),
              bottomLeft: Radius.circular(
                isIncoming ? 2 : 9,
              ),
              bottomRight: Radius.circular(
                isIncoming ? 9 : 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              WhatsappMessageTime(
                createdAt: createdAt,
                status: status,
                isIncoming: isIncoming,
              ),
            ],
          ),
        ),
      ),
    );
  }
}