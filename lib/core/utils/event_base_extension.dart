import 'package:linca_otaku_support/core/network/model/event_base.dart';

extension EventBaseExtension on EventBase {
  String get kanaIfOfficial {
    return this is OfficialEvent ? (this as OfficialEvent).kana : '';
  }

  String get imageUrlIfOfficial {
    return this is OfficialEvent ? (this as OfficialEvent).imageUrl : '';
  }
}
