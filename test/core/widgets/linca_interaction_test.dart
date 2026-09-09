import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/theme/app_schemes.dart';
import 'package:linca_otaku_support/core/theme/app_theme.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/flip_card.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';
import 'package:linca_otaku_support/features/event_detail/view/custom_participation_button.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_day_cell.dart';
import 'package:linca_otaku_support/features/my_page/view/my_page_item.dart';
import 'package:linca_otaku_support/l10n/app_localizations.dart';

Widget testApp(Widget child, {bool reduced = false, double textScale = 1}) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildAppTheme(lightScheme),
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: reduced,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  final Map<String, Widget Function(VoidCallback? onPressed)> buttons =
      <String, Widget Function(VoidCallback? onPressed)>{
    'elevated': (VoidCallback? onPressed) => ElevatedButton(
          onPressed: onPressed,
          child: const Text('save'),
        ),
    'filled': (VoidCallback? onPressed) => FilledButton(
          onPressed: onPressed,
          child: const Text('save'),
        ),
    'outlined': (VoidCallback? onPressed) => OutlinedButton(
          onPressed: onPressed,
          child: const Text('save'),
        ),
    'text': (VoidCallback? onPressed) => TextButton(
          onPressed: onPressed,
          child: const Text('save'),
        ),
    'icon': (VoidCallback? onPressed) => IconButton(
          onPressed: onPressed,
          tooltip: 'save',
          icon: const Icon(Icons.save),
        ),
  };

  for (final MapEntry<String, Widget Function(VoidCallback? onPressed)> entry
      in buttons.entries) {
    testWidgets('${entry.key} keeps one callback per tap and disables safely',
        (WidgetTester tester) async {
      int calls = 0;
      await tester.pumpWidget(testApp(entry.value(() => calls++)));
      await tester.pumpAndSettle();
      final Finder control = find.byType(AnimatedScale).first;
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(control),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.widget<AnimatedScale>(control).scale, lessThan(1));
      expect(calls, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(tester.widget<AnimatedScale>(control).scale, 1);

      await tester.pumpWidget(testApp(entry.value(null)));
      await tester.pumpAndSettle();
      // Disabled content need not participate in hit testing.
      await tester.tapAt(tester.getCenter(control));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(tester.widget<AnimatedScale>(control).scale, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keyboard activation and focus survive theme animation',
      (WidgetTester tester) async {
    int calls = 0;
    await tester.pumpWidget(testApp(ElevatedButton(
      autofocus: true,
      onPressed: () => calls++,
      child: const Text('save'),
    )));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll and pointer cancellation do not activate a list item',
      (WidgetTester tester) async {
    int calls = 0;
    await tester.pumpWidget(testApp(ListView(
      children: <Widget>[
        MyPageItem(title: 'item', onClickItem: () => calls++),
        const SizedBox(height: 1600),
      ],
    )));
    await tester.pumpAndSettle();
    final Finder item = find.text('item');
    final TestGesture cancel =
        await tester.startGesture(tester.getCenter(item));
    await tester.pump(const Duration(milliseconds: 150));
    await cancel.cancel();
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.drag(item, const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested button does not also activate its list item',
      (WidgetTester tester) async {
    int rowCalls = 0;
    int buttonCalls = 0;
    await tester.pumpWidget(testApp(MyPageItem(
      title: 'account',
      onClickItem: () => rowCalls++,
      trailing: ElevatedButton(
        onPressed: () => buttonCalls++,
        child: const Text('unlink'),
      ),
    )));
    await tester.tap(find.text('unlink'));
    await tester.pumpAndSettle();
    expect(buttonCalls, 1);
    expect(rowCalls, 0);
    await tester.tap(find.text('account'));
    await tester.pumpAndSettle();
    expect(rowCalls, 1);
  });

  testWidgets('long press remains distinct from tap',
      (WidgetTester tester) async {
    int taps = 0;
    int longPresses = 0;
    await tester.pumpWidget(testApp(LincaInteractive(
      builder: (BuildContext context, WidgetStatesController states) => InkWell(
        statesController: states,
        onTap: () => taps++,
        onLongPress: () => longPresses++,
        child: const SizedBox(width: 200, height: 100, child: Text('card')),
      ),
    )));
    await tester.longPress(find.text('card'));
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(longPresses, 1);
  });

  testWidgets('reduced motion keeps controls stable and editable state intact',
      (WidgetTester tester) async {
    int calls = 0;
    Widget content() => Column(
          children: <Widget>[
            const TextField(),
            MyPageItem(title: 'item', onClickItem: () => calls++),
            ElevatedButton(
              onPressed: () => calls++,
              child: const Text('save'),
            ),
          ],
        );
    await tester.pumpWidget(testApp(content()));
    await tester.enterText(find.byType(TextField), 'keep me');
    await tester.pumpWidget(testApp(content(), reduced: true));
    await tester.pumpAndSettle();
    expect(find.text('keep me'), findsOneWidget);
    final TestGesture gesture =
        await tester.startGesture(tester.getCenter(find.text('item')));
    await tester.pumpAndSettle();
    for (final AnimatedScale scale
        in tester.widgetList<AnimatedScale>(find.byType(AnimatedScale))) {
      expect(scale.scale, 1);
      expect(scale.duration, Duration.zero);
    }
    await gesture.up();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('participation stays controlled by its parent during rapid taps',
      (WidgetTester tester) async {
    int calls = 0;
    ParticipationType selected = ParticipationType.absent;
    late StateSetter update;
    await tester.pumpWidget(testApp(StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        update = setState;
        return SizedBox(
          width: 130,
          child: CustomParticipationButton(
            participationType: ParticipationType.onSite,
            selectedParticipationType: selected,
            iconData: Icons.event_available,
            onClick: () => calls++,
          ),
        );
      },
    )));
    await tester.tap(find.byType(CustomParticipationButton));
    await tester.tap(find.byType(CustomParticipationButton));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(
      tester
          .widget<CustomParticipationButton>(
            find.byType(CustomParticipationButton),
          )
          .isSelected,
      isFalse,
    );
    update(() => selected = ParticipationType.onSite);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CustomParticipationButton>(
            find.byType(CustomParticipationButton),
          )
          .isSelected,
      isTrue,
    );
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendar preserves date callback and selected semantics',
      (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    int calls = 0;
    await tester.pumpWidget(testApp(SizedBox(
      width: 48,
      height: 48,
      child: LincaCalendarDayCell(
        date: DateTime(2026, 9, 9),
        isToday: true,
        isHoliday: false,
        isSelected: true,
        hasEvent: true,
        hasAnniversary: false,
        onTap: () => calls++,
      ),
    )));
    await tester.tap(find.text('9'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
        tester.getSemantics(find.byType(LincaCalendarDayCell)),
        matchesSemantics(
            isSelected: true,
            isButton: true,
            hasSelectedState: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
            label: '9',
            textDirection: TextDirection.ltr));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  for (final bool reduced in <bool>[false, true]) {
    testWidgets('flip handles rapid changes with reduced motion $reduced',
        (WidgetTester tester) async {
      Widget card(bool front) => testApp(
            FlipCard(
              isFront: front,
              front: const Text('front'),
              back: const Text('back'),
            ),
            reduced: reduced,
          );
      await tester.pumpWidget(card(false));
      expect(find.text('back'), findsOneWidget);
      await tester.pumpWidget(card(true));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpWidget(card(false));
      await tester.pumpAndSettle();
      expect(find.text('back'), findsOneWidget);
      await tester.pumpWidget(card(true));
      await tester.pumpAndSettle();
      expect(find.text('front'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('success keeps long messages and executes its effect only once',
      (WidgetTester tester) async {
    int calls = 0;
    await tester.pumpWidget(testApp(
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => context.showSuccessSnackBar(
              message: '保存しました。イベントの参加予定とメモを更新しました。' * 4,
              effect: () => calls++,
            ),
            child: const Text('save'),
          ),
        ),
        textScale: 1.5));
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
    expect(find.byType(LincaSuccessIcon), findsOneWidget);
    expect(calls, 1);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });
}
