import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';

mixin EventAnalyticsManager {
  void logEvent({
    required AnalyticsEvent event,
    Map<String, Object> params = const <String, Object>{},
  }) {
    FirebaseAnalytics.instance.logEvent(
      name: event.name,
      parameters: params,
    );
  }
}
