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
  static const String eventNotificationEnabled = 'event_notification_enabled';

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
  static const int checkInRadius = 300;

  static const int userNameMaxLength = 30;
  static const int bioMaxLength = 300;
  static const int snsMaxLength = 30;
  static const int eventMemoMaxLength = 500;
  static const int originalEventNameMaxLength = 70;
  static const int originalEventDescriptionMaxLength = 1000;
  static const int originalEventVenueMaxLength = 30;
  static const int originalEventOrganizerMaxLength = 30;
  static const int originalEventUrlMaxLength = 100;

  // 参考URL: https://w.atwiki.jp/lovelive-sif/pages/26.html
  static const List<String> defaultNames = <String>[
    '幻の学院生',
    '明るい学院生',
    '期待の学院生',
    '純粋な学院生',
    '素直な学院生',
    '元気な学院生',
    '天然な学院生',
    '勇敢な学院生',
    '憧れの学院生',
    '気になる学院生',
    '真面目な学院生',
    '不思議な学院生',
    '癒し系な学院生',
    '心優しい学院生',
    'さわやかな学院生',
    '頼りになる学院生',
    'さすらいの学院生',
    '正義感あふれる学院生',
    'カラオケ好きの学院生',
    'アイドル好きの学院生',
  ];

}
