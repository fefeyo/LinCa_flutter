import 'package:flutter/material.dart';

Color colorFromHex(String hexColor) {
  final String cleanedHex = hexColor.replaceFirst('#', '');
  final String fullHex = cleanedHex.length == 6 ? 'FF$cleanedHex' : cleanedHex;

  return Color(int.parse(fullHex, radix: 16));
}

const double _startOpacity = 0.8;
const double _middleOpacity = 0.2;
const double _endOpacity = 0.0;

extension ColorSchemeExtension on ColorScheme {
  Color get colorMuse => colorFromHex('#E4007F');

  Color get colorAqours => colorFromHex('#00BFFF');

  Color get colorNijigasaki => colorFromHex('#FCC800');

  Color get colorLiella => colorFromHex('#9932CC');

  Color get colorHasunosora => colorFromHex('#FFC0CB');

  Color get colorIkizulive => colorFromHex('#87CEEB');

  Color get textGrey => colorFromHex('#333333');

  LinearGradient gradientMuse({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorMuse.withValues(alpha: _startOpacity),
          colorMuse.withValues(alpha: _middleOpacity),
          colorMuse.withValues(alpha: _endOpacity),
        ],
        begin: begin,
        end: end,
      );

  LinearGradient gradientAqours({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorAqours.withValues(alpha: _startOpacity),
          colorAqours.withValues(alpha: _middleOpacity),
          colorAqours.withValues(alpha: _endOpacity),
        ],
        begin: begin,
        end: end,
      );

  LinearGradient gradientNijigasaki({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorNijigasaki.withValues(alpha: _startOpacity),
          colorNijigasaki.withValues(alpha: _middleOpacity),
          colorNijigasaki.withValues(alpha: _endOpacity),
        ],
        begin: begin,
        end: end,
      );

  LinearGradient gradientLiella({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorLiella.withValues(alpha: _startOpacity),
          colorLiella.withValues(alpha: _middleOpacity),
          colorLiella.withValues(alpha: _endOpacity),
        ],
        begin: begin,
        end: end,
      );

  LinearGradient gradientHasunosora({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorHasunosora.withValues(alpha: _startOpacity),
          colorHasunosora.withValues(alpha: _middleOpacity),
          colorHasunosora.withValues(alpha: _endOpacity),
        ],
        begin: begin,
        end: end,
      );

  LinearGradient gradientIkizulive({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorIkizulive.withValues(alpha: _startOpacity),
          colorIkizulive.withValues(alpha: _middleOpacity),
          colorIkizulive.withValues(alpha: _endOpacity),
        ],
        begin: begin,
        end: end,
      );

  LinearGradient get gradientMuseForGraph => LinearGradient(
        colors: <Color>[
          colorMuse,
          colorMuse.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get gradientAqoursForGraph => LinearGradient(
        colors: <Color>[
          colorAqours,
          colorAqours.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get gradientNijigasakiForGraph => LinearGradient(
        colors: <Color>[
          colorNijigasaki,
          colorNijigasaki.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get gradientLiellaForGraph => LinearGradient(
        colors: <Color>[
          colorLiella,
          colorLiella.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get gradientHasunosoraForGraph => LinearGradient(
        colors: <Color>[
          colorHasunosora,
          colorHasunosora.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get gradientIkizuliveForGraph => LinearGradient(
        colors: <Color>[
          colorIkizulive,
          colorIkizulive.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
}
