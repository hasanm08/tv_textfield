import 'package:flutter/services.dart';

/// Handles [TvTextFieldPlatform] method channel calls on Dart-only platforms.
Future<dynamic> handleTvTextfieldPlatformCall(MethodCall call) async {
  switch (call.method) {
    case 'getPlatformInfo':
      return <String, bool>{
        'isAndroidTv': false,
        'isTvOS': false,
        'isTelevision': false,
      };
    default:
      throw MissingPluginException('No implementation for ${call.method}');
  }
}
