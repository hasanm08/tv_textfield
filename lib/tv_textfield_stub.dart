import 'package:flutter/services.dart';

import 'tv_textfield_platform_handler.dart';

/// Dart plugin registration for Linux, macOS, and Windows.
class TvTextfieldPluginStub {
  static void registerWith() {
    const channel = MethodChannel('tv_textfield/platform');
    channel.setMethodCallHandler(handleTvTextfieldPlatformCall);
  }
}
