import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/auth/providers.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import '../data/created_event_list_state.dart';

final StateNotifierProvider<CreatedEventListViewModel, CreatedEventListState>
    createdEventListViewModelProvider =
    StateNotifierProvider<CreatedEventListViewModel, CreatedEventListState>(
        (Ref ref) {
  final String? uid = ref.watch(uidProvider);
  final List<LincaEvent> events =
      ref.watch(userEventControllerProvider).value ?? <LincaEvent>[];
  final List<LincaEvent> myEvents = events.where((LincaEvent event) {
    final UnOfficialEvent unofficialEvent = event.event as UnOfficialEvent;
    return unofficialEvent.createdBy == uid;
  }).toList();

  return CreatedEventListViewModel(events: myEvents);
});

class CreatedEventListViewModel extends StateNotifier<CreatedEventListState> {
  CreatedEventListViewModel({
    required this.events,
  }) : super(CreatedEventListState(events: events));

  final List<LincaEvent> events;
}
