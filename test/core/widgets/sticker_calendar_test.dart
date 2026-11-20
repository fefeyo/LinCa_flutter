import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_day_cell.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_header.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_weekly_row.dart';

import 'linca_interaction_test.dart' show testApp;

void main() {
  for (final bool reduced in <bool>[false, true]) {
    testWidgets('sticker selection and both markers, reduced=$reduced',
        (WidgetTester tester) async {
      int calls = 0;
      Widget cell(bool selected) => testApp(
            SizedBox(
              width: 40,
              height: 40,
              child: LincaCalendarDayCell(
                date: DateTime(2026, 11, 19),
                isToday: true,
                isHoliday: false,
                isSelected: selected,
                hasEvent: true,
                hasAnniversary: true,
                onTap: () => calls++,
              ),
            ),
            reduced: reduced,
          );
      await tester.pumpWidget(cell(false));
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      await tester.tap(find.text('19'));
      await tester.pumpWidget(cell(true));
      await tester.pumpAndSettle();
      expect(calls, 1);
      final AnimatedRotation rotation =
          tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(rotation.turns, reduced ? 0 : -0.012);
      expect(rotation.duration, reduced ? Duration.zero : isNot(Duration.zero));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('compact header handles large text and disabled navigation',
      (WidgetTester tester) async {
    int calls = 0;
    await tester.pumpWidget(testApp(
      SizedBox(
        width: 288,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          LincaCalendarHeader(
            focusedMonth: DateTime(2026, 11),
            onPrev: null,
            onNext: () => calls++,
          ),
          const LincaCalendarWeeklyRow(),
        ]),
      ),
      textScale: 1.5,
    ));
    await tester.tap(find.byIcon(Icons.chevron_left));
    expect(calls, 0);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
