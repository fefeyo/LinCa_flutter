// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'LinCa';

  @override
  String get drawer_home => 'ホーム';

  @override
  String get drawer_myEvents => 'マイイベント';

  @override
  String get drawer_profile => 'マイページ';

  @override
  String events_count(int count) {
    return '$count件のイベント';
  }
}
