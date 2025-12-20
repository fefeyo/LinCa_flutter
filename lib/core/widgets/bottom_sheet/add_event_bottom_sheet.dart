import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:linca_otaku_support/core/constants/event_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.gr.dart';
import '../../../core/utils/context_extension.dart';
import '../../../features/create_event/data/create_event_type.dart';
import '../../constants/app_constants.dart';

class AddEventBottomSheet extends HookWidget {
  const AddEventBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<State<StatefulWidget>> selectFromOfficialEventKey =
        useMemoized(() => GlobalKey());
    final GlobalKey<State<StatefulWidget>> selectFromOriginalEventKey =
        useMemoized(() => GlobalKey());
    final GlobalKey<State<StatefulWidget>> createPublicEventKey =
        useMemoized(() => GlobalKey());
    final GlobalKey<State<StatefulWidget>> createPrivateEventKey =
        useMemoized(() => GlobalKey());

    final List<TutorialStep> steps = <TutorialStep>[
      TutorialStep(
        targetKey: selectFromOfficialEventKey,
        title: context.l10n.add_event_official_title,
        description: context.l10n.add_event_official_description,
        tag: 'official_event',
      ),
      TutorialStep(
        targetKey: selectFromOriginalEventKey,
        title: context.l10n.add_event_original_title,
        description: context.l10n.add_event_original_description,
        tag: 'original_event',
      ),
      TutorialStep(
        targetKey: createPublicEventKey,
        title: context.l10n.add_event_create_public_title,
        description: context.l10n.add_event_create_public_description,
        tag: 'create_public',
      ),
      TutorialStep(
        targetKey: createPrivateEventKey,
        title: context.l10n.add_event_create_private_title,
        description: context.l10n.add_event_create_private_description,
        tag: 'create_private',
      ),
    ];

    useEffect(() {
      Future<void>.microtask(() async {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        final bool hasSeenTutorial =
            sharedPreferences.getBool(AppConstants.hasSeenTutorial) ?? false;
        if (!hasSeenTutorial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future<void>.delayed(const Duration(milliseconds: 200), () {
              if (context.mounted) {
                TutorialOverlay(
                  context: context,
                  steps: steps,
                  finshText: context.l10n.common_finish,
                  onFinish: () => sharedPreferences.setBool(
                      AppConstants.hasSeenTutorial, true),
                  skipText: context.l10n.common_skip,
                  onSkip: () => sharedPreferences.setBool(
                      AppConstants.hasSeenTutorial, true),
                  nextText: context.l10n.common_next,
                ).show();
              }
            });
          });
        }
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
                    onTap: () => transitPage(
                      context: context,
                      routeInfo: ChooseEventRoute(
                        eventType: EventType.official,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    key: selectFromOriginalEventKey,
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.diversity_3),
                    title: Text(
                      context.l10n.add_unofficial_event_select_from_list,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () => transitPage(
                      context: context,
                      routeInfo: ChooseEventRoute(
                        eventType: EventType.unofficial,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    key: createPublicEventKey,
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.public),
                    title: Text(
                      context.l10n.add_event_create_public,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () => transitPage(
                      context: context,
                      routeInfo: CreateEventRoute(
                          createEventType: CreateEventType.public),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    key: createPrivateEventKey,
                    tileColor: context.colorScheme.surface,
                    leading: const Icon(Icons.lock),
                    title: Text(
                      context.l10n.add_event_create_private,
                      style: context.textTheme.bodyMedium,
                    ),
                    onTap: () => transitPage(
                      context: context,
                      routeInfo: CreateEventRoute(
                          createEventType: CreateEventType.private),
                    ),
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
