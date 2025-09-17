import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

import '../../core/models/linca_event.dart';
import '../../core/network/providers.dart';
import '../../core/widgets/bottom_sheet/add_event_bottom_sheet.dart';
import '../../core/widgets/common/common_simple_list_error.dart';
import '../../core/widgets/common/common_simple_loading.dart';
import '../../core/widgets/event/event_card.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<LincaEvent, ParticipationInfo>> myEvents =
        ref.watch(participationControllerProvider);

    Widget generateEventList() {
      return switch (myEvents) {
        AsyncData<Map<LincaEvent, ParticipationInfo>>(
          :final Map<LincaEvent, ParticipationInfo> value
        ) =>
          value.isEmpty
              ? Center(
                  child: Text(
                    'まだイベント参加情報がありません',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  clipBehavior: Clip.none,
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int index) {
                    final LincaEvent lincaEvent = value.keys.elementAt(index);
                    final ParticipationInfo participationInfo =
                        value.values.elementAt(index);
                    return EventCard(
                      lincaEvent: lincaEvent,
                      participationInfo: participationInfo,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 16,
                    );
                  }),
        AsyncError<Map<LincaEvent, ParticipationInfo>>(
          :final Object error,
          stackTrace: final StackTrace _
        ) =>
          CommonSimpleListError(
            error: error,
            retry: () => ref.refresh(eventControllerProvider),
          ),
        AsyncLoading<Map<LincaEvent, ParticipationInfo>>() =>
          const CommonSimpleLoading(),
        _ => const SizedBox.shrink(),
      };
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: generateEventList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEventBottomSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
