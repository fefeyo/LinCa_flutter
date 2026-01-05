import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar.dart';

@RoutePage()
class LincaCalendarPage extends HookConsumerWidget {
  const LincaCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: LincaCalendar(),
        ),
      ),
    );
  }
}
