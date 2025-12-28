import 'package:flutter/material.dart';

import '../../../core/utils/context_extension.dart';

class TutorialCustomStepPage extends StatelessWidget {
  const TutorialCustomStepPage({
    super.key,
    required this.content,
    required this.title,
    required this.description,
  });

  final Widget content;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          content,
          const SizedBox(height: 24),
          Text(
            title,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
