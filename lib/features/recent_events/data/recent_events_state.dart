import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_events_state.freezed.dart';
part 'recent_events_state.g.dart';

@freezed
abstract class RecentEventsState with _$RecentEventsState {
  const factory RecentEventsState({
    @Default('') String name,
  }) = _RecentEventsState;

  factory RecentEventsState.fromJson(Map<String, dynamic> json) =>
      _$RecentEventsStateFromJson(json);
}
