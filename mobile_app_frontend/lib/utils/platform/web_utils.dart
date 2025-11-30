// Conditional export for web-specific functionality
export 'web_utils_stub.dart' if (dart.library.html) 'web_utils_web.dart';
