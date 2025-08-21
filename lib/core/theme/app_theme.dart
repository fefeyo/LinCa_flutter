import 'package:flutter/material.dart';
import 'app_typography.dart';

ThemeData buildAppTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    // 角丸・影など M3 の推奨に寄せる
    visualDensity: VisualDensity.standard,
    // 文字
    textTheme: buildTextTheme(scheme),
    // AppBar / FAB など代表コンポーネントのチューニング
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outlineVariant),
      selectedColor: scheme.secondaryContainer,
      disabledColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: scheme.onSurface),
      secondaryLabelStyle: TextStyle(color: scheme.onSecondaryContainer),
    ),
    // 角丸の統一感
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),
  );
}
