import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/linca_event.dart';
import '../../core/widgets/bottom_sheet/my_event_sort_bottom_sheet.dart';
import '../../core/widgets/event/event_card.dart';
import 'data/choose_event_state.dart';
import 'view_model/choose_event_view_model.dart';

@RoutePage()
class ChooseEventPage extends HookConsumerWidget {
  const ChooseEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChooseEventState state = ref.watch(chooseEventViewModelProvider);
    final ChooseEventViewModel viewModel =
        ref.read(chooseEventViewModelProvider.notifier);
    final ValueNotifier<bool> isSearching = useState(false);
    final TextEditingController searchController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: isSearching.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'キーワード、イベントコードを入力',
                  border: InputBorder.none,
                ),
                onChanged: (String value) {
                  viewModel.setKeyword(value);
                },
              )
            : const Text('イベント一覧'),
        actions: <Widget>[
          IconButton(
            onPressed: () => MyEventSortBottomSheet.show(context),
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: Icon(isSearching.value ? Icons.close : Icons.search),
            onPressed: () {
              isSearching.value = !isSearching.value;
              if (!isSearching.value) {
                searchController.clear();
                viewModel.setKeyword('');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListView.separated(
          itemCount: state.sortedEvents.length,
          itemBuilder: (BuildContext context, int index) {
            final LincaEvent event = state.sortedEvents[index];
            return EventCard(lincaEvent: event);
          },
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 4),
        ),
      ),
    );
  }
}
