import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';

mixin ScreenAnalyticsManager {
  void logScreen(AnalyticsScreen screen) {
    useEffect(() {
      FirebaseAnalytics.instance.logScreenView(
        screenName: screen.name,
      );

      return null;
    }, <Object?>[]);
  }
}
