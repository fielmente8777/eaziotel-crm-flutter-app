 import 'package:eazotel/features/whatsapp/controller/WhatsappConversationMesseg.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class WhatsappMessageInput
    extends StatelessWidget {
  final WhatsappConversationDetailController
      controller;

  const WhatsappMessageInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        8,
        6,
        8,
        6,
      ),
      color:
          Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints:
                  const BoxConstraints(
                minHeight: 48,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? TAppColors.darkCard
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? TAppColors.darkBorder
                      : TAppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons
                          .emoji_emotions_outlined,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller:
                          controller.textController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction:
                          TextInputAction.newline,
                      decoration:
                          const InputDecoration(
                        hintText: 'Message',
                        border:
                            InputBorder.none,
                        enabledBorder:
                            InputBorder.none,
                        focusedBorder:
                            InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.attach_file,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons
                          .camera_alt_outlined,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TAppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }
}