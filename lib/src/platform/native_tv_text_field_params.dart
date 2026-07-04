import 'package:flutter/material.dart';

/// Builds creation/update params for native [EditText] / [UITextField] views.
Map<String, dynamic> buildNativeCreationParams({
  required String text,
  required InputDecoration decoration,
  required TextStyle? style,
  required TextAlign textAlign,
  required bool obscureText,
  required int? maxLines,
  required int? minLines,
  required bool enabled,
  required bool autofocus,
  required TextInputType? keyboardType,
  required TextInputAction? textInputAction,
}) {
  final hint = decoration.hintText ?? '';
  final textColor = style?.color;
  return {
    'text': text,
    'hint': hint,
    'enabled': enabled,
    'obscureText': obscureText,
    'textAlign': textAlign.name,
    'maxLines': maxLines ?? 1,
    'minLines': minLines ?? 1,
    'autofocus': autofocus,
    'keyboardType': nativeKeyboardTypeName(keyboardType),
    'textInputAction': textInputAction?.name,
    if (textColor != null) 'textColor': textColor.toARGB32(),
  };
}

/// Returns whether two native param maps are equivalent.
bool nativeCreationParamsEqual(
  Map<String, dynamic>? a,
  Map<String, dynamic>? b,
) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

String? nativeKeyboardTypeName(TextInputType? type) {
  if (type == null) {
    return null;
  }
  if (type == TextInputType.multiline) return 'multiline';
  if (type == TextInputType.number) return 'number';
  if (type == TextInputType.phone) return 'phone';
  if (type == TextInputType.emailAddress) return 'emailAddress';
  if (type == TextInputType.url) return 'url';
  if (type == TextInputType.visiblePassword) return 'visiblePassword';
  if (type == TextInputType.datetime) return 'datetime';
  if (type == TextInputType.name) return 'name';
  if (type == TextInputType.none) return 'none';
  return 'text';
}

/// Estimated height for native platform views based on theme and line count.
double estimateNativeTextFieldHeight(
  BuildContext context, {
  required TextStyle? style,
  required int? maxLines,
}) {
  final theme = Theme.of(context);
  final lines = maxLines == null ? 1 : maxLines.clamp(1, 6);
  final fontSize =
      style?.fontSize ?? theme.textTheme.bodyLarge?.fontSize ?? 16;
  return (fontSize * 1.4 * lines) + 16;
}
