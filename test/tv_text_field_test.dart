import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_textfield/tv_textfield.dart';

void main() {
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
}
