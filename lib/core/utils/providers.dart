import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_service.dart';

final Provider<SharedPreferences> sharedPreferencesProvider =
Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError(); // 上書き前提
});

final Provider<PreferencesService> preferencesServiceProvider =
Provider<PreferencesService>((Ref ref) {
  final SharedPreferences preferences = ref.watch(sharedPreferencesProvider);
  return PreferencesService(preferences);
});
