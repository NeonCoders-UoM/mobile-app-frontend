// Web-specific implementation using dart:html
import 'dart:html' as html;
import 'dart:typed_data';

class WebUtils {
  static void downloadFile(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static void openUrlInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  static void submitForm(String action, Map<String, String> fields) {
    final form = html.FormElement();
    form.method = 'POST';
    form.action = action;

    fields.forEach((key, value) {
      final input = html.InputElement();
      input.type = 'hidden';
      input.name = key;
      input.value = value;
      form.append(input);
    });

    html.document.body!.append(form);
    form.submit();
  }

  static String? getLocalStorage(String key) {
    return html.window.localStorage[key];
  }

  static void setLocalStorage(String key, String value) {
    html.window.localStorage[key] = value;
  }

  static void removeLocalStorage(String key) {
    html.window.localStorage.remove(key);
  }
}
