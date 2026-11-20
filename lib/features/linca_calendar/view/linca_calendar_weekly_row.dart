import 'package:flutter/material.dart';

class LincaCalendarWeeklyRow extends StatelessWidget {
  const LincaCalendarWeeklyRow({super.key});

  static const List<String> _labels = <String>[
    '日',
    '月',
    '火',
    '水',
    '木',
    '金',
    '土',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels.map((String label) {
        return Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: label == '日'
                    ? const Color(0xFFFF5BA1).withValues(alpha: 0.12)
                    : label == '土'
                        ? const Color(0xFF4CC3FF).withValues(alpha: 0.12)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
