import 'package:flutter/services.dart';

/// Remote / D-pad keys that should move focus instead of editing text.
bool isDirectionalNavigationKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowDown ||
      key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.arrowRight ||
      key == LogicalKeyboardKey.gameButtonA ||
      key == LogicalKeyboardKey.gameButtonB ||
      key == LogicalKeyboardKey.gameButtonC ||
      key == LogicalKeyboardKey.gameButtonX ||
      key == LogicalKeyboardKey.gameButtonY ||
      key == LogicalKeyboardKey.gameButtonZ;
}

/// Keys that activate text editing on a focused field.
bool isActivationKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.gameButtonA;
}

/// Keys that dismiss editing or the soft keyboard.
///
/// Includes Android Back, desktop Escape, and Apple TV Menu (mapped to escape on
/// some embedders).
bool isDismissKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.escape ||
      key == LogicalKeyboardKey.goBack ||
      key == LogicalKeyboardKey.browserBack ||
      key == LogicalKeyboardKey.metaLeft ||
      key == LogicalKeyboardKey.metaRight;
}
