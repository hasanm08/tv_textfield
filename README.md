# tv_textfield

A Flutter package that fixes common **TV / remote control** issues with `TextField` on **Android TV**, **Apple TV**, and other platforms — including D-pad focus getting stuck after the on-screen keyboard is dismissed ([flutter#147772](https://github.com/flutter/flutter/issues/147772)).

## Platform support

| Platform | Default backend | Soft keyboard | Hardware keyboard |
|----------|-----------------|---------------|-------------------|
| Android TV | Native `EditText` | Yes | Yes |
| Apple TV (tvOS) | Native `UITextField` | Yes (system keyboard) | Yes (Bluetooth) |
| iOS / iPadOS | Flutter | Yes | Yes |
| Android phone | Native `EditText` | Yes | Yes |
| macOS / Windows / Linux | Flutter | N/A | Yes |
| Web | Flutter | Browser keyboard | Yes |

Works with [flutter-tvos](https://fluttertv.dev) for Apple TV builds.

## Features

- **D-pad / Siri Remote friendly** — move between fields with arrows when not editing
- **Select / Enter to edit** — opens the keyboard without trapping navigation
- **Back / Menu / Escape to dismiss** — closes the keyboard and releases focus
- **Cross-platform** — native views on Android and Apple TV, Flutter fallback elsewhere
- **Drop-in API** — familiar `TextField`-like parameters

## Installation

```yaml
dependencies:
  tv_textfield: ^0.1.0
```

## Usage

Initialize platform detection (recommended for Apple TV auto-detection), wrap your app with `TvTextFieldScope`, and use `TvTextField`:

```dart
import 'package:flutter/material.dart';
import 'package:tv_textfield/tv_textfield.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeTvTextField();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TvTextFieldScope(
        child: MyHomePage(),
      ),
    );
  }
}
```

```dart
TvTextField(
  controller: controller,
  focusNode: focusNode,
  decoration: InputDecoration(
    labelText: 'Search',
    border: OutlineInputBorder(),
  ),
  textInputAction: TextInputAction.search,
  onSubmitted: (value) => debugPrint('Submitted: $value'),
)
```

### Remote controls

| Action | Android TV | Apple TV |
|--------|------------|----------|
| Move focus | D-pad arrows | Siri Remote swipe |
| Start editing | Select / Enter | Select (center click) |
| Dismiss keyboard | Back | Menu |

### Implementation modes

| Mode | Description |
|------|-------------|
| `auto` (default) | Native on Android; native on tvOS; Flutter elsewhere |
| `flutter` | Pure Flutter with TV focus fixes |
| `native` | Native on Android or Apple platforms |
| `androidNative` | Force Android `EditText` |
| `appleNative` | Force Apple `UITextField` |

```dart
TvTextField(
  implementation: TvTextFieldImplementation.flutter,
  // ...
)
```

## Example

```bash
cd example
flutter run                  # mobile / desktop
flutter run -d <tv-device>   # Android TV or Apple TV
```

### Android TV

Add the leanback launcher category if needed:

```xml
<intent-filter>
  <action android:name="android.intent.action.MAIN" />
  <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
</intent-filter>
```

### Apple TV

Use the [flutter-tvos](https://fluttertv.dev) toolchain to build for tvOS. The plugin registers for both `ios` and `tvos` targets with shared Swift sources.

## How it works

**Flutter mode** shows a read-only field display while focused but not editing. D-pad arrows are not consumed, so focus traversal keeps working. When the user activates the field, a real `TextField` is shown for typing.

**Native mode** embeds a platform text field (`EditText` on Android, `UITextField` on Apple platforms), delegating soft-keyboard behavior to the OS — the recommended approach for TV devices.

## License

MIT
