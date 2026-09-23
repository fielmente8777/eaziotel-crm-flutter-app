import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:flutter/material.dart';

class WhatsappInteractiveMessage extends StatelessWidget {
  final WhatsappInteractiveModel? interactive;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const WhatsappInteractiveMessage({
    super.key,
    required this.interactive,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive == null) {
      return const SizedBox.shrink();
    }

    final type = interactive!.type?.toLowerCase();

    if (type == 'carousel') {
      return _WhatsappCarouselMessage(
        interactive: interactive!,
        createdAt: createdAt,
        status: status,
        isIncoming: isIncoming,
      );
    }

    return _WhatsappListMessage(
      interactive: interactive!,
      createdAt: createdAt,
      status: status,
      isIncoming: isIncoming,
    );
  }
}

// ============================================================
// LIST MESSAGE
// ============================================================

class _WhatsappListMessage extends StatelessWidget {
  final WhatsappInteractiveModel interactive;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const _WhatsappListMessage({
    required this.interactive,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bodyText = interactive.body?.text ?? '';

    final buttonText = interactive.action?.button ?? '';

    final sections = interactive.action?.sections ?? [];

    final bubbleColor = isIncoming
        ? (isDark ? const Color(0xff202c33) : Colors.white)
        : (isDark ? const Color(0xff005c4b) : const Color(0xffd9fdd3));

    final textColor = isDark ? Colors.white : Colors.black87;

    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          margin: EdgeInsets.only(
            left: isIncoming ? 0 : 35,
            right: isIncoming ? 35 : 0,
            top: 3,
            bottom: 3,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(9),
              topRight: const Radius.circular(9),
              bottomLeft: Radius.circular(isIncoming ? 2 : 9),
              bottomRight: Radius.circular(isIncoming ? 9 : 2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 8, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bodyText.isNotEmpty)
                  Text(
                    bodyText,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: textColor,
                    ),
                  ),

                if (sections.isNotEmpty) ...[
                  const SizedBox(height: 10),

                  Container(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),

                  const SizedBox(height: 5),

                  for (final section in sections)
                    _WhatsappListSection(
                      section: section,
                      isDark: isDark,
                      textColor: textColor,
                    ),
                ],

                if (buttonText.isNotEmpty) ...[
                  const SizedBox(height: 6),

                  Container(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),

                  const SizedBox(height: 3),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _showListOptions(context, sections);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Color(0xff00a884),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 2),

                Align(
                  alignment: Alignment.centerRight,
                  child: _WhatsappMessageMeta(
                    createdAt: createdAt,
                    status: status,
                    isIncoming: isIncoming,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showListOptions(
    BuildContext context,
    List<WhatsappInteractiveSectionModel> sections,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _WhatsappListBottomSheet(sections: sections);
      },
    );
  }
}

// ============================================================
// LIST SECTION
// ============================================================

class _WhatsappListSection extends StatelessWidget {
  final WhatsappInteractiveSectionModel section;
  final bool isDark;
  final Color textColor;

  const _WhatsappListSection({
    required this.section,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final title = section.title ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 5),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),

        for (final row in section.rows)
          _WhatsappListRow(row: row, isDark: isDark, textColor: textColor),
      ],
    );
  }
}

// ============================================================
// LIST ROW
// ============================================================

class _WhatsappListRow extends StatelessWidget {
  final WhatsappInteractiveRowModel row;
  final bool isDark;
  final Color textColor;

  const _WhatsappListRow({
    required this.row,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final title = row.title ?? '';
    final description = row.description ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 6, right: 9),
            decoration: const BoxDecoration(
              color: Color(0xff00a884),
              shape: BoxShape.circle,
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),

                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LIST BOTTOM SHEET
// ============================================================

class _WhatsappListBottomSheet extends StatelessWidget {
  final List<WhatsappInteractiveSectionModel> sections;

  const _WhatsappListBottomSheet({required this.sections});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff202c33) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Select an option',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((section.title ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 5,
                            left: 4,
                          ),
                          child: Text(
                            section.title!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),

                      for (final row in section.rows)
                        _WhatsappBottomSheetRow(row: row),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOTTOM SHEET ROW
// ============================================================

class _WhatsappBottomSheetRow extends StatelessWidget {
  final WhatsappInteractiveRowModel row;

  const _WhatsappBottomSheetRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        debugPrint(
          'Interactive row selected: '
          '${row.id}',
        );

        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff111b21) : const Color(0xfff5f5f5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  if ((row.description ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        row.description!,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Color(0xff00a884)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CAROUSEL MESSAGE
// ============================================================

class _WhatsappCarouselMessage extends StatelessWidget {
  final WhatsappInteractiveModel interactive;
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const _WhatsappCarouselMessage({
    required this.interactive,
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bodyText = interactive.body?.text ?? '';

    final cards = interactive.action?.cards ?? [];

    final bubbleColor = isIncoming
        ? (isDark ? const Color(0xff202c33) : Colors.white)
        : (isDark ? const Color(0xff005c4b) : const Color(0xffd9fdd3));

    final textColor = isDark ? Colors.white : Colors.black87;

    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.90,
        ),
        child: Container(
          margin: EdgeInsets.only(
            left: isIncoming ? 0 : 25,
            right: isIncoming ? 25 : 0,
            top: 3,
            bottom: 3,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(9),
              topRight: const Radius.circular(9),
              bottomLeft: Radius.circular(isIncoming ? 2 : 9),
              bottomRight: Radius.circular(isIncoming ? 9 : 2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 8, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bodyText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Text(
                      bodyText,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: textColor,
                      ),
                    ),
                  ),

                if (cards.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int index = 0; index < cards.length; index++) ...[
                          _WhatsappCarouselCard(card: cards[index]),
                          if (index != cards.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerRight,
                  child: _WhatsappMessageMeta(
                    createdAt: createdAt,
                    status: status,
                    isIncoming: isIncoming,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CAROUSEL CARD
// ============================================================

class _WhatsappCarouselCard extends StatelessWidget {
  final WhatsappInteractiveCardModel card;

  const _WhatsappCarouselCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageUrl = card.header?.image?.link;

    final bodyText = card.body?.text ?? '';

    final buttons = card.action?.buttons ?? [];

    return Container(
      width: 235,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111b21) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          SizedBox(
            height: 145,
            width: double.infinity,
            child: _CarouselImage(imageUrl: imageUrl),
          ),

          // BODY
          if (bodyText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 6),
              child: Text(
                bodyText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

          // const Spacer(),

          // BUTTONS
          if (buttons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
              child: Column(
                children: [
                  for (final button in buttons) _CarouselButton(button: button),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CAROUSEL IMAGE
// ============================================================

class _CarouselImage extends StatelessWidget {
  final String? imageUrl;

  const _CarouselImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 42, color: Colors.black38),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,

      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: Colors.black12,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },

      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.black12,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: Colors.black38,
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// CAROUSEL BUTTON
// ============================================================

class _CarouselButton extends StatelessWidget {
  final WhatsappInteractiveButtonModel button;

  const _CarouselButton({required this.button});

  @override
  Widget build(BuildContext context) {
    final title = button.reply?.title ?? '';

    if (title.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 38,
      child: OutlinedButton(
        onPressed: () {
          debugPrint(
            'Carousel button clicked: '
            '${button.reply?.id}',
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff00a884),
          side: const BorderSide(color: Color(0xff00a884)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ============================================================
// MESSAGE META
// ============================================================

class _WhatsappMessageMeta extends StatelessWidget {
  final String? createdAt;
  final String? status;
  final bool isIncoming;

  const _WhatsappMessageMeta({
    required this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(createdAt);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),

        if (!isIncoming)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: _WhatsappStatusIcon(status: status),
          ),
      ],
    );
  }
}

// ============================================================
// STATUS ICON
// ============================================================

class _WhatsappStatusIcon extends StatelessWidget {
  final String? status;

  const _WhatsappStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final value = status?.toLowerCase();

    if (value == 'read') {
      return const Icon(Icons.done_all, size: 15, color: Color(0xff53bdeb));
    }

    if (value == 'delivered') {
      return const Icon(Icons.done_all, size: 15, color: Colors.grey);
    }

    if (value == 'sent') {
      return const Icon(Icons.done, size: 15, color: Colors.grey);
    }

    return const SizedBox.shrink();
  }
}

// ============================================================
// TIME FORMAT
// ============================================================

String _formatTime(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }

  final date = DateTime.tryParse(value);

  if (date == null) {
    return '';
  }

  final localDate = date.toLocal();

  final hour = localDate.hour;

  final minute = localDate.minute.toString().padLeft(2, '0');

  final period = hour >= 12 ? 'PM' : 'AM';

  final displayHour = hour % 12 == 0 ? 12 : hour % 12;

  return '$displayHour:$minute $period';
}
