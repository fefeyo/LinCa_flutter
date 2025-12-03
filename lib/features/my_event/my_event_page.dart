import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/features/my_event/data/my_event_state.dart';
import 'package:linca_otaku_support/features/my_event/view_model/my_event_view_model.dart';

import '../../core/models/linca_event.dart';
import '../../core/widgets/bottom_sheet/add_event_bottom_sheet.dart';
import '../../core/widgets/event/event_card.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyEventState state = ref.watch(myEventViewModelProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: state.sortedEvents.isEmpty
            ? Center(
                child: Text(
                  'まだイベント参加情報がありません',
                  style: context.textTheme.titleMedium,
                ),
              )
            : ListView.separated(
                clipBehavior: Clip.none,
                itemCount: state.sortedEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  final LincaEvent lincaEvent =
                      state.sortedEvents.keys.elementAt(index);
                  final ParticipationInfo participationInfo =
                      state.sortedEvents.values.elementAt(index);
                  return EventCard(
                    lincaEvent: lincaEvent,
                    participationInfo: participationInfo,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 12,
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEventBottomSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
