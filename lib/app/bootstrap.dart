import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/notification/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/providers.dart';
import 'app.dart';
import 'initial_data.dart';

void bootstrap({required String serverClientId}) {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    GoogleSignIn.instance.initialize(serverClientId: serverClientId);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(preferences),
    ]);
    await loadInitialData(container);

    await _initTimeZone();
    await _initLocalNotifications(
        container.read(localNotificationsPluginProvider));

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  }, (Object error, StackTrace stacktrace) {
    FirebaseCrashlytics.instance.recordError(error, stacktrace, fatal: true);
  });
}

Future<void> _initTimeZone() async {
  tz.initializeTimeZones();

  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
}

Future<void> _initLocalNotifications(
    FlutterLocalNotificationsPlugin plugin) async {
  const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings ios = DarwinInitializationSettings();

  const InitializationSettings settings = InitializationSettings(
    android: android,
    iOS: ios,
  );

  await plugin.initialize(settings: settings);
}
