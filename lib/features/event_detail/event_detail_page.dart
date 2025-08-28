import 'package:fefeyo_flutter_template/core/models/linca_event.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class EventDetailPage extends HookConsumerWidget {
  const EventDetailPage({
    super.key,
    required this.lincaEvent,
  });

  final LincaEvent lincaEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('event_detail')),
      body: Center(
        child: Text(lincaEvent.event.title),
      ),
    );
  }
}
