import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/network/providers.dart';
import 'core/theme/app_schemes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

import 'core/router/app_router.dart';

final AppRouter appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize(
      serverClientId:
          '630270810691-cavclpg0rs7vr4kgojc93fv0'
              '8ovrssgl.apps.googleusercontent.com');

  final ProviderContainer container = ProviderContainer();
  await container.read(badgeControllerProvider.future);
  await container.read(groupControllerProvider.future);
  await container.read(tagControllerProvider.future);
  await container.read(venueControllerProvider.future);
  await container.read(eventControllerProvider.future);
  await container.read(userEventControllerProvider.future);
  await container.read(participationControllerProvider.future);
  await container.read(userControllerProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
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
