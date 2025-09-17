import '../../../core/utils/context_extension.dart';
import 'package:flutter/material.dart';

class ParticipationStatusBadge extends StatelessWidget {
  const ParticipationStatusBadge({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          text,
          style: context.textTheme.labelMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
