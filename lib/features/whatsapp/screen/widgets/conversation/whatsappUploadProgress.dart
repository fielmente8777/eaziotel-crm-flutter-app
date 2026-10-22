import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// UPLOAD PROGRESS STORE
// ============================================================

/// Upload progress of the image / video being sent (0.0 - 1.0),
/// keyed by the message id (temp id).
class WhatsappUploadProgress {
  WhatsappUploadProgress._();

  static final RxMap<String, double> _values = <String, double>{}.obs;

  /// null = this message is not uploading
  static double? of(String messageId) => _values[messageId];

  static void update(String messageId, double value) {
    final next = value.clamp(0.0, 1.0);
    final current = _values[messageId];

    // Do not rebuild the UI if the percent did not change
    if (current != null && (current * 100).floor() == (next * 100).floor()) {
      return;
    }

    _values[messageId] = next;
  }

  static void clear(String messageId) => _values.remove(messageId);
}

// ============================================================
// UPLOAD OVERLAY
// ============================================================

/// Shows a progress ring + percent over the image / video while uploading.
class WhatsappUploadOverlay extends StatelessWidget {
  final String messageId;
  final Widget child;

  const WhatsappUploadOverlay({
    super.key,
    required this.messageId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = WhatsappUploadProgress.of(messageId);

      if (value == null) return child;

      return Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Container(color: Colors.black45),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
