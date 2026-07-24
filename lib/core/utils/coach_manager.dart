import 'package:flutter/material.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';

mixin CoachManager {
  Future<void> showIfNeeded({
    required BuildContext context,
    required PreferencesService preferences,
    required List<TutorialStep> steps,
    bool isCompletable = false,
    required VoidCallback onComplete,
    required VoidCallback onSkip,
  }) async {
    final bool hasSeenTutorial = await preferences.hasSeenTutorial();
    if (!hasSeenTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            TutorialOverlay(
              context: context,
              steps: steps,
              nextText: context.l10n.common_next,
              finshText: isCompletable
                  ? context.l10n.common_finish
                  : context.l10n.common_next,
              skipText: context.l10n.common_skip,
              onComplete: onComplete,
              onSkip: () {
                onSkip();
                preferences.markTutorialAsSeen();
              },
            ).show();
          }
        });
      });
    }
  }
}
