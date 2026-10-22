// ============================================================
// EMAIL IMPORT SCREEN  (check the emails from Excel / CSV)
//
//   "120 emails found in guests.xlsx"
//   [ a@x.com    ✎ ✕ ]   <- edit or remove
//   [+ Add email]
//   [Continue to compose (118 valid)]
//
// Continue -> a batch is created -> Get.back(result: batch)
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/email_marketing_controller.dart';
import '../services/email_import.dart';

class EmailImportScreen extends StatefulWidget {
  const EmailImportScreen({
    super.key,
    required this.fileName,
    required this.emails,
  });

  final String fileName;
  final List<String> emails;

  @override
  State<EmailImportScreen> createState() => _EmailImportScreenState();
}

class _EmailImportScreenState extends State<EmailImportScreen> {
  final controller = Get.find<EmailMarketingController>();

  late final List<TextEditingController> _fields = [
    for (final e in widget.emails) TextEditingController(text: e),
  ];

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  List<String> get _valid => _fields
      .map((f) => f.text.trim().toLowerCase())
      .where(EmailImport.isEmail)
      .toSet()
      .toList();

  Future<void> _continue() async {
    final emails = _valid;
    if (emails.isEmpty) {
      Get.snackbar(
        'No valid emails',
        'Please add at least one valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final batch = await controller.prepareEmails(
      emails,
      onError: (m) => Get.snackbar(
        'Could not continue',
        m,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TAppColors.error,
        colorText: Colors.white,
      ),
    );

    if (batch != null) Get.back(result: batch);
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final valid = _valid.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Imported recipients')),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: p.card,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(
            () => FilledButton.icon(
              onPressed: controller.isPreparing.value || valid == 0
                  ? null
                  : _continue,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              icon: Icon(
                controller.isPreparing.value
                    ? Icons.hourglass_top_rounded
                    : Icons.edit_note_rounded,
              ),
              label: Text('Continue to compose ($valid valid)'),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart_outlined, color: p.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_fields.length} email${_fields.length == 1 ? '' : 's'} '
                        'found in ${widget.fileName}',
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fix or remove any address before you continue.',
                  style: TextStyle(color: p.subText, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < _fields.length; i++)
                  Padding(
                    key: ObjectKey(_fields[i]),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _fields[i],
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        errorText:
                            _fields[i].text.trim().isEmpty ||
                                EmailImport.isEmail(_fields[i].text)
                            ? null
                            : 'Not a valid email',
                        suffixIcon: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            final removed = _fields[i];
                            setState(() => _fields.remove(removed));
                            // Let the field leave the screen, then close the controller
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => removed.dispose(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _fields.add(TextEditingController())),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add email'),
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
