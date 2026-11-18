import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';
import 'app_typography.dart';

ThemeData buildAppTheme(ColorScheme scheme) {
  return ThemeData(
    dividerColor: Colors.transparent,
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: scheme.onPrimary,
        backgroundColor: scheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ).copyWith(foregroundBuilder: lincaButtonForeground),
    ),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(foregroundBuilder: lincaButtonForeground),
    ),
    outlinedButtonTheme: const OutlinedButtonThemeData(
      style: ButtonStyle(foregroundBuilder: lincaButtonForeground),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(foregroundBuilder: lincaButtonForeground),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(foregroundBuilder: lincaButtonForeground),
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
      backgroundColor: scheme.surfaceContainer,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
