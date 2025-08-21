import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/model/event.dart';
import '../../core/widgets/event/event_card.dart';

@RoutePage()
class RecentEventsPage extends HookConsumerWidget {
  const RecentEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              EventCard(
                event: Event(tags: <String>[
                  '#ラブライブ！スーパースター！',
                  '#Liella!',
                  'tag1',
                  'tag2',
                  'tag3',
                  'tag4',
                ]),
              ),
              EventCard(
                event: Event(tags: <String>['#ラブライブ！スーパースター！', '#Liella!']),
              ),
              EventCard(
                event: Event(tags: <String>['#ラブライブ！スーパースター！', '#Liella!']),
              ),
              EventCard(
                event: Event(tags: <String>['#ラブライブ！スーパースター！', '#Liella!']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
