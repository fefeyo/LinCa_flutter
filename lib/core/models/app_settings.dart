import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    // 全体の通知設定
    @Default(false) bool isNotificationEnabled,
    // マイイベントに登録済みのイベントを通知するか
    @Default(false) bool isMyEventNotificationEnabled,
    // マイイベントの通知タイプ
    @Default(EventNotificationType.allParticipation)
    EventNotificationType eventNotificationType,
    // 参加登録していないイベント通知
    @Default(false) bool isAllEventNotificationEnabled,
    // ラブライブ！のイベント通知
    @Default(false) bool isLoveLiveNotificationEnabled,
    // ラブライブ！サンシャイン!!のイベント通知
    @Default(false) bool isSunshineNotificationEnabled,
    // ラブライブ！虹ヶ咲学園スクールアイドル同好会のイベント通知
    @Default(false) bool isNijigasakiNotificationEnabled,
    // ラブライブ！スーパースター!!のイベント通知
    @Default(false) bool isSuperstarNotificationEnabled,
    // ラブライブ！蓮ノ空女学院スクールアイドルクラブのイベント通知
    @Default(false) bool isHasunosoraNotificationEnabled,
    // イキヅライブ！LOVELIVE!BLUEBIRDのイベント通知
    @Default(false) bool isIkizuliveNotificationEnabled,
    // スクールアイドルミュージカルのイベント通知
    @Default(false) bool isMusicalNotificationEnabled,
    // 幻日のヨハネのイベント通知
    @Default(false) bool isYohaneNotificationEnabled,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}

enum EventNotificationType {
  allParticipation,
  onlyHasCheckedIn,
}
