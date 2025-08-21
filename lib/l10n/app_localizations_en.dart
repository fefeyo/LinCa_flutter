// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LinCa';

  @override
  String get drawer_home => 'Home';

  @override
  String get drawer_myEvents => 'My Events';

  @override
  String get drawer_profile => 'Profile';

  @override
  String events_count(int count) {
    return '$count events';
  }
}
