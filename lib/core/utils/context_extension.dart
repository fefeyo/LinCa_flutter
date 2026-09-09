import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/widgets/common/linca_interaction.dart';

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

extension BuildContextExtension on BuildContext {
  void showSuccessSnackBar({
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? effect,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const LincaSuccessIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
    effect?.call();
  }

  void showErrorSnackBar({
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
    VoidCallback? effect,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
    effect?.call();
  }
}
