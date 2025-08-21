import 'package:fefeyo_flutter_template/core/network/model/event.dart';
import 'package:fefeyo_flutter_template/core/widgets/event/event_card.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/participation_type.dart';
import 'data/my_event_state.dart';
import 'view_model/my_event_view_model.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyEventState state = ref.watch(myEventViewModelProvider);
    return Scaffold(
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              EventCard(
                event: Event(type: ParticipationType.onSite, tags: [
                  '#ラブライブ！スーパースター！',
                  '#Liella!',
                  'tag1',
                  'tag2',
                  'tag3',
                  'tag4',
                ]),
              ),
              EventCard(
                event: Event(
                    type: ParticipationType.streaming,
                    tags: ['#ラブライブ！スーパースター！', '#Liella!']),
              ),
              EventCard(
                event: Event(
                    type: ParticipationType.liveViewing,
                    tags: ['#ラブライブ！スーパースター！', '#Liella!']),
              ),
              EventCard(
                event: Event(
                    type: ParticipationType.absent,
                    tags: ['#ラブライブ！スーパースター！', '#Liella!']),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
