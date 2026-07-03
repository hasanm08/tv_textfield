import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'tv_textfield_platform_handler.dart';

/// Web plugin registration for [tv_textfield].
class TvTextfieldPluginWeb {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'tv_textfield/platform',
      const StandardMethodCodec(),
      registrar,
    );
    channel.setMethodCallHandler(handleTvTextfieldPlatformCall);
  }
}
