import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'native_tv_text_field_mixin.dart';
import 'native_tv_text_field_params.dart';

/// Apple-native [UITextField] embedded through a platform view.
///
/// Used on tvOS for the system full-screen keyboard and on iOS when native input
/// is explicitly requested.
class AppleTvTextField extends StatefulWidget {
  const AppleTvTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChange,
    this.focusDecoration,
    this.canRequestFocus = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChange;
  final BoxDecoration? focusDecoration;
  final bool canRequestFocus;

  @override
  State<AppleTvTextField> createState() => _AppleTvTextFieldState();
}

class _AppleTvTextFieldState extends State<AppleTvTextField>
    with NativeTvTextFieldMixin<AppleTvTextField> {
  static const _viewType = 'tv_textfield/edit_text';

  @override
  TextEditingController get nativeController => widget.controller;

  @override
  FocusNode get nativeFocusNode => widget.focusNode;

  @override
  InputDecoration get nativeDecoration => widget.decoration;

  @override
  TextStyle? get nativeStyle => widget.style;

  @override
  TextAlign get nativeTextAlign => widget.textAlign;

  @override
  bool get nativeObscureText => widget.obscureText;

  @override
  int? get nativeMaxLines => widget.maxLines;

  @override
  int? get nativeMinLines => widget.minLines;

  @override
  bool get nativeEnabled => widget.enabled;

  @override
  bool get nativeAutofocus => widget.autofocus;

  @override
  TextInputType? get nativeKeyboardType => widget.keyboardType;

  @override
  TextInputAction? get nativeTextInputAction => widget.textInputAction;

  @override
  ValueChanged<String>? get nativeOnChanged => widget.onChanged;

  @override
  ValueChanged<String>? get nativeOnSubmitted => widget.onSubmitted;

  @override
  ValueChanged<bool>? get nativeOnFocusChange => widget.onFocusChange;

  @override
  void initState() {
    super.initState();
    attachNativeListeners();
  }

  @override
  void didUpdateWidget(covariant AppleTvTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    swapNativeListeners(
      oldFocusNode: oldWidget.focusNode,
      newFocusNode: widget.focusNode,
      oldController: oldWidget.controller,
      newController: widget.controller,
    );
    updateNativeViewIfNeeded();
  }

  @override
  void dispose() {
    detachNativeListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = defaultTargetPlatform == TargetPlatform.iOS
        ? Focus(
            focusNode: widget.focusNode,
            canRequestFocus: widget.canRequestFocus && widget.enabled,
            child: RepaintBoundary(
              child: SizedBox(
                height: estimateNativeTextFieldHeight(
                  context,
                  style: widget.style,
                  maxLines: widget.maxLines,
                ),
                child: UiKitView(
                  viewType: _viewType,
                  layoutDirection: TextDirection.ltr,
                  creationParams: nativeCreationParams(),
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: onNativePlatformViewCreated,
                  gestureRecognizers:
                      const <Factory<OneSequenceGestureRecognizer>>{
                    Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
                  },
                ),
              ),
            ),
          )
        : TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: widget.decoration,
            style: widget.style,
            textAlign: widget.textAlign,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          );

    return wrapNativeFocusDecoration(
      child: child,
      focusDecoration: widget.focusDecoration,
      focusNode: widget.focusNode,
    );
  }
}
