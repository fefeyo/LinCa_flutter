class AppConstants {
  static const String lincaScheme = 'linca://card/';
  static const String twitterScheme = 'https://x.com/';
  static const String instagramScheme = 'https://instagram.com/';
  static const String blueskyScheme = 'https://bsky.app/profile/';

  // Firebase CollectionPath
  static const String groupCollectionPath = 'groups';
  static const String badgeCollectionPath = 'badges';
  static const String userCollectionPath = 'users';
  static const String eventCollectionPath = 'events';
  static const String friendCollectionPath = 'friends';
  static const String participationsPath = 'participations';
  static const String tagPath = 'tags';
  static const String venuePath = 'venues';
  static const String userEventPath = 'user_events';

  // SharedPreferences
  static const String badgeLastUpdatedAtKey = 'badge_last_updated_at_key';
  static const String eventLastUpdatedAtKey = 'event_last_updated_at_key';
  static const String groupLastUpdatedAtKey = 'group_last_updated_at_key';
  static const String tagLastUpdatedAtKey = 'tag_last_updated_at_key';
  static const String venueLastUpdatedAtKey = 'venue_last_updated_at_key';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String participationLastUpdatedAtKey =
      'participation_last_updated_at_key';
  static const String hasSeenTutorial = 'has_seen_tutorial';

  static const String eventLastFetchedAtKey = 'event_last_fetched_at_key';
  static const String userEventLastFetchedAtKey =
      'user_event_last_fetched_at_key';
  static const String participationLastFetchedAtKey =
      'participation_last_fetched_at_key';
  static const String friendLastFetchedAtKey = 'event_last_fetched_at_key';
  static const String hideOnTheDayDialog = 'hide_on_the_day_dialog';

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

  // チェックイン範囲(m)
  static const int checkInRadius = 150;

  static const int userNameMaxLength = 30;
  static const int bioMaxLength = 300;
  static const int eventMemoMaxLength = 500;

}
