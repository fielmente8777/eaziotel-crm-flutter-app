import 'package:audioplayers/audioplayers.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/call_model.dart';
import '../services/call_service.dart';

class CallsController extends GetxController {
  final CallService _service = CallService();

  final LocationController locationController = Get.put(LocationController());

  static const int _limit = 20;

  // ============================================================
  // STATE
  // ============================================================

  final calls = <CallModel>[].obs;

  final isLoading = true.obs; // pehla page
  final isLoadingMore = false.obs; // agle page
  final errorMessage = RxnString();

  final total = 0.obs;
  final hasNextPage = false.obs;

  int _page = 0;
  String _hotelId = '';

  // ============================================================
  // RECORDING PLAYER
  // ============================================================

  final AudioPlayer _player = AudioPlayer();

  /// Jis call ki recording chal rahi hai uski id ('' = koi nahi)
  final playingCallId = ''.obs;

  /// Jis call ki recording abhi download ho rahi hai ('' = koi nahi)
  final loadingRecordingId = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    _hotelId = locationController.selectedHotel.value?.hotelId ?? '';

    // Hotel badalne par list dobara load
    ever(locationController.selectedHotel, (hotel) {
      _hotelId = hotel?.hotelId ?? '';
      loadCalls();
    });

    _player.onPlayerComplete.listen((_) => playingCallId.value = '');

    loadCalls();
  }

  @override
  void onClose() {
    _player.dispose();

    super.onClose();
  }

  // ============================================================
  // WHATSAPP CHAT (app ke andar wali conversation)
  // ============================================================

  /// Jis call ke liye WhatsApp chat khul rahi hai ('' = koi nahi)
  final openingWhatsappId = ''.obs;

  String get hotelId => _hotelId;

  // ============================================================
  // LOAD FIRST PAGE (pull to refresh bhi yahi)
  // ============================================================

  Future<void> loadCalls() async {
    final hid = _hotelId;

    await stopRecording();

    if (hid.isEmpty) {
      calls.clear();
      total.value = 0;
      hasNextPage.value = false;
      errorMessage.value = 'No hotel selected';
      isLoading.value = false;
      return;
    }

    // Pehli baar / hotel badalne par shimmer, refresh par purani list rehne do
    if (calls.isEmpty) isLoading.value = true;

    errorMessage.value = null;

    try {
      final result = await _service.getCalls(hid: hid, page: 1, limit: _limit);

      // Request ke dauran hotel badal gaya -> purana result chhod do
      if (hid != _hotelId) return;

      _page = 1;

      calls.assignAll(result.calls);
      total.value = result.pagination.total;
      hasNextPage.value = result.pagination.hasNextPage;
    } catch (e) {
      debugPrint('CALLS LOAD ERROR: $e');

      if (hid != _hotelId) return;

      calls.clear();
      errorMessage.value = _message(e);
    } finally {
      if (hid == _hotelId) isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD NEXT PAGE
  // ============================================================

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasNextPage.value) return;

    final hid = _hotelId;

    isLoadingMore.value = true;

    try {
      final result = await _service.getCalls(
        hid: hid,
        page: _page + 1,
        limit: _limit,
      );

      if (hid != _hotelId) return;

      _page++;

      calls.addAll(result.calls);
      total.value = result.pagination.total;
      hasNextPage.value = result.pagination.hasNextPage;
    } catch (e) {
      debugPrint('CALLS LOAD MORE ERROR: $e');

      Get.snackbar('Error', _message(e), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingMore.value = false;
    }
  }

  String _message(Object error) {
    return error is ApiException
        ? error.message
        : 'Unable to load calls. Please try again.';
  }

  // ============================================================
  // UPDATE STAGE / SEGREGATION / GUEST TYPE / PRIORITY
  // ============================================================

  Future<void> updateField(
    CallModel call,
    CallField field,
    String value, {
    DateTime? followUpDate,
  }) async {
    if (call.valueOf(field) == value && followUpDate == null) return;

    final index = calls.indexWhere((c) => c.id == call.id);

    if (index < 0 || call.sid.isEmpty) return;

    // Turant UI me dikhao, fail ho to wapas purani value
    calls[index] = call.withField(field, value, followUpDate: followUpDate);

    try {
      await _service.updateCall(
        id: call.sid,
        hid: _hotelId,
        body: {
          'sid': call.sid,
          field.apiKey: field.apiValue(value),
          if (followUpDate != null)
            'followUpDate': followUpDate.toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('CALL UPDATE ERROR: $e');

      final current = calls.indexWhere((c) => c.id == call.id);

      if (current >= 0) calls[current] = call;

      Get.snackbar(
        'Error',
        e is ApiException
            ? e.message
            : '${field.label} update nahi hua, dobara try karein',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // RECORDING PLAY / STOP
  // ============================================================

  Future<void> toggleRecording(CallModel call) async {
    if (call.sid.isEmpty) return;

    // Yahi recording chal rahi hai -> band karo
    if (playingCallId.value == call.id) {
      await stopRecording();
      return;
    }

    // Yahi recording abhi load ho rahi hai
    if (loadingRecordingId.value == call.id) return;

    await stopRecording();

    loadingRecordingId.value = call.id;

    try {
      // /api/v1/call/recording/{sid} se audio lao (login token ke saath)
      final path = await _service.getRecordingFile(call.sid);

      // Is beech user ne koi aur recording chun li
      if (loadingRecordingId.value != call.id) return;

      loadingRecordingId.value = '';
      playingCallId.value = call.id;

      await _player.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('CALL RECORDING ERROR: $e');

      if (loadingRecordingId.value == call.id) loadingRecordingId.value = '';
      if (playingCallId.value == call.id) playingCallId.value = '';

      Get.snackbar(
        'Recording',
        e is ApiException ? e.message : 'Unable to play this recording',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<void> stopRecording() async {
    loadingRecordingId.value = '';

    if (playingCallId.value.isEmpty) return;

    playingCallId.value = '';

    try {
      await _player.stop();
    } catch (_) {}
  }
}
