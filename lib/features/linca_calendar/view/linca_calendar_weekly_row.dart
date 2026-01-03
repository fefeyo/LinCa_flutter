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
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }
}
