import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileMembersModel.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:get/get.dart';

class LeadFilterController extends GetxController {
  final DashboardController controller =
      Get.find<DashboardController>();

  LeadModel? currentLead;



  

  

  // ------------------------------------------------------------
  // SELECTED VALUES
  // ------------------------------------------------------------

  final selectedAttemptedBy = ''.obs;

  UserModel? selectedAttemptedByUser;

  final selectedStage = ''.obs;

  final selectedTurnAwayCode = ''.obs;

  // ------------------------------------------------------------
  // STAGE LIST
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // TURN AWAY CODE LIST
  // ------------------------------------------------------------

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
    currentLead = lead;
    
  }

  // ============================================================
  // ATTEMPTED BY CHANGE
  // ============================================================

  Future<void> onAttemptedByChanged(UserModel user) async {
    selectedAttemptedBy.value = user.displayName ?? '';
    selectedAttemptedByUser = user;

    final lead = currentLead;

    if (lead == null) {
      print('❌ CURRENT LEAD IS NULL');
      return;
    }

    final String leadId = lead.leadId ?? lead.id ?? '';
    final String hid = lead.hid ?? lead.hId ?? '';

    if (leadId.isEmpty || hid.isEmpty) {
      print('❌ LEAD ID OR HID EMPTY');
      return;
    }

    await updateAttemptedBy(
      leadId: leadId,
      hid: hid,
      assignee: user.displayName?.trim() ?? '',
      assigneeEmail: user.emailId?.trim() ?? '',
      assigneeNumber: user.phone?.trim() ?? '',
    );
  }

  // ============================================================
  // STAGE CHANGE
  // ============================================================

  Future<void> onStageChanged(String stage) async {
    selectedStage.value = stage;

    final lead = currentLead;

    if (lead == null) {
      print('❌ CURRENT LEAD IS NULL');
      return;
    }

    final String leadId = lead.leadId ?? lead.id ?? '';
    final String hid = lead.hid ?? lead.hId ?? '';

    if (leadId.isEmpty || hid.isEmpty) {
      print('❌ LEAD ID OR HID EMPTY');
      return;
    }

    await updateStage(
      leadId: leadId,
      hid: hid,
      status: stage,
    );
  }

  // ============================================================
  // TURN AWAY CODE CHANGE
  // ============================================================

  Future<void> onTurnAwayCodeChanged(String code) async {
    selectedTurnAwayCode.value = code;

    final lead = currentLead;

    if (lead == null) {
      print('❌ CURRENT LEAD IS NULL');
      return;
    }

    final String leadId = lead.leadId ?? lead.id ?? '';
    final String hid = lead.hid ?? lead.hId ?? '';

    if (leadId.isEmpty || hid.isEmpty) {
      print('❌ LEAD ID OR HID EMPTY');
      return;
    }

    await updateTurnAwayCode(
      leadId: leadId,
      hid: hid,
      status: 'Turn Away',
      turnAwayCode: code,
    );
  }

  // ============================================================
  // ATTEMPTED BY API
  // ============================================================

  Future<void> updateAttemptedBy({
    required String leadId,
    required String hid,
    required String assignee,
    required String assigneeEmail,
    required String assigneeNumber,
  }) async {
    final String endpoint =
        '/api/v1/leads/$leadId/update?hid=$hid';

    final Map<String, dynamic> body = {
      'leadId': leadId,
      'hid': hid,
      'assignee': assignee,
      'assigneeEmail': assigneeEmail,
      'assigneeNumber': assigneeNumber,
    };

    try {
      final response = await ApiClient.put(
        endpoint,
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        print('✅ ATTEMPTED BY UPDATED');
      } else {
        print('❌ ATTEMPTED BY UPDATE FAILED');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ ATTEMPTED BY API ERROR: $e');
    }
  }

  // ============================================================
  // STAGE API
  // ============================================================

  Future<void> updateStage({
    required String leadId,
    required String hid,
    required String status,
  }) async {
    final String endpoint =
        '/api/v1/leads/$leadId/update?hid=$hid';

    final Map<String, dynamic> body = {
      'leadId': leadId,
      'status': status,
      'hid': hid,
      'followUpDate': null,
    };

    try {
      final response = await ApiClient.put(
        endpoint,
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        print('✅ STAGE UPDATED: $status');
      } else {
        print('❌ STAGE UPDATE FAILED');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ STAGE API ERROR: $e');
    }
  }

  // ============================================================
  // TURN AWAY CODE API
  // ============================================================

  Future<void> updateTurnAwayCode({
    required String leadId,
    required String hid,
    required String status,
    required String turnAwayCode,
  }) async {
    final String endpoint =
        '/api/v1/leads/$leadId/update?hid=$hid';

    final Map<String, dynamic> body = {
      'leadId': leadId,
      'status': status,
      'hid': hid,
      'followUpDate': null,
      'turnAwayCode': turnAwayCode,
    };

    try {
      final response = await ApiClient.put(
        endpoint,
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        print('✅ TURN AWAY CODE UPDATED: $turnAwayCode');
      } else {
        print('❌ TURN AWAY CODE UPDATE FAILED');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ TURN AWAY CODE API ERROR: $e');
    }
  }
}