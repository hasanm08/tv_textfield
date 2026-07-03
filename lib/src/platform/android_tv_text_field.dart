import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android-native [EditText] embedded through a platform view.
///
/// Handles TV remote input and the on-screen keyboard correctly on Android TV
/// by delegating to the platform text input stack.
class AndroidTvTextField extends StatefulWidget {
  const AndroidTvTextField({
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
  State<AndroidTvTextField> createState() => _AndroidTvTextFieldState();
}

class _AndroidTvTextFieldState extends State<AndroidTvTextField> {
  static const _viewType = 'tv_textfield/edit_text';
  MethodChannel? _channel;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_syncTextToNative);
  }

  @override
  void didUpdateWidget(covariant AndroidTvTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncTextToNative);
      widget.controller.addListener(_syncTextToNative);
    }
    _updateNativeView();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_syncTextToNative);
    super.dispose();
  }

  void _handleFocusChange() {
    widget.onFocusChange?.call(widget.focusNode.hasFocus);
    _channel?.invokeMethod<void>(
      'setFocused',
      widget.focusNode.hasFocus,
    );
    setState(() {});
  }

  Future<void> _syncTextToNative() async {
    await _channel?.invokeMethod<void>('setText', widget.controller.text);
  }

  Future<void> _updateNativeView() async {
    await _channel?.invokeMethod<void>('update', _creationParams());
  }

  Map<String, dynamic> _creationParams() {
    final hint = widget.decoration.hintText ?? '';
    final textColor = widget.style?.color;
    return {
      'text': widget.controller.text,
      'hint': hint,
      'enabled': widget.enabled,
      'obscureText': widget.obscureText,
      'textAlign': widget.textAlign.name,
      'maxLines': widget.maxLines ?? 1,
      'minLines': widget.minLines ?? 1,
      'autofocus': widget.autofocus,
      'keyboardType': _keyboardTypeName(widget.keyboardType),
      'textInputAction': widget.textInputAction?.name,
      if (textColor != null) 'textColor': textColor.toARGB32(),
    };
  }

  String? _keyboardTypeName(TextInputType? type) {
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

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('tv_textfield/edit_text_$id');
    _channel!.setMethodCallHandler(_handleMethodCall);
    _updateNativeView();
    if (widget.autofocus) {
      widget.focusNode.requestFocus();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments as String? ?? '';
        if (widget.controller.text != text) {
          widget.controller.value = widget.controller.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
            composing: TextRange.empty,
          );
          widget.onChanged?.call(text);
        }
      case 'onSubmitted':
        final text = call.arguments as String? ?? widget.controller.text;
        widget.onSubmitted?.call(text);
      case 'onFocusChanged':
        final focused = call.arguments as bool? ?? false;
        if (focused) {
          if (!widget.focusNode.hasFocus) {
            widget.focusNode.requestFocus();
          }
        } else {
          widget.focusNode.unfocus();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = defaultTargetPlatform == TargetPlatform.android
        ? Focus(
            focusNode: widget.focusNode,
            canRequestFocus: widget.canRequestFocus && widget.enabled,
            child: SizedBox(
              height: _estimatedHeight(context),
              child: AndroidView(
                viewType: _viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: _creationParams(),
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: _onPlatformViewCreated,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                  Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
                },
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

    if (widget.focusDecoration == null) {
      return child;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: widget.focusNode.hasFocus ? widget.focusDecoration : null,
      child: child,
    );
  }

  double _estimatedHeight(BuildContext context) {
    final theme = Theme.of(context);
    final lines = widget.maxLines == null ? 1 : (widget.maxLines!).clamp(1, 6);
    final fontSize = widget.style?.fontSize ?? theme.textTheme.bodyLarge?.fontSize ?? 16;
    final padding = 16.0;
    return (fontSize * 1.4 * lines) + padding;
  }
}
