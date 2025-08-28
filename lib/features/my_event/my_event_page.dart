import 'package:fefeyo_flutter_template/core/models/linca_event.dart';
import 'package:fefeyo_flutter_template/core/network/providers.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/core/widgets/bottom_sheet/add_event_bottom_sheet.dart';
import 'package:fefeyo_flutter_template/core/widgets/event/event_card.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
          ListView.builder(
              itemCount: value.length,
              itemBuilder: (BuildContext context, int index) {
                return EventCard(lincaEvent: value[index]);
              }),
        AsyncError<List<LincaEvent>>(
          :final Object error,
          stackTrace: final StackTrace _
        ) =>
          Center(
            child: Column(
              children: <Widget>[
                Text(
                  'エラーが発生しました\n$error',
                  style: context.textTheme.headlineMedium,
                ),
                ElevatedButton(
                  onPressed: () => ref.refresh(eventControllerProvider),
                  child: const Text('再読み込み'),
                ),
              ],
            ),
          ),
        AsyncLoading<List<LincaEvent>>() => const Center(
            child: CircularProgressIndicator(),
          ),
        _ => const SizedBox.shrink(),
      };
    }

    return Scaffold(
      body: generateEventList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEventBottomSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
