import 'package:flutter/material.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_schemes.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

final AppRouter appRouter = AppRouter();

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
