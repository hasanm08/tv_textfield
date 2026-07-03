import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform/apple_tv_text_field.dart';
import 'platform/android_tv_text_field.dart';
import 'platform/flutter_tv_text_field.dart';
import 'platform/tv_text_field_platform.dart';

export 'platform/flutter_tv_text_field.dart' show TvTextFieldImplementation;
export 'platform/tv_text_field_platform.dart'
    show TvPlatformInfo, TvTextFieldPlatform;

/// A TV- and remote-friendly text field for Android TV, Apple TV, and other
/// platforms.
///
/// Fixes focus issues where a [TextField] traps D-pad / Siri Remote focus after
/// the on-screen keyboard is dismissed.
///
/// Wrap your app with [TvTextFieldScope] and optionally call
/// [TvTextFieldPlatform.ensureInitialized] in `main()` so tvOS / Android TV are
/// detected for [TvTextFieldImplementation.auto].
class TvTextField extends StatelessWidget {
  const TvTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
    this.onTap,
    this.onTapOutside,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.implementation = TvTextFieldImplementation.auto,
    this.focusDecoration,
    this.unfocusOnDismiss = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final bool canRequestFocus;
  final ValueChanged<bool>? onFocusChange;
  final TvTextFieldImplementation implementation;
  final BoxDecoration? focusDecoration;
  final bool unfocusOnDismiss;

  @override
  Widget build(BuildContext context) {
    return _TvTextFieldStateful(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: style,
      textAlign: textAlign,
      readOnly: readOnly,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      enabled: enabled,
      onTap: onTap,
      onTapOutside: onTapOutside,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      implementation: implementation,
      focusDecoration: focusDecoration,
      unfocusOnDismiss: unfocusOnDismiss,
    );
  }
}

class _TvTextFieldStateful extends StatefulWidget {
  const _TvTextFieldStateful({
    this.controller,
    this.focusNode,
    required this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
    this.onTap,
    this.onTapOutside,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.implementation = TvTextFieldImplementation.auto,
    this.focusDecoration,
    this.unfocusOnDismiss = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final bool canRequestFocus;
  final ValueChanged<bool>? onFocusChange;
  final TvTextFieldImplementation implementation;
  final BoxDecoration? focusDecoration;
  final bool unfocusOnDismiss;

  @override
  State<_TvTextFieldStateful> createState() => _TvTextFieldStatefulState();
}

class _TvTextFieldStatefulState extends State<_TvTextFieldStateful> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'TvTextField');
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _TvTextFieldStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller && widget.controller != null) {
      if (_ownsController) {
        _controller.dispose();
      }
      _ownsController = false;
      _controller = widget.controller!;
    }
    if (oldWidget.focusNode != widget.focusNode && widget.focusNode != null) {
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _ownsFocusNode = false;
      _focusNode = widget.focusNode!;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveTvTextFieldImplementation(widget.implementation);

    switch (resolved) {
      case TvTextFieldImplementation.androidNative:
        return AndroidTvTextField(
          controller: _controller,
          focusNode: _focusNode,
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
          onFocusChange: widget.onFocusChange,
          focusDecoration: widget.focusDecoration,
          canRequestFocus: widget.canRequestFocus,
        );
      case TvTextFieldImplementation.appleNative:
        return AppleTvTextField(
          controller: _controller,
          focusNode: _focusNode,
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
          onFocusChange: widget.onFocusChange,
          focusDecoration: widget.focusDecoration,
          canRequestFocus: widget.canRequestFocus,
        );
      case TvTextFieldImplementation.auto:
      case TvTextFieldImplementation.flutter:
      case TvTextFieldImplementation.native:
        return FlutterTvTextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: widget.decoration,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: widget.style,
          textAlign: widget.textAlign,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onTapOutside: widget.onTapOutside,
          canRequestFocus: widget.canRequestFocus,
          onFocusChange: widget.onFocusChange,
          focusDecoration: widget.focusDecoration,
          unfocusOnDismiss: widget.unfocusOnDismiss,
        );
    }
  }
}
