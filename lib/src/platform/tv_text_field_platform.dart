import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform capabilities reported by the native plugin layer.
class TvPlatformInfo {
  const TvPlatformInfo({
    required this.isAndroidTv,
    required this.isTvOS,
    required this.isTelevision,
  });

  final bool isAndroidTv;
  final bool isTvOS;
  final bool isTelevision;

  factory TvPlatformInfo.fromMap(Map<dynamic, dynamic> map) {
    return TvPlatformInfo(
      isAndroidTv: map['isAndroidTv'] as bool? ?? false,
      isTvOS: map['isTvOS'] as bool? ?? false,
      isTelevision: map['isTelevision'] as bool? ?? false,
    );
  }

  static const fallback = TvPlatformInfo(
    isAndroidTv: false,
    isTvOS: false,
    isTelevision: false,
  );
}

/// Resolves TV-specific platform details through a method channel.
class TvTextFieldPlatform {
  TvTextFieldPlatform._();

  static const _channel = MethodChannel('tv_textfield/platform');

  static TvPlatformInfo? _cached;
  static Future<TvPlatformInfo>? _pending;

  /// Loads platform info once. Safe to call multiple times.
  static Future<TvPlatformInfo> ensureInitialized() {
    return _pending ??= _load().then((info) {
      _cached = info;
      return info;
    });
  }

  static Future<TvPlatformInfo> _load() async {
    if (kIsWeb) {
      return TvPlatformInfo.fallback;
    }
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getPlatformInfo',
      );
      if (result == null) {
        return TvPlatformInfo.fallback;
      }
      return TvPlatformInfo.fromMap(result);
    } on PlatformException {
      return TvPlatformInfo.fallback;
    } on MissingPluginException {
      return TvPlatformInfo.fallback;
    }
  }

  static TvPlatformInfo get info => _cached ?? TvPlatformInfo.fallback;

  static bool get isTelevision => info.isTelevision;
  static bool get isTvOS => info.isTvOS;
  static bool get isAndroidTv => info.isAndroidTv;
}
