import 'package:collection/collection.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

extension ParticipationListExtension on List<ParticipationInfo> {
  ParticipationInfo? getByEventId(String eventId) => firstWhereOrNull(
        (ParticipationInfo participationInfo) =>
            participationInfo.eventId == eventId,
      );

  bool hasEventId(String eventId) =>
      any((ParticipationInfo participationInfo) =>
          participationInfo.eventId == eventId);
}
