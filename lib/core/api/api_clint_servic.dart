import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart' hide BaseUrl;
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  // ============================================================
  // GET
  // ============================================================

  static Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // POST
  // (fileField + filePath dene par multipart/form-data bhejta hai,
  //  body ke fields form fields ban jaate hain.
  //  formData: true dene par bina file ke bhi form-data jata hai.)
  // ============================================================

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
    String? fileField,
    String? filePath,
    bool formData = false,
    void Function(int sent, int total)? onUploadProgress,
  }) {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
      fileField: fileField,
      filePath: filePath,
      formData: formData,
      onUploadProgress: onUploadProgress,
    );
  }

  // ============================================================
  // PUT
  // ============================================================

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // PATCH
  // ============================================================

  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      authenticated: authenticated,
      baseUrl: baseUrl,
    );
  }

  // ============================================================
  // MULTIPART (form-data + kitni bhi files, POST ya PUT)
  // Jaise Quick Reply: title, text + 3 photo + 1 PDF
  // (ek hi field naam "file" se kai files bhej sakte ho)
  // ============================================================

  static Future<http.Response> multipart(
    String endpoint, {
    String method = 'POST',
    Map<String, dynamic>? fields,
    List<ApiUploadFile> files = const [],
    bool authenticated = true,
    String? baseUrl,
  }) {
    return _request(
      method: method,
      endpoint: endpoint,
      body: fields,
      authenticated: authenticated,
      baseUrl: baseUrl,
      files: files,
    );
  }

  // ============================================================
  // MAIN REQUEST
  // ============================================================

  static Future<http.Response> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool retry = true,
    String? baseUrl,
    String? fileField,
    String? filePath,
    bool formData = false,
    void Function(int sent, int total)? onUploadProgress,
    List<ApiUploadFile>? files,
  }) async {
    try {
      // ----------------------------------------------------------
      // Get Access Token
      // ----------------------------------------------------------

      final token = authenticated ? await TokenStorage.getAccessToken() : null;

      // ----------------------------------------------------------
      // Headers
      // ----------------------------------------------------------

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',

        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // ----------------------------------------------------------
      // Base URL
      // ----------------------------------------------------------

      final server = baseUrl ?? BaseUrl.production;

      final url = Uri.parse('$server$endpoint');

      // ----------------------------------------------------------
      // Request Logs
      // ----------------------------------------------------------

      print('');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🚀 API REQUEST');
      print('Method : $method');
      print('URL    : $url');

      if (body != null) {
        print('Body   : $body');
      }

      if (filePath != null) {
        print('File   : $fileField -> $filePath');
      }

      // ----------------------------------------------------------
      // Send Request
      // ----------------------------------------------------------

      final response = await _sendRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
        fileField: fileField,
        filePath: filePath,
        formData: formData,
        onUploadProgress: onUploadProgress,
        files: files,
      );

      // ----------------------------------------------------------
      // Response Logs
      // ----------------------------------------------------------

      print('📡 STATUS : ${response.statusCode}');
      print('📥 RESPONSE : ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('');

      // ==========================================================
      // TOKEN EXPIRED
      // ==========================================================

      if (response.statusCode == 401 && authenticated && retry) {
        print('🔄 Access token expired. Refreshing token...');

        final refreshed = await _refreshToken();

        if (refreshed) {
          print('✅ Token refreshed successfully');

          // Retry original request only once
          return _request(
            method: method,
            endpoint: endpoint,
            body: body,
            authenticated: true,
            retry: false,
            baseUrl: baseUrl,
            fileField: fileField,
            filePath: filePath,
            formData: formData,
            onUploadProgress: onUploadProgress,
            files: files,
          );
        }

        // --------------------------------------------------------
        // Refresh Failed
        // --------------------------------------------------------

        print('❌ Token refresh failed');

        await TokenStorage.clearTokens();

        throw ApiException(
          message: 'Session expired. Please login again.',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
      }

      // ==========================================================
      // HTTP ERROR
      // ==========================================================

      if (response.statusCode >= 400) {
        print('❌ API ERROR: ${response.statusCode}');

        final error = _handleHttpError(response);

        throw ApiException(
          message: error.message,
          statusCode: error.statusCode,
          type: error.type,
          responseBody: response.body,
        );
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      return response;
    }
    // ============================================================
    // NO INTERNET
    // ============================================================
    on SocketException {
      print('🌐 No internet connection');

      throw ApiException(
        message: 'No internet connection. Please check your network.',
        type: ApiExceptionType.noInternet,
      );
    }
    // ============================================================
    // TIMEOUT
    // ============================================================
    on TimeoutException {
      print('⏰ Request timeout');

      throw ApiException(
        message: 'Request timed out. Please try again.',
        type: ApiExceptionType.timeout,
      );
    }
    // ============================================================
    // CONNECTION ERROR
    // ============================================================
    on http.ClientException {
      print('❌ Connection error');

      throw ApiException(
        message: 'Unable to connect to server.',
        type: ApiExceptionType.connection,
      );
    }
    // ============================================================
    // API EXCEPTION
    // ============================================================
    on ApiException {
      rethrow;
    }
    // ============================================================
    // UNKNOWN ERROR
    // ============================================================
    catch (e) {
      print('❌ API Error: $e');

      throw ApiException(
        message: 'Something went wrong. Please try again.',
        type: ApiExceptionType.unknown,
      );
    }
  }

  // ============================================================
  // SEND REQUEST
  // ============================================================

  // ============================================================
  // MULTIPART SEND (multipart() se aata hai)
  // ============================================================

  static Future<http.Response> _sendMultipart({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    required List<ApiUploadFile> files,
    Map<String, dynamic>? fields,
  }) async {
    final request = http.MultipartRequest(method, url);

    // Content-Type hatao, boundary http package khud lagata hai
    request.headers.addAll(
      Map<String, String>.from(headers)
        ..removeWhere((key, _) => key.toLowerCase() == 'content-type'),
    );

    fields?.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          file.field,
          file.path,
          filename: file.fileName,
          contentType: http.MediaType.parse(file.mimeType),
        ),
      );
    }

    final streamed = await _client
        .send(request)
        // Video / kai file ho sakti hain, isliye zyada time
        .timeout(Duration(seconds: files.isEmpty ? 30 : 300));

    return http.Response.fromStream(streamed);
  }

  static Future<http.Response> _sendRequest({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
    String? fileField,
    String? filePath,
    bool formData = false,
    void Function(int sent, int total)? onUploadProgress,
    List<ApiUploadFile>? files,
  }) async {
    if (files != null) {
      return _sendMultipart(
        method: method,
        url: url,
        headers: headers,
        fields: body,
        files: files,
      );
    }

    // ----------------------------------------------------------
    // MULTIPART (file upload) - sirf POST par
    // ----------------------------------------------------------

    if (method == 'POST' && fileField != null && filePath != null) {
      final request = _ProgressMultipartRequest(
        'POST',
        url,
        onProgress: onUploadProgress,
      );

      // Content-Type hatao, multipart ka boundary http package khud lagata hai
      final multipartHeaders = Map<String, String>.from(headers)
        ..removeWhere((key, _) => key.toLowerCase() == 'content-type');

      request.headers.addAll(multipartHeaders);

      body?.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final lowerPath = filePath.toLowerCase();

      final String mimeType;
      final String extension;

      final isVideo = lowerPath.endsWith('.mp4');

      if (isVideo) {
        mimeType = 'video/mp4';
        extension = 'mp4';
      } else if (lowerPath.endsWith('.png')) {
        mimeType = 'image/png';
        extension = 'png';
      } else if (lowerPath.endsWith('.webp')) {
        mimeType = 'image/webp';
        extension = 'webp';
      } else {
        // .jpg, .jpeg ya extension na ho, teeno case me image/jpeg
        mimeType = 'image/jpeg';
        extension = 'jpg';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          filePath,
          filename:
              '${isVideo ? 'video' : 'image'}_${DateTime.now().millisecondsSinceEpoch}.$extension',
          contentType: http.MediaType.parse(mimeType),
        ),
      );
      final streamed = await _client
          .send(request)
          // Video badi hoti hai, upload ko zyada time do
          .timeout(Duration(seconds: isVideo ? 300 : 60));

      return http.Response.fromStream(streamed);
    }

    // ----------------------------------------------------------
    // FORM DATA (bina file ke) - sirf POST par
    // ----------------------------------------------------------

    if (method == 'POST' && formData) {
      final request = http.MultipartRequest('POST', url);

      // Content-Type hatao, form ka boundary http package khud lagata hai
      final formHeaders = Map<String, String>.from(headers)
        ..removeWhere((key, _) => key.toLowerCase() == 'content-type');

      request.headers.addAll(formHeaders);

      body?.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));

      return http.Response.fromStream(streamed);
    }

    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      // ----------------------------------------------------------
      // GET
      // ----------------------------------------------------------

      case 'GET':
        return _client
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 30));

      // ----------------------------------------------------------
      // POST
      // ----------------------------------------------------------

      case 'POST':
        return _client
            .post(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      // ----------------------------------------------------------
      // PUT
      // ----------------------------------------------------------

      case 'PUT':
        return _client
            .put(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      // ----------------------------------------------------------
      // PATCH
      // ----------------------------------------------------------

      case 'PATCH':
        return _client
            .patch(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      // ----------------------------------------------------------
      // DELETE
      // ----------------------------------------------------------

      case 'DELETE':
        return _client
            .delete(url, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 30));

      // ----------------------------------------------------------
      // Unsupported
      // ----------------------------------------------------------

      default:
        throw ApiException(
          message: 'Unsupported HTTP method: $method',
          type: ApiExceptionType.unknown,
        );
    }
  }

  // ============================================================
  // HTTP ERROR HANDLER
  // ============================================================

  static ApiException _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      // --------------------------------------------------------
      // 400
      // --------------------------------------------------------

      case 400:
        return ApiException(
          message: 'Bad request. Please check your data.',
          statusCode: 400,
          type: ApiExceptionType.badRequest,
        );

      // --------------------------------------------------------
      // 401
      // --------------------------------------------------------

      case 401:
        return ApiException(
          message: 'Unauthorized. Please login again.',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );

      // --------------------------------------------------------
      // 403
      // --------------------------------------------------------

      case 403:
        return ApiException(
          message: 'You do not have permission to perform this action.',
          statusCode: 403,
          type: ApiExceptionType.forbidden,
        );

      // --------------------------------------------------------
      // 404
      // --------------------------------------------------------

      case 404:
        return ApiException(
          message: 'Requested resource was not found.',
          statusCode: 404,
          type: ApiExceptionType.notFound,
        );

      // --------------------------------------------------------
      // 408
      // --------------------------------------------------------

      case 408:
        return ApiException(
          message: 'Request timeout. Please try again.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );

      // --------------------------------------------------------
      // 429
      // --------------------------------------------------------

      case 429:
        return ApiException(
          message: 'Too many requests. Please try again later.',
          statusCode: 429,
          type: ApiExceptionType.tooManyRequests,
        );

      // --------------------------------------------------------
      // 500
      // --------------------------------------------------------

      case 500:
        return ApiException(
          message: 'Internal server error.',
          statusCode: 500,
          type: ApiExceptionType.serverError,
        );

      // --------------------------------------------------------
      // 502 / 503 / 504
      // --------------------------------------------------------

      case 502:
      case 503:
      case 504:
        return ApiException(
          message: 'Server is temporarily unavailable.',
          statusCode: response.statusCode,
          type: ApiExceptionType.serverError,
        );

      // --------------------------------------------------------
      // OTHER
      // --------------------------------------------------------

      default:
        return ApiException(
          message: 'Something went wrong. Please try again.',
          statusCode: response.statusCode,
          type: ApiExceptionType.unknown,
        );
    }
  }

  // ============================================================
  // GOOGLE AUTH
  // ============================================================

  static Future<http.Response> googleAuth(String idToken) async {
    try {
      final response = await _client
          .post(
            Uri.parse(BaseUrl.googleAuthUrl),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      print('🚀 Google Auth');
      print('📡 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode >= 400) {
        throw _handleHttpError(response);
      }

      return response;
    }
    // ----------------------------------------------------------
    // NO INTERNET
    // ----------------------------------------------------------
    on SocketException {
      throw ApiException(
        message: 'No internet connection. Please check your network.',
        type: ApiExceptionType.noInternet,
      );
    }
    // ----------------------------------------------------------
    // TIMEOUT
    // ----------------------------------------------------------
    on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        type: ApiExceptionType.timeout,
      );
    }
    // ----------------------------------------------------------
    // CONNECTION
    // ----------------------------------------------------------
    on http.ClientException {
      throw ApiException(
        message: 'Unable to connect to server.',
        type: ApiExceptionType.connection,
      );
    }
    // ----------------------------------------------------------
    // API EXCEPTION
    // ----------------------------------------------------------
    on ApiException {
      rethrow;
    }
    // ----------------------------------------------------------
    // UNKNOWN
    // ----------------------------------------------------------
    catch (e) {
      print('❌ Google Login Error: $e');

      throw ApiException(
        message: 'Google login failed. Please try again.',
        type: ApiExceptionType.unknown,
      );
    }
  }

  // ============================================================
  // REFRESH TOKEN
  // ============================================================

  static Future<bool> _refreshToken() async {
    try {
      // ----------------------------------------------------------
      // Get Refresh Token
      // ----------------------------------------------------------

      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ Refresh token not available');
        return false;
      }

      // ----------------------------------------------------------
      // Refresh URL
      // ----------------------------------------------------------

      final url = Uri.parse(
        '${BaseUrl.production}'
        '${AuthApiEndpoint.refreshToken}',
      );

      print('🔄 Refresh Token API');
      print('URL: $url');

      // ----------------------------------------------------------
      // Request
      // ----------------------------------------------------------

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      print('🔄 Refresh Status: ${response.statusCode}');
      print('🔄 Refresh Response: ${response.body}');

      // ----------------------------------------------------------
      // Refresh Failed
      // ----------------------------------------------------------

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      // ----------------------------------------------------------
      // Parse Response
      // ----------------------------------------------------------

      final data = jsonDecode(response.body);

      // ----------------------------------------------------------
      // Support Multiple Token Names
      // ----------------------------------------------------------

      final newAccessToken =
          data['accessToken'] ?? data['access_token'] ?? data['token'];

      final newRefreshToken = data['refreshToken'] ?? data['refresh_token'];

      // ----------------------------------------------------------
      // Access Token Missing
      // ----------------------------------------------------------

      if (newAccessToken == null || newAccessToken.toString().isEmpty) {
        print('❌ New access token missing');
        return false;
      }

      // ----------------------------------------------------------
      // Save New Tokens
      // ----------------------------------------------------------

      await TokenStorage.saveTokens(
        accessToken: newAccessToken.toString(),
        refreshToken: newRefreshToken?.toString() ?? refreshToken,
      );

      print('✅ New access token saved');

      return true;
    }
    // ----------------------------------------------------------
    // Refresh Error
    // ----------------------------------------------------------
    catch (e) {
      print('❌ Refresh Token Error: $e');
      return false;
    }
  }
}

// ============================================================
// MULTIPART REQUEST WITH UPLOAD PROGRESS
// ============================================================

/// Body bhejte waqt kitne bytes ja chuke hain, wo [onProgress] me batata hai.
class _ProgressMultipartRequest extends http.MultipartRequest {
  _ProgressMultipartRequest(super.method, super.url, {this.onProgress});

  final void Function(int sent, int total)? onProgress;

  @override
  http.ByteStream finalize() {
    final stream = super.finalize();

    final callback = onProgress;

    if (callback == null) return stream;

    final total = contentLength;

    var sent = 0;

    return http.ByteStream(
      stream.transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (data, sink) {
            sent += data.length;

            callback(sent, total);

            sink.add(data);
          },
        ),
      ),
    );
  }
}

// ============================================================
// UPLOAD FILE (ApiClient.multipart ke liye)
// ============================================================

class ApiUploadFile {
  ApiUploadFile({required this.field, required this.path, String? fileName})
    : fileName = fileName ?? path.split(RegExp(r'[\/]')).last;

  /// Form ka naam, jaise "file"
  final String field;

  /// Phone / computer par file ka rasta
  final String path;
  final String fileName;

  /// Extension se type (jpg -> image/jpeg, pdf -> application/pdf ...)
  String get mimeType {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    return _mimeTypes[ext] ?? 'application/octet-stream';
  }

  static const Map<String, String> _mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    '3gp': 'video/3gpp',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  };
}
