/// POST /eazotel/edit/password ka nateeja
class ChangePasswordResult {
  final bool success;
  final String? message;

  const ChangePasswordResult({required this.success, this.message});

  /// Server 200 ke saath bhi "Status": false bhej sakta hai
  /// (jaise purana password galat ho).
  factory ChangePasswordResult.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResult(
      success: json['Status'] != false && json['success'] != false,
      message: (json['Message'] ?? json['message'])?.toString(),
    );
  }

  const ChangePasswordResult.failure(String this.message) : success = false;
}
