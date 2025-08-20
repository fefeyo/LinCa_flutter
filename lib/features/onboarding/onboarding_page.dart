import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/onboarding_state.dart';
import 'view_model/onboarding_view_model.dart';

@RoutePage()
class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('onboarding')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
