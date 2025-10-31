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
  Color get colorLovelive => colorFromHex('#FF1493');

  Color get colorSunshine => colorFromHex('#00BFFF');

  Color get colorNijigasaki => colorFromHex('#FFD010');

  Color get colorSuperstar => colorFromHex('#9932CC');

  Color get colorHasunosora => colorFromHex('#F7B2BE');

  Color get colorIkizulive => colorFromHex('#F5A027');

  Color get colorYohane => colorFromHex('#008B8B');

  Color get colorMusical => colorFromHex('#D70035');

  Color get textGrey => colorFromHex('#333333');

  LinearGradient gradientMuse({
    required Alignment begin,
    required Alignment end,
  }) =>
      LinearGradient(
        colors: <Color>[
          colorLovelive.withValues(alpha: _startOpacity),
          colorLovelive.withValues(alpha: _middleOpacity),
          colorLovelive.withValues(alpha: _endOpacity),
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
          colorSunshine.withValues(alpha: _startOpacity),
          colorSunshine.withValues(alpha: _middleOpacity),
          colorSunshine.withValues(alpha: _endOpacity),
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
          colorSuperstar.withValues(alpha: _startOpacity),
          colorSuperstar.withValues(alpha: _middleOpacity),
          colorSuperstar.withValues(alpha: _endOpacity),
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
          colorLovelive,
          colorLovelive.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get gradientAqoursForGraph => LinearGradient(
        colors: <Color>[
          colorSunshine,
          colorSunshine.withValues(alpha: 0.5),
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
          colorSuperstar,
          colorSuperstar.withValues(alpha: 0.5),
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
