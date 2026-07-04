import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tv_text_field_display.dart';
import '../tv_text_field_keys.dart';
import 'tv_text_field_platform.dart';

/// Pure Flutter TV text field used on desktop, web, iOS, and as a fallback.
class FlutterTvTextField extends StatefulWidget {
  const FlutterTvTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
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
    this.focusDecoration,
    this.unfocusOnDismiss = true,
    this.autofocusEditing = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool readOnly;
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
  final BoxDecoration? focusDecoration;
  final bool unfocusOnDismiss;
  final bool autofocusEditing;

  @override
  State<FlutterTvTextField> createState() => _FlutterTvTextFieldState();
}

class _FlutterTvTextFieldState extends State<FlutterTvTextField> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant FlutterTvTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    widget.onFocusChange?.call(widget.focusNode.hasFocus);
    if (!widget.focusNode.hasFocus) {
      _exitEditing(dismissKeyboard: true, unfocus: false);
    }
  }

  void _enterEditing() {
    if (!widget.enabled || widget.readOnly) {
      return;
    }
    setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  void _exitEditing({
    required bool dismissKeyboard,
    required bool unfocus,
  }) {
    if (!_isEditing && !dismissKeyboard && !unfocus) {
      return;
    }
    if (dismissKeyboard) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }
    if (mounted) {
      setState(() => _isEditing = false);
    }
    if (unfocus) {
      widget.focusNode.unfocus();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (isDismissKey(key)) {
      if (_isEditing) {
        _exitEditing(
          dismissKeyboard: true,
          unfocus: widget.unfocusOnDismiss,
        );
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (!_isEditing && isActivationKey(key)) {
      _enterEditing();
      return KeyEventResult.handled;
    }

    if (!_isEditing && isDirectionalNavigationKey(key)) {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildEditingField();
    }

    return ListenableBuilder(
      listenable: Listenable.merge([widget.focusNode, widget.controller]),
      builder: (context, _) {
        return Focus(
          focusNode: widget.focusNode,
          canRequestFocus: widget.canRequestFocus && widget.enabled,
          skipTraversal: false,
          onKeyEvent: _handleKeyEvent,
          child: Actions(
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  _enterEditing();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTap: widget.enabled
                  ? () {
                      widget.onTap?.call();
                      _enterEditing();
                    }
                  : null,
              child: TvTextFieldDisplay(
                text: widget.controller.text,
                decoration: widget.decoration,
                style: widget.style,
                obscureText: widget.obscureText,
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                hasFocus: widget.focusNode.hasFocus,
                focusDecoration: widget.focusDecoration,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditingField() {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: widget.style,
      textAlign: widget.textAlign,
      readOnly: widget.readOnly,
      autofocus: widget.autofocusEditing,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: (value) {
        widget.onSubmitted?.call(value);
        _exitEditing(dismissKeyboard: true, unfocus: widget.unfocusOnDismiss);
      },
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      onTap: widget.onTap,
      onTapOutside: (event) {
        widget.onTapOutside?.call(event);
        _exitEditing(dismissKeyboard: true, unfocus: false);
      },
    );
  }
}

/// Picks the best [TvTextFieldImplementation] for the current platform.
TvTextFieldImplementation resolveTvTextFieldImplementation(
  TvTextFieldImplementation? requested,
) {
  if (requested == TvTextFieldImplementation.flutter) {
    return TvTextFieldImplementation.flutter;
  }
  if (requested == TvTextFieldImplementation.androidNative) {
    return TvTextFieldImplementation.androidNative;
  }
  if (requested == TvTextFieldImplementation.appleNative) {
    return TvTextFieldImplementation.appleNative;
  }
  if (requested == TvTextFieldImplementation.native) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return TvTextFieldImplementation.androidNative;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return TvTextFieldImplementation.appleNative;
    }
    return TvTextFieldImplementation.flutter;
  }

  final info = TvTextFieldPlatform.info;
  if (defaultTargetPlatform == TargetPlatform.android) {
    return TvTextFieldImplementation.androidNative;
  }
  if (defaultTargetPlatform == TargetPlatform.iOS && info.isTvOS) {
    return TvTextFieldImplementation.appleNative;
  }
  return TvTextFieldImplementation.flutter;
}

/// How [TvTextField] handles text input on the current platform.
enum TvTextFieldImplementation {
  /// Picks the best backend for the current device (default).
  auto,

  /// Pure Flutter implementation with TV focus fixes.
  flutter,

  /// Native platform view on Android or Apple platforms.
  native,

  /// Native Android [EditText] via platform view.
  androidNative,

  /// Native Apple [UITextField] via platform view (tvOS / iOS).
  appleNative,
}
