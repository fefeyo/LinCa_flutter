import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/event_list_state.dart';
import 'view_model/event_list_view_model.dart';

@RoutePage()
class EventListPage extends HookConsumerWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EventListState state = ref.watch(eventListViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('event_list')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
