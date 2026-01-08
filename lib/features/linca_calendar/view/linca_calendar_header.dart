import 'package:flutter/material.dart';

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
          '${focusedMonth.year}年 ${focusedMonth.month}月',
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
