import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  Future<void> updateLastUpdatedAt(String key) async {
    await sharedPreferences.setString(key, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastUpdatedAt(String key) async {
    final String? lastUpdatedAt = sharedPreferences.getString(key);
    return lastUpdatedAt != null ? DateTime.parse(lastUpdatedAt) : null;
  }

  Future<void> markTutorialAsSeen() async {
    await sharedPreferences.setBool(AppConstants.hasSeenTutorial, true);
  }

  Future<bool> hasSeenTutorial() async {
    return sharedPreferences.getBool(AppConstants.hasSeenTutorial) ?? false;
  }

  Future<void> clear() async {
    await sharedPreferences.clear();
  }
}
