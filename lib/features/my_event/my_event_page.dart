import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/coach_manager.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/features/my_event/data/my_event_state.dart';
import 'package:linca_otaku_support/features/my_event/view_model/my_event_view_model.dart';

import '../../core/models/linca_event.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/providers.dart';
import '../../core/widgets/bottom_sheet/add_event_bottom_sheet.dart';
import '../../core/widgets/event/event_card.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget with CoachManager {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyEventState state = ref.watch(myEventViewModelProvider);
    final GlobalKey eventListKey = useMemoized(() => GlobalKey());
    final GlobalKey floatingActionButtonKey = useMemoized(() => GlobalKey());

    final List<TutorialStep> steps = <TutorialStep>[
      TutorialStep(
        targetKey: eventListKey,
        title: context.l10n.coach_step1_title,
        description: context.l10n.coach_step1_description,
        tag: 'event_list',
      ),
      TutorialStep(
        targetKey: floatingActionButtonKey,
        title: context.l10n.coach_step2_title,
        description: context.l10n.coach_step2_description,
        tag: 'add_event',
      ),
    ];

    useEffect(() {
      Future<void>.microtask(() async {
        if (!context.mounted) return;
        final PreferencesService preferences =
            ref.read(preferencesServiceProvider);
        await showIfNeeded(
          context: context,
          preferences: preferences,
          steps: steps,
          onComplete: () => AddEventBottomSheet.show(context),
        );
      });

      return null;
    }, const <Object?>[]);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: state.sortedEvents.isEmpty
            ? Center(
                key: eventListKey,
                child: Text(
                  context.l10n.event_list_empty_title,
                  style: context.textTheme.titleMedium,
                ),
              )
            : ListView.separated(
                key: eventListKey,
                clipBehavior: Clip.none,
                itemCount: state.sortedEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  final LincaEvent lincaEvent =
                      state.sortedEvents.keys.elementAt(index);
                  final ParticipationInfo participationInfo =
                      state.sortedEvents.values.elementAt(index);
                  return EventCard(
                    lincaEvent: lincaEvent,
                    onClick: () => context.router.push(
                      EventDetailRoute(
                        lincaEvent: lincaEvent,
                        participationInfo: participationInfo,
                      ),
                    ),
                    participationInfo: participationInfo,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 12,
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        key: floatingActionButtonKey,
        onPressed: () => AddEventBottomSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
