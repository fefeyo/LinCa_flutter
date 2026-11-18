import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linca_otaku_support/core/widgets/common/pressable_scale.dart';

void main() {
  testWidgets('PressableScale keeps the child tap behavior', (
    WidgetTester tester,
  ) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PressableScale(
            child: TextButton(
              onPressed: () => tapCount += 1,
              child: const Text('Tap'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
  });
}
