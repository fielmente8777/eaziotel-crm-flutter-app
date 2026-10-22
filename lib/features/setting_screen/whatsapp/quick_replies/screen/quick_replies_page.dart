// ============================================================
// QUICK REPLIES PAGE  (Settings > WhatsApp > Quick Replies)
//
//   top   : title + "New Reply"
//   tab   : Existing Replies | Create Reply (Edit Reply)
//   list  : search + card (naam, message, kitni photo/video/document,
//           Edit / Delete). Phone 1 column, tablet / window 2 column.
//   form  : name, message, three upload boxes, chosen files (remove with x)
// ============================================================

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../screen/widgets/wa_form_widgets.dart';
import '../controller/quick_reply_controller.dart';
import '../models/quick_reply_response.dart';

class QuickRepliesPage extends StatelessWidget {
  const QuickRepliesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(QuickReplyController());

    return TResponsiveBuilder(
      builder: (context, r) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              r.pagePadding,
              r.pagePadding,
              r.pagePadding,
              8,
            ),
            child: WaPageHeader(
              title: 'Quick Replies',
              subtitle:
                  'Reusable replies with text, images, videos and documents',
              action: ElevatedButton.icon(
                style: waPrimaryButton(context),
                onPressed: c.startCreate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Reply'),
              ),
            ),
          ),
          Obx(
            () => WaSubTabs(
              labels: [
                'Existing Replies (${c.totalReplies})',
                c.isEditing ? 'Edit Reply' : 'Create Reply',
              ],
              selected: c.tab.value.index,
              onSelect: (i) {
                if (i == 0) {
                  c.cancelForm();
                } else if (c.tab.value != QuickReplyTab.form) {
                  c.startCreate();
                }
              },
            ),
          ),
          Expanded(
            child: Obx(
              () => c.tab.value == QuickReplyTab.list
                  ? _ListView(c: c, r: r)
                  : _FormView(c: c, r: r),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LIST
// ============================================================

class _ListView extends StatelessWidget {
  const _ListView({required this.c, required this.r});

  final QuickReplyController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final columns = r.isPhone ? 1 : 2;

    return RefreshIndicator(
      onRefresh: c.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pagePadding),
        children: [
          TextField(
            onChanged: (v) => c.search.value = v,
            decoration: waInput(
              context,
              hint: 'Search replies...',
              prefix: Icon(Icons.search, color: p.subText),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (c.isLoading.value) return _Shimmer(columns: columns);

            if (c.loadFailed.value) {
              return _Empty(
                icon: Icons.cloud_off_outlined,
                text: "Couldn't load quick replies.",
                action: TextButton.icon(
                  onPressed: c.load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              );
            }

            final list = c.replies;
            if (list.isEmpty) {
              return _Empty(
                icon: Icons.bolt_outlined,
                text: c.totalReplies == 0
                    ? 'No quick replies yet. Create one to get started.'
                    : 'No replies match your search.',
                action: c.totalReplies == 0
                    ? ElevatedButton.icon(
                        style: waPrimaryButton(context),
                        onPressed: c.startCreate,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create Reply'),
                      )
                    : null,
              );
            }

            return _Grid(
              columns: columns,
              children: [
                for (final reply in list)
                  _ReplyCard(
                    reply: reply,
                    deleting: c.deletingId.value == reply.id,
                    onEdit: () => c.startEdit(reply),
                    onDelete: () => c.delete(reply),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final width = (box.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({
    required this.reply,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });

  final QuickReply reply;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget pill(int count, String label, IconData icon, Color color) {
      if (count == 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              '$count $label${count > 1 ? 's' : ''}',
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: deleting ? .45 : 1,
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: deleting ? null : onEdit,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.title,
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      if (reply.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reply.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.subText, fontSize: 12.5),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          pill(
                            reply.images.length,
                            'Image',
                            Icons.image_outlined,
                            Colors.purple,
                          ),
                          pill(
                            reply.videos.length,
                            'Video',
                            Icons.videocam_outlined,
                            Colors.orange,
                          ),
                          pill(
                            reply.documents.length,
                            'Document',
                            Icons.description_outlined,
                            Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      visualDensity: VisualDensity.compact,
                      onPressed: deleting ? null : onEdit,
                      icon: Icon(Icons.edit_outlined, color: p.text, size: 20),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                      onPressed: deleting ? null : onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 44, color: p.subText),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.subText),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: _Grid(
        columns: columns,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              height: 104,
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// FORM
// ============================================================

class _FormView extends StatelessWidget {
  const _FormView({required this.c, required this.r});

  final QuickReplyController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final zones = [
      for (final kind in AttachmentKind.values)
        _UploadZone(kind: kind, onTap: () => c.pickFiles(kind)),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.pagePadding),
      child: TCenteredContent(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WaLabel('Reply Name'),
              TextField(
                controller: c.title,
                decoration: waInput(context, hint: 'Welcome Message'),
              ),
              const SizedBox(height: 14),
              const WaLabel('Message text'),
              TextField(
                controller: c.message,
                minLines: 4,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                decoration: waInput(
                  context,
                  hint:
                      'Type your quick reply... (sent as a caption if attachments are included)',
                ),
              ),
              const SizedBox(height: 18),
              Obx(
                () => WaLabel(
                  'Attachments',
                  trailing: Text(
                    'Sends as ${c.messageCount} message'
                    '${c.messageCount > 1 ? 's' : ''} on WhatsApp',
                    style: TextStyle(color: p.subText, fontSize: 11.5),
                  ),
                ),
              ),
              if (r.isPhone)
                Column(
                  children: [
                    for (final z in zones)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: z,
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    for (var i = 0; i < zones.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: zones[i]),
                    ],
                  ],
                ),
              Obx(
                () => c.fileError.value.isEmpty
                    ? const SizedBox(height: 8)
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          c.fileError.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
              ),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final a in c.attachments)
                      _AttachmentChip(
                        attachment: a,
                        onRemove: () => c.removeAttachment(a),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Divider(color: p.border, height: 1),
              const SizedBox(height: 14),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton(
                      style: waOutlineButton(context),
                      onPressed: c.isSaving.value ? null : c.cancelForm,
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      style: waPrimaryButton(context),
                      onPressed: c.canSave && !c.isSaving.value ? c.save : null,
                      icon: Icon(
                        c.isSaving.value ? Icons.hourglass_top : Icons.check,
                        size: 18,
                      ),
                      label: Text(c.isSaving.value ? 'Saving…' : 'Save Reply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.kind, required this.onTap});

  final AttachmentKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: p.inner,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(kind.icon, color: p.primary, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Add ${kind.label.toLowerCase()}',
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '  (${kind.maxMb}MB)',
                      style: TextStyle(color: p.subText, fontSize: 11.5),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.attachment, required this.onRemove});

  final QuickReplyAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final a = attachment;

    Widget thumb;
    if (a.kind == AttachmentKind.image && a.path != null) {
      thumb = Image.file(File(a.path!), fit: BoxFit.cover);
    } else if (a.kind == AttachmentKind.image &&
        (a.media?.url.startsWith('http') ?? false)) {
      thumb = CachedNetworkImage(
        imageUrl: a.media!.url,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => Icon(a.kind.icon, color: p.subText),
      );
    } else {
      thumb = Icon(a.kind.icon, color: p.subText);
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(6, 6, 2, 6),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              color: p.card,
              alignment: Alignment.center,
              child: thumb,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  [
                    a.kind.label,
                    if (a.sizeLabel.isNotEmpty) a.sizeLabel,
                    if (!a.isNew) 'saved',
                  ].join(' · '),
                  style: TextStyle(color: p.subText, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
