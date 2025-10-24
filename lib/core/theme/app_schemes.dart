import 'package:flutter/material.dart';

/// ブランドの基準色（LinCaのポップ感：シアン→ピンク系）
const Color kSeed = Color(0xFF4CC3FF); // 例：シアン
const Color kSecondarySeed = Color(0xFFFF5BA1); // 例：ピンク

/// ライト/ダークの ColorScheme を fromSeed で生成。
final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: kSeed,
  brightness: Brightness.light,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kSeed,
  brightness: Brightness.dark,
);

/// 必要なら “イベント系のアクセント” を別トークンとして扱う拡張
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({required this.gradStart, required this.gradEnd});

  final Color gradStart;
  final Color gradEnd;

  @override
  BrandColors copyWith({Color? gradStart, Color? gradEnd}) => BrandColors(
      gradStart: gradStart ?? this.gradStart, gradEnd: gradEnd ?? this.gradEnd);

  @override
  ThemeExtension<BrandColors> lerp(
      ThemeExtension<BrandColors>? other, double t) {
    final BrandColors o = other as BrandColors;
    return BrandColors(
      gradStart: Color.lerp(gradStart, o.gradStart, t)!,
      gradEnd: Color.lerp(gradEnd, o.gradEnd, t)!,
    );
  }
}

BrandColors buildBrandColors(ColorScheme scheme) => BrandColors(
      gradStart: scheme.primary,
      gradEnd: kSecondarySeed,
    );
