import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/choose_event_state.dart';
import 'view_model/choose_event_view_model.dart';

@RoutePage()
class ChooseEventPage extends HookConsumerWidget {
  const ChooseEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChooseEventState state = ref.watch(chooseEventViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('choose_event')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
