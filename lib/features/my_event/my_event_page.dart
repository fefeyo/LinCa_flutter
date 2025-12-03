import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/features/my_event/data/my_event_state.dart';
import 'package:linca_otaku_support/features/my_event/view_model/my_event_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/linca_event.dart';
import '../../core/widgets/bottom_sheet/add_event_bottom_sheet.dart';
import '../../core/widgets/event/event_card.dart';

@RoutePage()
class MyEventPage extends HookConsumerWidget {
  const MyEventPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyEventState state = ref.watch(myEventViewModelProvider);
    final GlobalKey eventListKey = useMemoized(() => GlobalKey());
    final GlobalKey floatingActionButtonKey = useMemoized(() => GlobalKey());

    final List<TutorialStep> steps = <TutorialStep>[
      TutorialStep(
        targetKey: eventListKey,
        title: 'イベント一覧',
        description: 'ここに参加したイベントが表示されます',
        tag: 'event_list',
      ),
      TutorialStep(
        targetKey: floatingActionButtonKey,
        title: context.l10n.add_event_button_title,
        description: context.l10n.add_event_button_description,
        tag: 'add_event',
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
                    nextText: context.l10n.common_next,
                    finshText: context.l10n.common_next,
                    skipText: context.l10n.common_skip,
                    onComplete: () => AddEventBottomSheet.show(context),
                    onSkip: () => sharedPreferences.setBool(
                        AppConstants.hasSeenTutorial, true)).show();
              }
            });
          });
        }
      });

      return null;
    }, const <Object?>[]);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: state.sortedEvents.isEmpty
            ? Center(
                child: Text(
                  'まだイベント参加情報がありません',
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
