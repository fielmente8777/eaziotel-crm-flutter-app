import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappLeadFilterController extends GetxController {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  // Chat se aane wali values
  final String conversationId;
  final String hid;
  final String ndid;
  final String contact;
  final String? name;

  WhatsappLeadFilterController({
    required this.conversationId,
    required this.hid,
    required this.ndid,
    required this.contact,
    this.name,
    String? status,
    String? assignee,
  }) {
    selectedStage.value = status?.trim() ?? '';
    selectedAttemptedBy.value = assignee?.trim() ?? '';
  }

  final selectedAttemptedBy = ''.obs;
  final selectedStage = ''.obs;
  final selectedTurnAwayCode = ''.obs;
  final Rxn<DateTime> selectedFollowUpDate = Rxn<DateTime>();

  final List<String> stageList = [
    'Open Queries',
    'Contacted',
    'Converted',
    'Out Of Budget',
    'Potential For Later',
    'Quotation Provided',
    'Dead Lead',
    'Date Sold Out',
    'Duplicate',
    'Follow Up',
    'Not Respond',
    'Qualified',
    'Not Qualified',
    'Turn Away',
    'Closure',
    'Hot',
  ];

  final List<String> turnAwayCodeList = [
    'GD',
    'JE',
    'LC',
    'NR',
    'Others',
    'DD',
    'CRP',
    'TA',
    'CP',
    'LOS',
    'GE',
    'RX',
  ];

  // ============================================================
  // COMMON UPDATE API
  // PUT /api/v1/leads/{conversationId}/update?hid={hid}
  // ============================================================
  Future<bool> updateLead(Map<String, dynamic> fields) async {
    if (conversationId.isEmpty || hid.isEmpty) {
      debugPrint('❌ conversationId ya hid empty hai');
      return false;
    }

    final String endpoint = '/api/v1/leads/$conversationId/update?hid=$hid';

    final Map<String, dynamic> body = {
      'Contact': contact,
      'Name': name,
      'ndid': ndid,
      'conversationId': conversationId,
      'hId': hid,
      ...fields, // status, assignee, notes, followUpDate...
    };

    try {
      final response = await ApiClient.put(
        endpoint,
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2, // gian-1eve.onrender.com
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ WHATSAPP LEAD UPDATED');
        return true;
      }

      debugPrint('❌ UPDATE FAILED: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      debugPrint('❌ UPDATE ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // ATTEMPTED BY
  // ============================================================
  Future<void> onAttemptedByChanged(UserModel user) async {
    final String name = user.displayName?.trim() ?? '';
    if (name.isEmpty) return;

    selectedAttemptedBy.value = name;

    await updateLead({
      'assignee': name,
      'assigneeEmail': user.emailId?.trim() ?? '',
      'assigneeNumber': user.phone?.trim() ?? '',
    });
  }

  // ============================================================
  // STAGE
  // ============================================================
  Future<void> onStageChanged(String stage) async {
    if (stage.trim().isEmpty) return;
    selectedStage.value = stage;
    await updateLead({'status': stage});
  }

  // ============================================================
  // TURN AWAY CODE
  // ============================================================
  Future<void> onTurnAwayCodeChanged(String code) async {
    if (code.trim().isEmpty) return;
    selectedTurnAwayCode.value = code;

    final ok = await updateLead({'status': 'Turn Away', 'turnAwayCode': code});
    if (ok) selectedStage.value = 'Turn Away';
  }

  // ============================================================
  // FOLLOW UP
  // ============================================================
  Future<void> selectFollowUpDateTime(BuildContext context) async {
    final now = DateTime.now();
    var initial = selectedFollowUpDate.value ?? now;
    if (initial.isBefore(now)) initial = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (pickedTime == null) return;

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final ok = await updateLead({
      'status': 'Follow Up',
      'followUpDate': selected.toUtc().toIso8601String(),
    });

    if (ok) {
      selectedFollowUpDate.value = selected;
      selectedStage.value = 'Follow Up';
    }
  }

  // ============================================================
  // NOTES (future ke liye ready)
  // ============================================================
  Future<bool> addNote(String message, {String source = 'whatsapp'}) {
    return updateLead({
      'notes': [
        {
          'activitySource': source,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'message': message,
        },
      ],
    });
  }
}
