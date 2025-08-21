import 'package:flutter/material.dart';

TextTheme buildTextTheme(ColorScheme scheme) {
  // M3 の既定サイズを活かしつつ色だけ調和させる方針
  final TextTheme base =
      Typography.material2021(platform: TargetPlatform.android).black;
  final Color onSurface = scheme.onSurface;

  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(color: onSurface),
    displayMedium: base.displayMedium?.copyWith(color: onSurface),
    displaySmall: base.displaySmall?.copyWith(color: onSurface),
    headlineLarge: base.headlineLarge
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
    headlineSmall: base.headlineSmall
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
    titleLarge: base.titleLarge?.copyWith(color: onSurface),
    titleMedium:
        base.titleMedium?.copyWith(color: onSurface.withValues(alpha: .9)),
    titleSmall:
        base.titleSmall?.copyWith(color: onSurface.withValues(alpha: .9)),
    bodyLarge: base.bodyLarge?.copyWith(color: onSurface),
    bodyMedium:
        base.bodyMedium?.copyWith(color: onSurface.withValues(alpha: .87)),
    bodySmall: base.bodySmall?.copyWith(color: onSurface.withValues(alpha: .7)),
    labelLarge: base.labelLarge?.copyWith(color: scheme.onPrimary),
    labelMedium:
        base.labelMedium?.copyWith(color: onSurface.withValues(alpha: .8)),
    labelSmall:
        base.labelSmall?.copyWith(color: onSurface.withValues(alpha: .6)),
  );
}
