import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

class LincaCalendarHeader extends StatelessWidget {
  const LincaCalendarHeader({
    super.key,
    required this.focusedMonth,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          context.l10n.event_calendar_year_month_title(
              '${focusedMonth.year}', '${focusedMonth.month}'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
