import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';

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
          tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            side: BorderSide(
                color: Theme.of(context).colorScheme.surface, width: 3),
          ),
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF573D50)
                  : const Color(0xFFFCE0EC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Theme.of(context).colorScheme.surface, width: 3),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 5,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: LincaAnimatedLabel(
              child: Text(
                key: ValueKey<String>(
                    '${focusedMonth.year}-${focusedMonth.month}'),
                context.l10n.event_calendar_year_month_title(
                    '${focusedMonth.year}', '${focusedMonth.month}'),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            side: BorderSide(
                color: Theme.of(context).colorScheme.surface, width: 3),
          ),
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
