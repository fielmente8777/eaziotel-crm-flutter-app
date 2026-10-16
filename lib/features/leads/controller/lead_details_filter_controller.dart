import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadFilterController extends GetxController {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  LeadModel? currentLead;

  String _currentLeadId = '';

  // ============================================================
  // SELECTED VALUES
  // ============================================================

  final selectedAttemptedBy = ''.obs;
  final selectedStage = ''.obs;
  final selectedTurnAwayCode = ''.obs;

  final Rxn<DateTime> selectedFollowUpDate = Rxn<DateTime>();

  UserModel? selectedAttemptedByUser;

  // ============================================================
  // STAGE LIST
  // ============================================================

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

  // ============================================================
  // TURN AWAY CODE LIST
  // ============================================================

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
  // SET CURRENT LEAD
  // ============================================================

  void setCurrentLead(LeadModel lead) {
    final String leadId = lead.leadId ?? lead.id ?? '';

    // Same lead already loaded.
    if (_currentLeadId == leadId && currentLead != null) {
      currentLead = lead;
      return;
    }

    currentLead = lead;
    _currentLeadId = leadId;

    selectedAttemptedBy.value = lead.assignee?.trim() ?? '';

    selectedStage.value = lead.status?.trim() ?? '';

    selectedTurnAwayCode.value = lead.turnAwayCode?.trim() ?? '';

    // Follow Up Date
    final String? followUpValue = lead.followUpDate;

    if (followUpValue != null && followUpValue.trim().isNotEmpty) {
      selectedFollowUpDate.value = DateTime.tryParse(followUpValue.trim());
    } else {
      selectedFollowUpDate.value = null;
    }
  }

  // ============================================================
  // COMMON UPDATE LEAD API
  // ============================================================

  Future<bool> updateLead(Map<String, dynamic> fields) async {
    final LeadModel? lead = currentLead;

    if (lead == null) {
      debugPrint('❌ CURRENT LEAD IS NULL');
      return false;
    }

    final String leadId = lead.leadId ?? lead.id ?? '';

    final String hid = lead.hid ?? lead.hId ?? '';

    if (leadId.isEmpty || hid.isEmpty) {
      debugPrint('❌ LEAD ID OR HID EMPTY');
      return false;
    }

    final String endpoint = '/api/v1/leads/$leadId/update?hid=$hid';

    final Map<String, dynamic> body = {'leadId': leadId, 'hid': hid, ...fields};

    try {
      final response = await ApiClient.put(
        endpoint,
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ LEAD UPDATED');

        return true;
      }

      debugPrint('❌ UPDATE FAILED: ${response.statusCode}');

      debugPrint('Response: ${response.body}');

      return false;
    } catch (e) {
      debugPrint('❌ UPDATE LEAD ERROR: $e');

      return false;
    }
  }

  // ============================================================
  // ATTEMPTED BY
  // ============================================================

  Future<void> onAttemptedByChanged(UserModel user) async {
    final String name = user.displayName?.trim() ?? '';

    if (name.isEmpty) {
      return;
    }

    selectedAttemptedBy.value = name;
    selectedAttemptedByUser = user;

    final bool success = await updateLead({
      'assignee': name,
      'assigneeEmail': user.emailId?.trim() ?? '',
      'assigneeNumber': user.phone?.trim() ?? '',
    });

    if (success) {
      currentLead?.assignee = name;

      currentLead?.assigneeEmail = user.emailId?.trim() ?? '';

      currentLead?.assigneeNumber = user.phone?.trim() ?? '';
    }
  }

  // ============================================================
  // STAGE
  // ============================================================

  Future<void> onStageChanged(String stage) async {
    if (stage.trim().isEmpty) {
      return;
    }

    selectedStage.value = stage;

    final bool success = await updateLead({'status': stage});

    if (success) {
      currentLead?.status = stage;
    }
  }

  // ============================================================
  // TURN AWAY CODE
  // ============================================================

  Future<void> onTurnAwayCodeChanged(String code) async {
    if (code.trim().isEmpty) {
      return;
    }

    selectedTurnAwayCode.value = code;

    final bool success = await updateLead({
      'status': 'Turn Away',
      'turnAwayCode': code,
    });

    if (success) {
      currentLead?.status = 'Turn Away';

      currentLead?.turnAwayCode = code;

      selectedStage.value = 'Turn Away';
    }
  }

  // ============================================================
  // FOLLOW UP DATE + TIME
  // ============================================================

  Future<void> selectFollowUpDateTime(BuildContext context) async {
    final LeadModel? lead = currentLead;

    if (lead == null) {
      debugPrint('❌ CURRENT LEAD IS NULL');
      return;
    }

    final String leadId = lead.leadId ?? lead.id ?? '';

    final String hid = lead.hid ?? lead.hId ?? '';

    if (leadId.isEmpty || hid.isEmpty) {
      debugPrint('❌ LEAD ID OR HID EMPTY');
      return;
    }

    final DateTime now = DateTime.now();

    DateTime initialDate = selectedFollowUpDate.value ?? now;

    if (initialDate.isBefore(now)) {
      initialDate = now;
    }

    // ----------------------------------------------------------
    // DATE PICKER
    // ----------------------------------------------------------

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );

    if (pickedDate == null) {
      return;
    }

    // ----------------------------------------------------------
    // TIME PICKER
    // ----------------------------------------------------------

    final DateTime currentDateTime = selectedFollowUpDate.value ?? now;

    final TimeOfDay initialTime = TimeOfDay(
      hour: currentDateTime.hour,
      minute: currentDateTime.minute,
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }

    // ----------------------------------------------------------
    // FINAL DATE TIME
    // ----------------------------------------------------------

    final DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final String utcDate = selectedDateTime.toUtc().toIso8601String();

    // ----------------------------------------------------------
    // API
    // ----------------------------------------------------------

    final bool success = await updateLead({
      'status': 'Follow Up',
      'followUpDate': utcDate,
    });

    if (!success) {
      return;
    }

    // ----------------------------------------------------------
    // LOCAL UPDATE
    // ----------------------------------------------------------

    selectedFollowUpDate.value = selectedDateTime;

    selectedStage.value = 'Follow Up';

    currentLead?.status = 'Follow Up';

    currentLead?.followUpDate = utcDate;

    Get.snackbar(
      'Success',
      'Follow up updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ============================================================
  // DELETE LEAD
  // ============================================================

  Future<bool> deleteLead(LeadModel lead) async {
    final String leadId = lead.leadId ?? lead.id ?? '';

    if (leadId.isEmpty) {
      debugPrint('❌ LEAD ID EMPTY');
      return false;
    }

    try {
      debugPrint('🗑️ DELETE LEAD ID: $leadId');

      final response = await ApiClient.delete(
        '/eazotel/delete-multiple-contact-queries',
        body: {
          'ids': [leadId],
        },
        authenticated: true,
        baseUrl: 'https://nexon.eazotel.com',
      );

      debugPrint('DELETE STATUS: ${response.statusCode}');

      debugPrint('DELETE RESPONSE: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ------------------------------------------------------
        // REMOVE FROM DASHBOARD LOCAL LIST
        // ------------------------------------------------------

        dashboardController.leads.removeWhere((item) {
          final String itemId = item.leadId ?? item.id ?? '';

          return itemId == leadId;
        });

        // ------------------------------------------------------
        // CLEAR CURRENT LEAD
        // ------------------------------------------------------

        if ((currentLead?.leadId ?? currentLead?.id ?? '') == leadId) {
          currentLead = null;
          _currentLeadId = '';
        }

        debugPrint('✅ LEAD DELETED SUCCESSFULLY');

        return true;
      }

      debugPrint('❌ DELETE FAILED: ${response.statusCode}');

      return false;
    } catch (e) {
      debugPrint('❌ DELETE LEAD ERROR: $e');

      return false;
    }
  }
}
