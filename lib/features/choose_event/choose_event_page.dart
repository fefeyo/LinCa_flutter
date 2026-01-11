import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/coach_manager.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';

import '../../core/constants/analytics_event.dart';
import '../../core/constants/event_type.dart';
import '../../core/models/filter_settings.dart';
import '../../core/models/linca_event.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/providers.dart';
import '../../core/widgets/event/event_card.dart';
import 'data/choose_event_state.dart';
import 'view_model/choose_event_view_model.dart';

@RoutePage()
class ChooseEventPage extends HookConsumerWidget
    with CoachManager, ScreenAnalyticsManager, EventAnalyticsManager {
  const ChooseEventPage({
    super.key,
    required this.eventType,
  });

  final EventType eventType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(eventType == EventType.official
        ? AnalyticsScreen.chooseOfficialEvent
        : AnalyticsScreen.chooseUnOfficialEvent);

    final ChooseEventState state = ref.watch(chooseEventViewModelProvider);
    final ChooseEventViewModel viewModel =
        ref.read(chooseEventViewModelProvider.notifier);
    final ValueNotifier<bool> isSearching = useState(false);
    final TextEditingController searchController = useTextEditingController();
    final GlobalKey<State<StatefulWidget>> eventListKey =
        useMemoized(() => GlobalKey());

    final List<TutorialStep> steps = <TutorialStep>[
      TutorialStep(
        targetKey: eventListKey,
        title: context.l10n.coach_step4_title,
        description: context.l10n.coach_step4_description,
        tag: 'event_list',
        onStepNext: (String _) =>
            logEvent(event: AnalyticsEvent.coachNextClick),
      ),
    ];

    useEffect(() {
      Future<void>.microtask(() async {
        viewModel.setEventType(eventType);

        if (!context.mounted) return;
        final PreferencesService preferences =
            ref.read(preferencesServiceProvider);
        showIfNeeded(
          context: context,
          preferences: preferences,
          steps: steps,
          onComplete: () => <dynamic, dynamic>{},
          onSkip: () => logEvent(event: AnalyticsEvent.coachSkipClick),
        );
      });

      return null;
    }, const <Object?>[]);

    return Scaffold(
      appBar: AppBar(
        title: isSearching.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: context.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: state.eventType == EventType.official
                      ? context.l10n.hint_choose_official_event_keyword
                      : context.l10n.hint_choose_unofficial_event_keyword,
                  border: InputBorder.none,
                ),
                onChanged: (String value) {
                  viewModel.setKeyword(value);
                },
              )
            : Column(
                children: <Widget>[
                  Text(
                    context.l10n.title_choose_event,
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    context.l10n.common_event_count(state.sortedEvents.length),
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
        actions: <Widget>[
          if (eventType == EventType.official)
            IconButton(
              onPressed: () async {
                logEvent(event: AnalyticsEvent.chooseEventFilterClick);

                final FilterSettings? result = await context.router.push(
                  EventSortFilterRoute(
                    initialSettings: state.filterSettings,
                    needDisplayOrderArea: true,
                    needHiddenParticipationArea: true,
                    needTagsArea: true,
                  ),
                );
                if (result != null) {
                  viewModel.setFilterSettings(result);
                }
              },
              icon: const Icon(Icons.sort),
            ),
          IconButton(
            icon: Icon(isSearching.value ? Icons.close : Icons.search),
            onPressed: () {
              logEvent(event: AnalyticsEvent.chooseEventSearchClick);

              isSearching.value = !isSearching.value;
              if (!isSearching.value) {
                searchController.clear();
                viewModel.setKeyword('');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: state.sortedEvents.isNotEmpty
            ? RefreshIndicator(
                child: ListView.separated(
                  key: eventListKey,
                  clipBehavior: Clip.none,
                  itemCount: state.sortedEvents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final LincaEvent lincaEvent = state.sortedEvents[index];
                    final ParticipationInfo? participationInfo =
                        state.participations[lincaEvent];
                    return EventCard(
                      lincaEvent: lincaEvent,
                      onClick: () {
                        logEvent(
                            event: AnalyticsEvent.chooseEventEventCardClick);

                        context.router.push(
                          EventDetailRoute(
                            lincaEvent: lincaEvent,
                            participationInfo: participationInfo,
                          ),
                        );
                      },
                      participationInfo: participationInfo,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 12),
                ),
                onRefresh: () async {
                  logEvent(event: AnalyticsEvent.chooseEventRefreshed);

                  await viewModel.refresh(eventType);
                })
            : Center(
                child: Text(
                  context.l10n.event_list_empty_title,
                  style: context.textTheme.titleMedium,
                ),
              ),
      ),
    );
  }
}
