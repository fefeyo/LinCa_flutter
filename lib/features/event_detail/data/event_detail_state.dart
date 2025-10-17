import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/network/model/user.dart';

part 'event_detail_state.freezed.dart';

@freezed
abstract class EventDetailState with _$EventDetailState {
  const factory EventDetailState({
    User? organizerUser,
  }) = _EventDetailState;
}
