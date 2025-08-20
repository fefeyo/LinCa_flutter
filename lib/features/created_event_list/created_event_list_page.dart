import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/created_event_list_state.dart';
import 'view_model/created_event_list_view_model.dart';

@RoutePage()
class CreatedEventListPage extends HookConsumerWidget {
  const CreatedEventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreatedEventListState state =
        ref.watch(createdEventListViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('created_event_list')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
