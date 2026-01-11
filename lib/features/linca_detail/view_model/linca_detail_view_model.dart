import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import '../../../core/network/repository/participation_repository.dart';
import '../data/linca_detail_state.dart';

final StateNotifierProvider<LincaDetailViewModel, LincaDetailState>
    lincaDetailViewModelProvider =
    StateNotifierProvider<LincaDetailViewModel, LincaDetailState>((Ref ref) {
  final List<LincaEvent> events =
      ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
  final ParticipationRepository participationRepository =
      ref.read(participationRepositoryProvider);
  return LincaDetailViewModel(
    events: events,
    participationRepository: participationRepository,
  );
});

class LincaDetailViewModel extends StateNotifier<LincaDetailState> {
  LincaDetailViewModel({
    required this.events,
    required this.participationRepository,
  }) : super(const LincaDetailState());

  final List<LincaEvent> events;
  final ParticipationRepository participationRepository;

  Future<void> setUpcomingEvent(String? uid) async {
    if (uid?.isEmpty == true) return;
    final List<ParticipationInfo> participations =
        await participationRepository.get();
    final List<LincaEvent> participationEvents = participations
        .map((ParticipationInfo participation) {
          if (participation.participationType == ParticipationType.absent) {
            return null;
          }
          return events.firstWhereOrNull(
              (LincaEvent event) => event.event.id == participation.eventId);
        })
        .whereType<LincaEvent>()
        .toList();

    // 未来のイベントだけを抽出し、開催日時でソートして最も近いものを取得
    // イベント開催日であれば開催中のイベントを表示
    final List<LincaEvent> upcomingEvent = participationEvents
        .where(
          (LincaEvent event) =>
              event.event.date?.isAfter(DateTime.now()) == true ||
              event.event.date?.isToday == true,
        )
        .toList()
      ..sort(
        (LincaEvent a, LincaEvent b) => a.event.date!.compareTo(b.event.date!),
      );

    state = state.copyWith(
      participationEvents: participationEvents,
      upcomingEvents: upcomingEvent.take(2).toList(),
    );
  }
}
