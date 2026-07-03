import 'package:flutter/material.dart';

/// Read-only visual that mirrors [TextField] styling while the field is not
/// being edited. Keeps D-pad navigation from getting trapped in a TextField.
class TvTextFieldDisplay extends StatelessWidget {
  const TvTextFieldDisplay({
    super.key,
    required this.text,
    required this.decoration,
    required this.style,
    required this.obscureText,
    required this.textAlign,
    required this.maxLines,
    required this.minLines,
    required this.hasFocus,
    this.focusDecoration,
  });

  final String text;
  final InputDecoration decoration;
  final TextStyle? style;
  final bool obscureText;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final bool hasFocus;
  final BoxDecoration? focusDecoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaults = theme.inputDecorationTheme;
    final effectiveDecoration = decoration.applyDefaults(defaults);

    final displayText = obscureText && text.isNotEmpty ? '•' * text.length : text;
    final hintText = effectiveDecoration.hintText ?? '';
    final showHint = displayText.isEmpty && hintText.isNotEmpty;

    final content = InputDecorator(
      decoration: effectiveDecoration,
      isFocused: hasFocus,
      isEmpty: displayText.isEmpty,
      child: Align(
        alignment: _alignmentFor(textAlign),
        widthFactor: 1,
        child: Text(
          showHint ? hintText : displayText,
          style: showHint
              ? effectiveDecoration.hintStyle ??
                  defaults.hintStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                  )
              : style ?? theme.textTheme.bodyLarge,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (focusDecoration == null) {
      return content;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: hasFocus ? focusDecoration : null,
      child: content,
    );
  }

  Alignment _alignmentFor(TextAlign align) {
    return switch (align) {
      TextAlign.left || TextAlign.start => Alignment.centerLeft,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      TextAlign.justify => Alignment.centerLeft,
    };
  }
}
