import 'package:flutter/material.dart';

/// ブランドの基準色（ネオン感のあるサイバー×ポップ）
const Color kSeed = Color(0xFF5B6CFF);
const Color kSecondarySeed = Color(0xFFFF4DA6);
const Color kTertiarySeed = Color(0xFF00D1FF);

/// ライト/ダークの ColorScheme を fromSeed で生成。
final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: kSeed,
  secondary: kSecondarySeed,
  tertiary: kTertiarySeed,
  brightness: Brightness.light,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kSeed,
  secondary: kSecondarySeed,
  tertiary: kTertiarySeed,
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
