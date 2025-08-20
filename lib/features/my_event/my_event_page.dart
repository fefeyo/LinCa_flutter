import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/my_event_state.dart';
import 'view_model/my_event_view_model.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyEventState state = ref.watch(myEventViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('my_event')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
