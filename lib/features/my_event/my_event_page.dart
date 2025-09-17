import 'package:fefeyo_flutter_template/core/models/linca_event.dart';
import 'package:fefeyo_flutter_template/core/network/providers.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/core/widgets/bottom_sheet/add_event_bottom_sheet.dart';
import 'package:fefeyo_flutter_template/core/widgets/common/common_simple_loading.dart';
import 'package:fefeyo_flutter_template/core/widgets/event/event_card.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/widgets/common/common_simple_list_error.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LincaEvent>> events =
        ref.watch(eventControllerProvider);

    Widget generateEventList() {
      return switch (events) {
        AsyncData<List<LincaEvent>>(:final List<LincaEvent> value) =>
          ListView.separated(
            itemCount: value.length,
            itemBuilder: (BuildContext context, int index) {
              return EventCard(lincaEvent: value[index]);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 4,);
            }
          ),
        AsyncError<List<LincaEvent>>(
          :final Object error,
          stackTrace: final StackTrace _
        ) =>
          CommonSimpleListError(
            error: error,
            retry: () => ref.refresh(eventControllerProvider),
          ),
        AsyncLoading<List<LincaEvent>>() => const CommonSimpleLoading(),
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
