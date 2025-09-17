import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/utils/context_extension.dart';

class TutorialStepPage extends StatelessWidget {
  const TutorialStepPage({
    super.key,
    required this.animation,
    required this.title,
    required this.description,
  });

  final String animation;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Lottie.asset(animation, height: 350),
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
