import 'package:eazotel/features/whatsapp/models/whatsappMessegesLeads.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class WhatsappConversationHeader
    extends StatelessWidget
    implements PreferredSizeWidget {
  final WhatsappConversationModel chat;

  const WhatsappConversationHeader({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: TAppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor:
                Colors.white.withOpacity(0.18),
            child: Text(
              _firstLetter(chat.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name?.isNotEmpty == true
                      ? chat.name!
                      : chat.phone ?? 'WhatsApp',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  chat.phone ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.white.withOpacity(0.80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.videocam_outlined,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.call_outlined,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (_) {},
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'contact',
                child: Text('Contact info'),
              ),
              PopupMenuItem(
                value: 'search',
                child: Text('Search'),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat'),
              ),
            ];
          },
        ),
      ],
    );
  }

  String _firstLetter(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return '?';
    }

    return value.trim()[0].toUpperCase();
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}