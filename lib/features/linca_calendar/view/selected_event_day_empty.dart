import 'package:flutter/material.dart';

import '../../../core/utils/context_extension.dart';

class SelectedEventDayEmpty extends StatelessWidget {
  const SelectedEventDayEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'この日のイベントはありません',
        style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
    );
  }
}
