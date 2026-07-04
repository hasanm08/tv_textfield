import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_textfield/tv_textfield.dart';
import 'package:tv_textfield/src/platform/native_tv_text_field_params.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TvTextField enters editing on activation key', (tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: TvTextFieldScope(
          child: Scaffold(
            body: TvTextField(
              focusNode: focusNode,
              implementation: TvTextFieldImplementation.flutter,
              decoration: const InputDecoration(hintText: 'Type here'),
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(InputDecorator), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('TvTextField dismisses editing on escape key', (tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: TvTextFieldScope(
          child: Scaffold(
            body: TvTextField(
              focusNode: focusNode,
              implementation: TvTextFieldImplementation.flutter,
              decoration: const InputDecoration(labelText: 'Field'),
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(InputDecorator), findsOneWidget);
  });

  testWidgets('TvTextField ignores directional keys while not editing', (
    tester,
  ) async {
    final firstFocus = FocusNode();
    final secondFocus = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: TvTextFieldScope(
          child: Scaffold(
            body: Column(
              children: [
                TvTextField(
                  focusNode: firstFocus,
                  implementation: TvTextFieldImplementation.flutter,
                  decoration: const InputDecoration(labelText: 'First'),
                ),
                TvTextField(
                  focusNode: secondFocus,
                  implementation: TvTextFieldImplementation.flutter,
                  decoration: const InputDecoration(labelText: 'Second'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    firstFocus.requestFocus();
    await tester.pump();
    expect(firstFocus.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(secondFocus.hasFocus, isTrue);
  });

  testWidgets('TvTextFieldScope sets directional navigation mode', (tester) async {
    NavigationMode? mode;

    await tester.pumpWidget(
      MaterialApp(
        home: TvTextFieldScope(
          child: Builder(
            builder: (context) {
              mode = MediaQuery.of(context).navigationMode;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(mode, NavigationMode.directional);
  });

  test('resolveTvTextFieldImplementation honors explicit flutter mode', () {
    expect(
      resolveTvTextFieldImplementation(TvTextFieldImplementation.flutter),
      TvTextFieldImplementation.flutter,
    );
  });

  test('resolveTvTextFieldImplementation honors explicit native modes', () {
    expect(
      resolveTvTextFieldImplementation(TvTextFieldImplementation.androidNative),
      TvTextFieldImplementation.androidNative,
    );
    expect(
      resolveTvTextFieldImplementation(TvTextFieldImplementation.appleNative),
      TvTextFieldImplementation.appleNative,
    );
  });

  test('resolveTvTextFieldImplementation auto uses flutter on desktop', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(
      resolveTvTextFieldImplementation(TvTextFieldImplementation.auto),
      TvTextFieldImplementation.flutter,
    );
  });

  test('nativeCreationParamsEqual detects equivalent maps', () {
    final left = buildNativeCreationParams(
      text: 'hello',
      decoration: const InputDecoration(hintText: 'Hint'),
      style: null,
      textAlign: TextAlign.start,
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: true,
      autofocus: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
    final right = Map<String, dynamic>.from(left);

    expect(nativeCreationParamsEqual(left, right), isTrue);
    expect(
      nativeCreationParamsEqual(left, {...left, 'text': 'world'}),
      isFalse,
    );
  });

  test('TvTextFieldPlatform falls back when channel is unavailable', () async {
    final info = await TvTextFieldPlatform.ensureInitialized();
    expect(info.isAndroidTv, isFalse);
    expect(info.isTvOS, isFalse);
    expect(info.isTelevision, isFalse);
  });
}
