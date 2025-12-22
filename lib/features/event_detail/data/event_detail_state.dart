import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/check_in_condition.dart';

import '../../../core/network/model/user.dart';

part 'event_detail_state.freezed.dart';

@freezed
abstract class EventDetailState with _$EventDetailState {
  const factory EventDetailState({
    CheckInCondition? checkInCondition,
    required bool isLoading,
  }) = _EventDetailState;
}
