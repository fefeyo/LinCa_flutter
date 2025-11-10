class AppConstants {
  static const String lincaScheme = 'linca://card/';
  static const String twitterScheme = 'https://x.com/';
  static const String instagramScheme = 'https://instagram.com/';
  static const String blueskyScheme = 'https://bsky.app/profile/';

  // SharedPreferences
  static const String badgeVersionKey = 'badge_version_key';
  static const String eventVersionKey = 'event_version_key';
  static const String groupVersionKey = 'group_version_key';
  static const String tagVersionKey = 'tag_version_key';
  static const String venueVersionKey = 'venue_version_key';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String participationVersionKey = 'participation_version_key';

  static const String eventLastFetchedAtKey = 'event_last_fetched_at_key';
  static const String userEventLastFetchedAtKey =
      'user_event_last_fetched_at_key';
  static const String participationLastFetchedAtKey =
      'participation_last_fetched_at_key';
  static const String friendLastFetchedAtKey = 'event_last_fetched_at_key';


  // Hero Animation Tag
  static const String heroTagLincaCardMyPage = 'LinCaCardMyPage';
  static const String heroTagLincaCardFriend = 'LinCaCardFriend';

  static const String seriesTagLovelive = 'series_lovelive';
  static const String seriesTagSunshine = 'series_sunshine';
  static const String seriesTagNijigasaki = 'series_nijigasaki';
  static const String seriesTagSuperstar = 'series_superstar';
  static const String seriesTagHasunosora = 'series_hasunosora';
  static const String seriesTagIkizulive = 'series_ikizulive';
  static const String seriesTagYohane = 'series_yohane';
  static const String seriesTagMusical = 'series_musical';
  static const String seriesTagCollaborative = 'series_collaborative';

  // 簡易プロフィールでの最大タグ表示数
  static const int maxSimpleProfileTagCount = 5;

  // 最大タグ設定数
  static const int maxProfileTagCount = 20;

  // チェックイン範囲
  static const int checkInRadius = 100;
}
