import 'package:freezed_annotation/freezed_annotation.dart';

import '../../constants/participation_type.dart';

part 'participation_info.freezed.dart';

part 'participation_info.g.dart';

@freezed
abstract class ParticipationInfo with _$ParticipationInfo {
  const factory ParticipationInfo({
    @Default('') String eventId,
    ParticipationType? participationType,
    @Default('') String participationMemo,
    @Default('') String groupSlug,
  }) = _ParticipationInfo;

  factory ParticipationInfo.fromJson(Map<String, dynamic> json) =>
      _$ParticipationInfoFromJson(json);
}
