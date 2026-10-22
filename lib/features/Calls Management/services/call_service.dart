import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';

import '../models/call_model.dart';

class CallService {
  /// GET /api/v1/call/getall?hid=..&page=..&limit=..
  Future<CallsResponse> getCalls({
    required String hid,
    required int page,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '${CallApiEndpoint.getAll}?hid=$hid&page=$page&limit=$limit',
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );

    return CallsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// PUT /api/v1/call/update-call/{sid}?hid=..
  /// body: {"sid": "..", "priority": "Medium"}
  ///       {"sid": "..", "segregation": {"label": "..", "value": ".."}}
  Future<void> updateCall({
    required String id,
    required String hid,
    required Map<String, dynamic> body,
  }) async {
    await ApiClient.put(
      '${CallApiEndpoint.updateCall(id)}?hid=$hid',
      body: body,
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );
  }

  /// POST /api/v1/call/auth/make-call?hid=..
  /// body: {"fromNumber": "+9192...", "toNumber": "+9178..."}
  Future<void> makeCall({
    required String hid,
    required String fromNumber,
    required String toNumber,
  }) async {
    await ApiClient.post(
      '${CallApiEndpoint.makeCall}?hid=$hid',
      body: {'fromNumber': fromNumber, 'toNumber': toNumber},
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );
  }

  // ============================================================
  // RECORDING
  // GET /api/v1/call/recording/{sid}  (needs the login token)
  // ============================================================

  /// Downloads the recording to the phone and returns the file path.
  /// Once downloaded, the same file is reused.
  Future<String> getRecordingFile(String sid) async {
    final dir = await getTemporaryDirectory();

    final safeSid = sid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final file = File('${dir.path}/call_recording_$safeSid.mp3');

    if (await file.exists() && await file.length() > 0) return file.path;

    var response = await _recordingRequest(sid);

    // Token expired -> refresh it through ApiClient, then try again
    if (response.statusCode == 401) {
      try {
        await ApiClient.get(
          '${CallApiEndpoint.getAll}?hid=0&page=1&limit=1',
          authenticated: true,
          baseUrl: BaseUrl.production2,
        );
      } catch (_) {}

      response = await _recordingRequest(sid);
    }

    var bytes = _audioBytes(response);

    // If the API sent a link in JSON instead of audio, get the audio from that link
    if (bytes == null) {
      final url = _findUrl(jsonDecode(utf8.decode(response.data ?? [])));

      if (url == null) throw _recordingError(response.statusCode);

      final audio = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
        ),
      );

      bytes = _audioBytes(audio);

      if (bytes == null) throw _recordingError(audio.statusCode);
    }

    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  final Dio _dio = Dio();

  Future<Response<List<int>>> _recordingRequest(String sid) async {
    final token = await TokenStorage.getAccessToken();

    return _dio.get<List<int>>(
      '${BaseUrl.production2}${CallApiEndpoint.recording(sid)}',
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  /// The bytes if the response is audio, otherwise (JSON / error) null
  List<int>? _audioBytes(Response<List<int>> response) {
    final status = response.statusCode ?? 0;

    if (status < 200 || status >= 300) {
      throw _recordingError(status);
    }

    final type = response.headers.value('content-type') ?? '';

    final data = response.data;

    if (type.contains('json') || data == null || data.isEmpty) return null;

    return data;
  }

  /// Find the first http link inside the JSON
  String? _findUrl(dynamic json) {
    if (json is String) return json.startsWith('http') ? json : null;

    final Iterable<dynamic> values = json is Map
        ? json.values
        : json is List
        ? json
        : const [];

    for (final value in values) {
      final url = _findUrl(value);

      if (url != null) return url;
    }

    return null;
  }

  ApiException _recordingError(int? status) {
    return ApiException(
      message: 'Unable to load this recording',
      statusCode: status,
      type: ApiExceptionType.unknown,
    );
  }
}