import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/local/controller/calendar_event_controller.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/utils/notification/providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/network/providers.dart';
import 'core/theme/app_schemes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/providers.dart';
import 'l10n/app_localizations.dart';

import 'core/router/app_router.dart';

final AppRouter appRouter = AppRouter();

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    GoogleSignIn.instance.initialize(
        serverClientId:
            // ignore: lines_longer_than_80_chars
            '630270810691-cavclpg0rs7vr4kgojc93fv08ovrssgl.apps.googleusercontent.com');
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(preferences),
    ]);
    await Future.wait(<Future<List<Object>>>[
      container.read(badgeControllerProvider.future),
      container.read(groupControllerProvider.future),
      container.read(tagControllerProvider.future),
      container.read(venueControllerProvider.future),
    ]);
    await container.read(userControllerProvider.future);
    await Future.wait(<Future<List<LincaEvent>>>[
      container.read(eventControllerProvider.future),
      container.read(userEventControllerProvider.future),
    ]);
    await container.read(calendarEventsProvider.future);

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

  await plugin.initialize(settings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.light,
      theme: buildAppTheme(lightScheme).copyWith(
        extensions: <ThemeExtension<dynamic>>[buildBrandColors(lightScheme)],
      ),
      darkTheme: buildAppTheme(darkScheme).copyWith(
        extensions: <ThemeExtension<dynamic>>[buildBrandColors(darkScheme)],
      ),
    );
  }
}
