import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';

part 'created_event_list_state.freezed.dart';

@freezed
abstract class CreatedEventListState with _$CreatedEventListState {
  const factory CreatedEventListState({
    @Default([]) List<LincaEvent> events,
  }) = _CreatedEventListState;
}
