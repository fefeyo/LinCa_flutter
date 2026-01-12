import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/event_memory.dart';

import '../../constants/participation_type.dart';

part 'participation_info.freezed.dart';

part 'participation_info.g.dart';

@freezed
abstract class ParticipationInfo with _$ParticipationInfo {
  @JsonSerializable(explicitToJson: true)
  const factory ParticipationInfo({
    @Default('') String eventId,
    ParticipationType? participationType,
    @Default('') String participationMemo,
    @Default('') String groupSlug,
    @Default(<EventMemory>[]) List<EventMemory> eventMemories,
  }) = _ParticipationInfo;

  factory ParticipationInfo.fromJson(Map<String, dynamic> json) =>
      _$ParticipationInfoFromJson(json);
}
