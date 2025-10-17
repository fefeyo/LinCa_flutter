import 'package:freezed_annotation/freezed_annotation.dart';

import '../network/model/event_base.dart';
import '../network/model/group.dart';
import '../network/model/tag.dart';
import '../network/model/venue.dart';

part 'linca_event.freezed.dart';

@freezed
abstract class LincaEvent with _$LincaEvent {
  const factory LincaEvent({
    @Default(EventBase.official()) EventBase event,
    @Default(<Tag>[]) List<Tag> tags,
    @Default(Venue()) Venue venue,
    @Default(Group()) Group group,
  }) = _LincaEvent;
}
