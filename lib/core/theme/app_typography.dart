import 'package:flutter/material.dart';

TextTheme buildTextTheme(ColorScheme scheme) {
  final TextTheme base =
      Typography.material2021(platform: TargetPlatform.android).black;
  final Color onSurface = scheme.onSurface;

  return base.copyWith(
    displayLarge: base.displayLarge
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w800, letterSpacing: -.5),
    displayMedium: base.displayMedium
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w800, letterSpacing: -.4),
    displaySmall: base.displaySmall
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -.3),
    headlineLarge: base.headlineLarge
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w800),
    headlineMedium: base.headlineMedium
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
    headlineSmall: base.headlineSmall
        ?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
    titleLarge:
        base.titleLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
    titleMedium: base.titleMedium
        ?.copyWith(color: onSurface.withValues(alpha: .9), fontWeight: FontWeight.w700),
    titleSmall: base.titleSmall
        ?.copyWith(color: onSurface.withValues(alpha: .88), fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(color: onSurface, height: 1.35),
    bodyMedium:
        base.bodyMedium?.copyWith(color: onSurface.withValues(alpha: .88), height: 1.35),
    bodySmall:
        base.bodySmall?.copyWith(color: onSurface.withValues(alpha: .75), height: 1.3),
    labelLarge: base.labelLarge
        ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700, letterSpacing: .2),
    labelMedium: base.labelMedium
        ?.copyWith(color: onSurface.withValues(alpha: .85), fontWeight: FontWeight.w600),
    labelSmall: base.labelSmall
        ?.copyWith(color: onSurface.withValues(alpha: .7), fontWeight: FontWeight.w600),
  );
}
