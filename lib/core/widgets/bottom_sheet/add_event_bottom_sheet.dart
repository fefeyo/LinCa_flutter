import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/constants/event_type.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:linca_otaku_support/core/utils/providers.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';

import '../../../core/router/app_router.gr.dart';
import '../../../core/utils/context_extension.dart';
import '../../../features/create_event/data/create_event_type.dart';
import '../../constants/analytics_event.dart';
import '../../utils/coach_manager.dart';

class AddEventBottomSheet extends HookConsumerWidget
    with CoachManager, ScreenAnalyticsManager, EventAnalyticsManager {
  const AddEventBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.addEventBottomSheet);

    final GlobalKey<State<StatefulWidget>> selectFromOfficialEventKey =
        useMemoized(() => GlobalKey());

    final List<TutorialStep> steps = <TutorialStep>[
      TutorialStep(
        targetKey: selectFromOfficialEventKey,
        title: context.l10n.coach_step3_title,
        description: context.l10n.coach_step3_description,
        tag: 'official_event',
        onStepNext: (String _) =>
            logEvent(event: AnalyticsEvent.coachNextClick),
      ),
    ];

    useEffect(() {
      Future<void>.microtask(() async {
        if (!context.mounted) return;
        final PreferencesService preferences =
            ref.read(preferencesServiceProvider);
        showIfNeeded(
          context: context,
          preferences: preferences,
          steps: steps,
          onComplete: () => transitPage(
            context: context,
            routeInfo: ChooseEventRoute(
              eventType: EventType.official,
            ),
          ),
          onSkip: () => logEvent(event: AnalyticsEvent.coachSkipClick),
        );
      });

      return null;
    }, const <Object?>[]);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード重なり対策
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          maxHeight: 400,
        ),
        child: Column(
          children: <Widget>[
            Text(
              context.l10n.add_event_title,
              style: context.textTheme.titleLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: <Widget>[
                  ListTile(
                    key: selectFromOfficialEventKey,
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      context.l10n.add_official_event_select_from_list,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      logEvent(event: AnalyticsEvent.addEventOfficialClick);

                      transitPage(
                        context: context,
                        routeInfo: ChooseEventRoute(
                          eventType: EventType.official,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.diversity_3),
                    title: Text(
                      context.l10n.add_unofficial_event_select_from_list,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      logEvent(event: AnalyticsEvent.addEventOriginalClick);

                      transitPage(
                        context: context,
                        routeInfo: ChooseEventRoute(
                          eventType: EventType.unofficial,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.public),
                    title: Text(
                      context.l10n.add_event_create_public,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      logEvent(event: AnalyticsEvent.addEventCreatePublicClick);

                      transitPage(
                        context: context,
                        routeInfo: CreateEventRoute(
                            createEventType: CreateEventType.public),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.lock),
                    title: Text(
                      context.l10n.add_event_create_private,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      logEvent(
                          event: AnalyticsEvent.addEventCreatePrivateClick);

                      transitPage(
                        context: context,
                        routeInfo: CreateEventRoute(
                            createEventType: CreateEventType.private),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void transitPage(
      {required BuildContext context, required PageRouteInfo routeInfo}) {
    context.router.pop();
    context.router.push(routeInfo);
  }

  static Future<void> show(BuildContext context) async => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => const AddEventBottomSheet());
}
