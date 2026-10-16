import 'package:eazotel/features/leads/controller/lead_notes_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadDetailsNoteScreen extends StatelessWidget {
  const LeadDetailsNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadDetailsNotesController>();
    final theme = Theme.of(context);

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _notesList(context, controller, theme),

          const SizedBox(height: 12),

          _addNoteButton(context, controller),

          if (controller.isLoading.value) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // NOTES LIST
  // ==========================================================

  Widget _notesList(
    BuildContext context,
    LeadDetailsNotesController controller,
    ThemeData theme,
  ) {
    if (controller.notes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: Column(
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 38,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No notes available',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.notes.length,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (context, index) {
        final note = controller.notes[index];

        return _noteCard(context, controller, index, note);
      },
    );
  }

  // ==========================================================
  // NOTE CARD
  // ==========================================================

  Widget _noteCard(
    BuildContext context,
    LeadDetailsNotesController controller,
    int index,
    dynamic note,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.note_alt_outlined,
              size: 17,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activitySource(note.activitySource),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  note.message ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                ),

                const SizedBox(height: 5),

                Text(
                  _formatDate(note.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    _deleteNoteDialog(context, controller, index);
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ADD NOTE BUTTON
  // ==========================================================

  Widget _addNoteButton(
    BuildContext context,
    LeadDetailsNotesController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.isLoading.value
            ? null
            : () {
                _addNoteDialog(context, controller);
              },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Note', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  // ==========================================================
  // ADD NOTE DIALOG
  // ==========================================================

  void _addNoteDialog(
    BuildContext context,
    LeadDetailsNotesController controller,
  ) {
    final messageController = TextEditingController();

    String activitySource = 'phone_call';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Add Note',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final theme = Theme.of(dialogContext);

        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Note',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        DropdownButtonFormField<String>(
                          value: activitySource,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Activity Source',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'phone_call',
                              child: Text('Phone Call'),
                            ),
                            DropdownMenuItem(
                              value: 'email',
                              child: Text('Email'),
                            ),
                            DropdownMenuItem(
                              value: 'whatsapp',
                              child: Text('WhatsApp'),
                            ),
                            DropdownMenuItem(
                              value: 'meeting',
                              child: Text('Meeting'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              activitySource = value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Enter note',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: const Text('Cancel'),
                            ),

                            const SizedBox(width: 8),

                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () async {
                                        FocusScope.of(
                                          context,
                                        ).unfocus(); // instant keyboard close

                                        final message = messageController.text
                                            .trim();

                                        if (message.isEmpty) {
                                          return;
                                        }

                                        final success = await controller
                                            .createNote(
                                              activitySource: activitySource,
                                              message: message,
                                            );

                                        if (success) {
                                          if (dialogContext.mounted) {
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DELETE NOTE DIALOG
  // ==========================================================

  void _deleteNoteDialog(
    BuildContext context,
    LeadDetailsNotesController controller,
    int index,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Note',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final theme = Theme.of(dialogContext);

        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.80,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Note',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Are you sure you want to delete this note?',
                      style: TextStyle(fontSize: 13),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Cancel'),
                        ),

                        const SizedBox(width: 8),

                        SizedBox(
                          width: 115,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    Navigator.of(dialogContext).pop();

                                    await controller.deleteNote(index);
                                  },
                            child: const Text('Delete'),
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
      },
    );
  }

  // ==========================================================
  // ACTIVITY SOURCE
  // ==========================================================

  String _activitySource(String? source) {
    switch (source) {
      case 'phone_call':
        return 'Phone Call';

      case 'whatsapp':
        return 'WhatsApp';

      case 'email':
        return 'Email';

      case 'meeting':
        return 'Meeting';

      case null:
      case '':
        return 'Note';

      default:
        return source;
    }
  }

  // ==========================================================
  // DATE
  // ==========================================================

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }
}
