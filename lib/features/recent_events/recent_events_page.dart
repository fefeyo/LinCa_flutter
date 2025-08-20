import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/recent_events_state.dart';
import 'view_model/recent_events_view_model.dart';

@RoutePage()
class RecentEventsPage extends HookConsumerWidget {
  const RecentEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecentEventsState state = ref.watch(recentEventsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('recent_events')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
