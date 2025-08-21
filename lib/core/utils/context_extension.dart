import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ThemeContextExt on BuildContext {
  /// Material Theme 全体
  ThemeData get theme => Theme.of(this);

  /// カラースキーム
  ColorScheme get colorScheme => theme.colorScheme;

  /// テキストテーマ
  TextTheme get textTheme => theme.textTheme;
}
