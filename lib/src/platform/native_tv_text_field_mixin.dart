import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'native_tv_text_field_params.dart';

/// Shared channel and sync logic for Android / Apple native text fields.
mixin NativeTvTextFieldMixin<T extends StatefulWidget> on State<T> {
  MethodChannel? nativeChannel;
  Map<String, dynamic>? lastNativeParams;
  bool suppressNativeTextSync = false;

  TextEditingController get nativeController;
  FocusNode get nativeFocusNode;
  InputDecoration get nativeDecoration;
  TextStyle? get nativeStyle;
  TextAlign get nativeTextAlign;
  bool get nativeObscureText;
  int? get nativeMaxLines;
  int? get nativeMinLines;
  bool get nativeEnabled;
  bool get nativeAutofocus;
  TextInputType? get nativeKeyboardType;
  TextInputAction? get nativeTextInputAction;
  ValueChanged<String>? get nativeOnChanged;
  ValueChanged<String>? get nativeOnSubmitted;
  ValueChanged<bool>? get nativeOnFocusChange;

  Map<String, dynamic> nativeCreationParams() {
    return buildNativeCreationParams(
      text: nativeController.text,
      decoration: nativeDecoration,
      style: nativeStyle,
      textAlign: nativeTextAlign,
      obscureText: nativeObscureText,
      maxLines: nativeMaxLines,
      minLines: nativeMinLines,
      enabled: nativeEnabled,
      autofocus: nativeAutofocus,
      keyboardType: nativeKeyboardType,
      textInputAction: nativeTextInputAction,
    );
  }

  void attachNativeListeners() {
    nativeFocusNode.addListener(handleNativeFocusSideEffects);
    nativeController.addListener(syncTextToNativeIfNeeded);
  }

  void detachNativeListeners() {
    nativeFocusNode.removeListener(handleNativeFocusSideEffects);
    nativeController.removeListener(syncTextToNativeIfNeeded);
  }

  void swapNativeListeners({
    required FocusNode oldFocusNode,
    required FocusNode newFocusNode,
    required TextEditingController oldController,
    required TextEditingController newController,
  }) {
    if (oldFocusNode != newFocusNode) {
      oldFocusNode.removeListener(handleNativeFocusSideEffects);
      newFocusNode.addListener(handleNativeFocusSideEffects);
    }
    if (oldController != newController) {
      oldController.removeListener(syncTextToNativeIfNeeded);
      newController.addListener(syncTextToNativeIfNeeded);
    }
  }

  void handleNativeFocusSideEffects() {
    nativeOnFocusChange?.call(nativeFocusNode.hasFocus);
    nativeChannel?.invokeMethod<void>('setFocused', nativeFocusNode.hasFocus);
  }

  Future<void> syncTextToNativeIfNeeded() async {
    if (suppressNativeTextSync) {
      return;
    }
    await nativeChannel?.invokeMethod<void>('setText', nativeController.text);
  }

  Future<void> updateNativeViewIfNeeded() async {
    final params = nativeCreationParams();
    if (nativeCreationParamsEqual(params, lastNativeParams)) {
      return;
    }
    lastNativeParams = Map<String, dynamic>.from(params);
    await nativeChannel?.invokeMethod<void>('update', params);
  }

  void onNativePlatformViewCreated(int id) {
    nativeChannel = MethodChannel('tv_textfield/edit_text_$id');
    nativeChannel!.setMethodCallHandler(handleNativeMethodCall);
    lastNativeParams = null;
    updateNativeViewIfNeeded();
    if (nativeAutofocus) {
      nativeFocusNode.requestFocus();
    }
  }

  Future<void> handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments as String? ?? '';
        if (nativeController.text != text) {
          suppressNativeTextSync = true;
          try {
            nativeController.value = nativeController.value.copyWith(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
              composing: TextRange.empty,
            );
            nativeOnChanged?.call(text);
          } finally {
            suppressNativeTextSync = false;
          }
        }
      case 'onSubmitted':
        final text = call.arguments as String? ?? nativeController.text;
        nativeOnSubmitted?.call(text);
      case 'onFocusChanged':
        final focused = call.arguments as bool? ?? false;
        if (focused) {
          if (!nativeFocusNode.hasFocus) {
            nativeFocusNode.requestFocus();
          }
        } else {
          nativeFocusNode.unfocus();
        }
    }
  }

  Widget wrapNativeFocusDecoration({
    required Widget child,
    required BoxDecoration? focusDecoration,
    required FocusNode focusNode,
  }) {
    if (focusDecoration == null) {
      return child;
    }

    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: focusNode.hasFocus ? focusDecoration : null,
          child: child,
        );
      },
    );
  }
}
