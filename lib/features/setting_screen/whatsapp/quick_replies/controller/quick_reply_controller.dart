// ============================================================
// QUICK REPLY CONTROLLER
// Settings > WhatsApp > Quick Replies
//
//   Existing Replies : list + search, Edit / Delete on each reply
//   Create / Edit    : name, message, photo / video / document
//                      (photo up to 5MB, video 10MB, document 10MB)
//
// On Edit, old files (the ones not removed) go back in "media",
// new files are uploaded in "file".
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/whatsapp_action_response.dart';
import '../models/quick_reply_response.dart';
import '../services/quick_reply_service.dart';

enum QuickReplyTab { list, form }

enum AttachmentKind {
  image('Image', 5, Icons.image_outlined),
  video('Video', 10, Icons.videocam_outlined),
  document('Document', 10, Icons.description_outlined);

  const AttachmentKind(this.label, this.maxMb, this.icon);

  final String label;
  final int maxMb;
  final IconData icon;

  int get maxBytes => maxMb * 1024 * 1024;

  static const documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
  ];
}

/// One file in the form: new (path) or already uploaded (media)
class QuickReplyAttachment {
  QuickReplyAttachment.newFile({
    required this.kind,
    required this.name,
    required this.size,
    required String this.path,
  }) : media = null;

  QuickReplyAttachment.existing(this.kind, QuickReplyMedia this.media)
    : name = media.fileName,
      size = media.size,
      path = null;

  final AttachmentKind kind;
  final String name;
  final int size;
  final String? path;
  final QuickReplyMedia? media;

  bool get isNew => path != null;

  String get sizeLabel {
    if (size <= 0) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class QuickReplyController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // LIST
  // ============================================================

  final listResponse = Rxn<QuickReplyListResponse>();
  final isLoading = true.obs;
  final loadFailed = false.obs;
  final search = ''.obs;
  final tab = QuickReplyTab.list.obs;

  /// Which reply is being deleted
  final deletingId = RxnString();

  List<QuickReply> get replies => (listResponse.value?.replies ?? const [])
      .where((r) => r.matches(search.value))
      .toList();

  int get totalReplies => listResponse.value?.replies.length ?? 0;

  @override
  void onInit() {
    super.onInit();
    title.addListener(_touch);
    message.addListener(_touch);
    load();
  }

  @override
  void onClose() {
    title.dispose();
    message.dispose();
    super.onClose();
  }

  Future<void> load() async {
    if (hid.isEmpty) {
      isLoading.value = false;
      loadFailed.value = true;
      return;
    }

    isLoading.value = listResponse.value == null;
    try {
      listResponse.value = await QuickReplyService.getQuickReplies(hid: hid);
      loadFailed.value = false;
    } catch (e) {
      debugPrint('QUICK REPLY: load error: $e');
      loadFailed.value = listResponse.value == null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // FORM
  // ============================================================

  /// null = new reply
  final editingId = RxnString();
  bool get isEditing => editingId.value != null;

  final title = TextEditingController();
  final message = TextEditingController();
  final attachments = <QuickReplyAttachment>[].obs;
  final fileError = ''.obs;
  final isSaving = false.obs;

  final _tick = 0.obs;
  void _touch() => _tick.value++;

  /// How many messages will go on WhatsApp (each file is a separate message)
  int get messageCount => attachments.isEmpty ? 1 : attachments.length;

  bool get canSave {
    _tick.value;
    return title.text.trim().isNotEmpty &&
        (message.text.trim().isNotEmpty || attachments.isNotEmpty);
  }

  List<QuickReplyAttachment> attachmentsOf(AttachmentKind kind) =>
      attachments.where((a) => a.kind == kind).toList();

  void startCreate() {
    editingId.value = null;
    title.clear();
    message.clear();
    attachments.clear();
    fileError.value = '';
    tab.value = QuickReplyTab.form;
  }

  void startEdit(QuickReply reply) {
    editingId.value = reply.id;
    title.text = reply.title;
    message.text = reply.text;
    fileError.value = '';
    attachments.assignAll([
      for (final m in reply.images)
        QuickReplyAttachment.existing(AttachmentKind.image, m),
      for (final m in reply.videos)
        QuickReplyAttachment.existing(AttachmentKind.video, m),
      for (final m in reply.documents)
        QuickReplyAttachment.existing(AttachmentKind.document, m),
    ]);
    tab.value = QuickReplyTab.form;
  }

  void cancelForm() {
    editingId.value = null;
    tab.value = QuickReplyTab.list;
  }

  Future<void> pickFiles(AttachmentKind kind) async {
    final picked = await FilePicker.pickFiles(
      type: switch (kind) {
        AttachmentKind.image => FileType.image,
        AttachmentKind.video => FileType.video,
        AttachmentKind.document => FileType.custom,
      },
      allowedExtensions: kind == AttachmentKind.document
          ? AttachmentKind.documentExtensions
          : null,
    );
    if (picked.isEmpty) return;

    final tooBig = <String>[];
    for (final file in picked) {
      final path = file.path;
      if (path == null) continue;

      final size = file.lengthSync() ?? await file.length() ?? 0;
      if (size > kind.maxBytes) {
        tooBig.add(file.name);
        continue;
      }
      attachments.add(
        QuickReplyAttachment.newFile(
          kind: kind,
          name: file.name,
          size: size,
          path: path,
        ),
      );
    }

    fileError.value = tooBig.isEmpty
        ? ''
        : '${tooBig.join(', ')} ${tooBig.length == 1 ? 'is' : 'are'} larger '
              'than ${kind.maxMb}MB and was skipped.';
  }

  void removeAttachment(QuickReplyAttachment attachment) {
    attachments.remove(attachment);
  }

  Future<void> save() async {
    if (!canSave || isSaving.value) return;

    isSaving.value = true;
    final wasEditing = isEditing;
    try {
      final response = await QuickReplyService.saveQuickReply(
        hid: hid,
        id: editingId.value,
        title: title.text.trim(),
        text: message.text.trim(),
        newFilePaths: [
          for (final a in attachments)
            if (a.isNew) a.path!,
        ],
        keepMedia: [
          for (final a in attachments)
            if (!a.isNew) a.media!,
        ],
      );

      if (response.isSuccess) {
        _toast(
          'Saved',
          response.message(
            wasEditing
                ? 'Quick reply updated successfully'
                : 'Quick reply created successfully',
          ),
        );
        editingId.value = null;
        tab.value = QuickReplyTab.list;
        await load();
        return;
      }

      _toast('Not saved', response.message('Failed to save quick reply.'));
    } catch (e) {
      _toast(
        'Not saved',
        WhatsappActionResponse.errorOf(e, 'Failed to save quick reply.'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> delete(QuickReply reply) async {
    if (deletingId.value != null) return;

    final sure = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete quick reply?'),
        content: Text('"${reply.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;

    deletingId.value = reply.id;
    try {
      final response = await QuickReplyService.deleteQuickReply(
        hid: hid,
        id: reply.id,
      );

      if (response.isSuccess) {
        // On the web the list did not refresh; here it is removed right away
        final current = listResponse.value;
        if (current != null) {
          listResponse.value = QuickReplyListResponse(
            success: current.success,
            responseStatusCode: current.responseStatusCode,
            responseMessage: current.responseMessage,
            replies: current.replies.where((r) => r.id != reply.id).toList(),
          );
        }
        _toast('Deleted', response.message('Quick reply deleted successfully'));
      } else {
        _toast(
          'Not deleted',
          response.message('Failed to delete quick reply.'),
        );
      }
    } catch (e) {
      _toast(
        'Not deleted',
        WhatsappActionResponse.errorOf(e, 'Failed to delete quick reply.'),
      );
    } finally {
      deletingId.value = null;
    }
  }

  void _toast(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
