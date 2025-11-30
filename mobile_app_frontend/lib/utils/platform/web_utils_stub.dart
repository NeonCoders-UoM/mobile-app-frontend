// Stub implementation for non-web platforms
import 'dart:typed_data';

class WebUtils {
  static void downloadFile(Uint8List bytes, String fileName) {
    throw UnsupportedError('File download is only supported on web platform');
  }

  static void openUrlInNewTab(String url) {
    throw UnsupportedError(
        'Opening URL in new tab is only supported on web platform');
  }

  static void submitForm(String action, Map<String, String> fields) {
    throw UnsupportedError('Form submission is only supported on web platform');
  }

  static String? getLocalStorage(String key) {
    return null;
  }

  static void setLocalStorage(String key, String value) {
    // No-op on non-web platforms
  }

  static void removeLocalStorage(String key) {
    // No-op on non-web platforms
  }
}
