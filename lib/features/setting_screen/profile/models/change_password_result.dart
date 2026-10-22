/// Result of POST /eazotel/edit/password
class ChangePasswordResult {
  final bool success;
  final String? message;

  const ChangePasswordResult({required this.success, this.message});

  /// The server can send "Status": false even with a 200
  /// (like when the old password is wrong).
  factory ChangePasswordResult.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResult(
      success: json['Status'] != false && json['success'] != false,
      message: (json['Message'] ?? json['message'])?.toString(),
    );
  }

  const ChangePasswordResult.failure(String this.message) : success = false;
}
