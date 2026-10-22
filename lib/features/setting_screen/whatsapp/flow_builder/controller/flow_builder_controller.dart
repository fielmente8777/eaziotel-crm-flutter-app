// ============================================================
// FLOW BUILDER CONTROLLER  (Flows > Create Flow)
//
//   Step 1: choose a template (Lead Generation / Feedback Form)
//   Step 2: type a name (dialog)
//   Step 3: build screens + fields -> Publish
//
// After Publish, the list in the "Flow Name" tab is refreshed.
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:get/get.dart';

import '../../controller/whatsapp_Flow_controller.dart';
import '../../models/whatsapp_action_response.dart';
import '../models/flow_builder_models.dart';
import '../services/flow_builder_service.dart';

class FlowBuilderController extends GetxController {
  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  /// null = no template chosen yet (show the list)
  final template = Rxn<FlowTemplateOption>();
  final flowName = ''.obs;

  final screens = <FlowScreenDraft>[].obs;
  final activeIndex = 0.obs;
  final isPublishing = false.obs;

  FlowScreenDraft? get activeScreen => screens.isEmpty
      ? null
      : screens[activeIndex.value.clamp(0, screens.length - 1)];

  /// The preview changes when the text changes
  final _tick = 0.obs;
  void _touch() => _tick.value++;
  int get tick => _tick.value;

  @override
  void onClose() {
    _clearScreens();
    super.onClose();
  }

  // ============================================================
  // START / BACK
  // ============================================================

  void start(FlowTemplateOption option, String name) {
    _clearScreens();
    template.value = option;
    flowName.value = name.trim();
    screens.add(_watchScreen(FlowScreenDraft(id: 1, title: 'Sign up')));
    activeIndex.value = 0;
  }

  void backToTemplates() {
    _clearScreens();
    template.value = null;
    flowName.value = '';
  }

  void _clearScreens() {
    for (final s in screens) {
      s.dispose();
    }
    screens.clear();
  }

  FlowScreenDraft _watchScreen(FlowScreenDraft s) {
    s.title.addListener(_touch);
    return s;
  }

  // ============================================================
  // SCREENS
  // ============================================================

  void addScreen() {
    screens.add(
      _watchScreen(FlowScreenDraft(id: DateTime.now().millisecondsSinceEpoch)),
    );
    activeIndex.value = screens.length - 1;
  }

  void removeScreen(FlowScreenDraft screen) {
    if (screens.length <= 1) return;
    final index = screens.indexOf(screen);
    screens.remove(screen);
    screen.dispose();
    if (activeIndex.value >= screens.length || activeIndex.value > index) {
      activeIndex.value = (activeIndex.value - 1).clamp(0, screens.length - 1);
    }
  }

  void selectScreen(int index) => activeIndex.value = index;

  // ============================================================
  // FIELDS (in the selected screen)
  // ============================================================

  void addField() {
    final screen = activeScreen;
    if (screen == null) return;
    final field = FlowFieldDraft()..label.addListener(_touch);
    screen.fields.add(field);
  }

  void removeField(FlowFieldDraft field) {
    activeScreen?.fields.remove(field);
    field.dispose();
  }

  // ============================================================
  // PUBLISH
  // ============================================================

  String? get problem {
    _tick.value;
    for (final s in screens) {
      if (s.title.text.trim().isEmpty) return 'Every screen needs a title.';
      if (s.fields.isEmpty) {
        return 'Screen "${s.title.text.trim()}" has no fields.';
      }
      if (s.fields.any((f) => f.label.text.trim().isEmpty)) {
        return 'Every field needs a label.';
      }
    }
    return null;
  }

  Future<void> publish() async {
    final option = template.value;
    if (option == null || isPublishing.value) return;

    final issue = problem;
    if (issue != null) {
      _toast('Check the flow', issue);
      return;
    }

    isPublishing.value = true;
    try {
      final response = await FlowBuilderService.createFlow(
        hid: hid,
        flowName: flowName.value,
        category: option.category,
        screens: screens.map((s) => s.toJson()).toList(),
      );

      if (response.isSuccess) {
        _toast('Flow created', response.message('Flow created successfully'));
        backToTemplates();

        // Show the new flow in the "Flow Name" tab
        if (Get.isRegistered<WhatsappFlowPageController>()) {
          final list = Get.find<WhatsappFlowPageController>();
          list.changeTab(FlowTab.flowName);
          list.loadFlows();
        }
        return;
      }

      _toast('Not published', response.message('Failed to publish flow.'));
    } catch (e) {
      _toast(
        'Not published',
        WhatsappActionResponse.errorOf(e, 'Failed to publish flow.'),
      );
    } finally {
      isPublishing.value = false;
    }
  }

  void _toast(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
