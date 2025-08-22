import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/create_event_state.dart';
import 'data/create_event_type.dart';
import 'view_model/create_event_view_model.dart';

@RoutePage()
class CreateEventPage extends HookConsumerWidget {
  const CreateEventPage({
    super.key,
    required this.createEventType,
  });

  final CreateEventType createEventType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreateEventState state = ref.watch(createEventViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('create_event')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
