import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform/tv_text_field_platform.dart';

/// Applies TV-friendly navigation defaults to descendant widgets.
///
/// Wrap your app or screen with this widget so [TvTextField] and other focusable
/// widgets use [NavigationMode.directional], which is required for reliable
/// D-pad / Siri Remote focus traversal on TV platforms.
class TvTextFieldScope extends StatelessWidget {
  const TvTextFieldScope({
    super.key,
    required this.child,
    this.navigationMode = NavigationMode.directional,
    this.enableActivateShortcut = true,
  });

  final Widget child;
  final NavigationMode navigationMode;

  /// Whether Select / Enter on a focused field should invoke [ActivateIntent].
  ///
  /// Enabled by default for Apple TV ([flutter-tvos](https://fluttertv.dev)) and
  /// other TV embedders that map the Siri Remote center button to Enter.
  final bool enableActivateShortcut;

  @override
  Widget build(BuildContext context) {
    Widget scoped = MediaQuery(
      data: MediaQuery.of(context).copyWith(navigationMode: navigationMode),
      child: child,
    );

    if (!enableActivateShortcut) {
      return scoped;
    }

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      },
      child: scoped,
    );
  }
}

/// Initializes TV platform detection. Call from `main()` before [runApp].
Future<void> initializeTvTextField() => TvTextFieldPlatform.ensureInitialized();
