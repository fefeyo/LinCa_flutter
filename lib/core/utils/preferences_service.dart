import 'dart:convert';

import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class PreferencesService {
  PreferencesService(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  Future<void> updateLastUpdatedAt(String key, DateTime lastUpdatedAt) async {
    await sharedPreferences.setString(key, lastUpdatedAt.toIso8601String());
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

  Future<void> updateAppSettings(AppSettings appSettings) async {
    final String json = jsonEncode(appSettings.toJson());
    await sharedPreferences.setString(AppConstants.appSettings, json);
  }

  AppSettings getAppSettings() {
    final String? jsonString =
        sharedPreferences.getString(AppConstants.appSettings);
    if (jsonString == null) return const AppSettings();
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;

    return AppSettings.fromJson(json);
  }

  Future<void> clear() async {
    await sharedPreferences.clear();
  }

  Future<void> clearUserSignInData() async {
    await sharedPreferences.remove(AppConstants.hasSeenOnboarding);
    await sharedPreferences.remove(AppConstants.participationLastUpdatedAtKey);
  }
}
