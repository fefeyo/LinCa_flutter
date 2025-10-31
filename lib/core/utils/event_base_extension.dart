import 'package:linca_otaku_support/core/network/model/event_base.dart';

extension EventBaseExtension on EventBase {
  String get displayKana =>
      this is OfficialEvent ? (this as OfficialEvent).kana : '';

  String get displayImageUrl =>
      this is OfficialEvent ? (this as OfficialEvent).imageUrl : '';

  String get displayCheckInId =>
      this is OfficialEvent ? (this as OfficialEvent).checkInId : '';

  bool get isCanceled =>
      this is OfficialEvent ? (this as OfficialEvent).cancelFlg : false;
}
