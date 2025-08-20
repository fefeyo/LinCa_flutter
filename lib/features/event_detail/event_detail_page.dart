import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/event_detail_state.dart';
import 'view_model/event_detail_view_model.dart';

@RoutePage()
class EventDetailPage extends HookConsumerWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EventDetailState state = ref.watch(eventDetailViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('event_detail')),
      body: Center(
        child: Text(state.name),
      ),
    );
  }
}
