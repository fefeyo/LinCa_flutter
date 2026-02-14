import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/filter_settings.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:linca_otaku_support/core/utils/providers.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/features/linca_calendar/view_model/linca_calendar_view_model.dart';
import 'package:linca_otaku_support/features/my_event/data/my_event_state.dart';

import '../../../core/utils/context_extension.dart';
import '../../core/network/model/participation_info.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/widgets/dialog/on_the_day_event_dialog.dart';
import '../my_event/view_model/my_event_view_model.dart';
import 'view/home_drawer.dart';

@RoutePage()
class HomePage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> titles = <String>[
      context.l10n.my_event_title,
      context.l10n.event_calendar_title,
      context.l10n.my_page_title,
    ];
    final MyEventState myEventState = ref.watch(myEventViewModelProvider);
    final MyEventViewModel myEventViewModel =
        ref.read(myEventViewModelProvider.notifier);
    final LincaUser lincaUser = ref.watch(userControllerProvider).value!;
    final ValueNotifier<bool> isSearching = useState(false);
    final TextEditingController searchController = useTextEditingController();
    final List<LincaEvent> events =
        ref.read(eventControllerProvider).value ?? <LincaEvent>[];
    final List<ParticipationInfo> participations =
        ref.read(participationControllerProvider).value ??
            <ParticipationInfo>[];
    final LincaCalendarViewModel lincaCalendarViewModel =
        ref.read(lincaCalendarViewModelProvider.notifier);
    final int sortedParticipationCount = myEventState.sortedEvents
        .map((LincaEvent lincaEvent) =>
            myEventState.participations.getByEventId(lincaEvent.event.id))
        .whereType<ParticipationInfo>()
        .toList()
        .length;

    useEffect(() {
      Future<void> effect() async {
        final List<LincaEvent> todayEvents = events.getTodayEvents();
        final PreferencesService preferences =
            ref.read(preferencesServiceProvider);
        final DateTime? hideOnTheDayDialogDate =
            await preferences.getLastUpdatedAt(AppConstants.hideOnTheDayDialog);
        final bool hasSeenTutorial = await preferences.hasSeenTutorial();
        if (todayEvents.isNotEmpty &&
            hideOnTheDayDialogDate?.isToday != true &&
            hasSeenTutorial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            OnTheDayEventDialog.show(
              context: context,
              events: todayEvents,
              participations: participations,
            );
          });
        }
      }

      Future<void>.microtask(effect);

      return null;
    }, const <Object?>[]);

    return AutoTabsRouter(
      routes: const <PageRouteInfo<Object?>>[
        MyEventRoute(),
        LincaCalendarRoute(),
        MyRoute(),
      ],
      transitionBuilder:
          (BuildContext context, Widget child, Animation<double> animation) {
        final TabsRouter tabs = AutoTabsRouter.of(context);
        return Scaffold(
          appBar: AppBar(
              title: isSearching.value
                  ? TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            context.l10n.hint_choose_official_event_keyword,
                        border: InputBorder.none,
                      ),
                      style: context.textTheme.bodyMedium,
                      onChanged: (String value) {
                        myEventViewModel.setKeyword(value);
                      },
                    )
                  : Column(
                      children: <Widget>[
                        Text(
                          titles[tabs.activeIndex],
                          style: context.textTheme.titleMedium,
                        ),
                        if (tabs.activeIndex == 0)
                          Text(
                            context.l10n
                                .common_event_count(sortedParticipationCount),
                            style: context.textTheme.bodyMedium,
                          ),
                      ],
                    ),
              actions: <Widget>[
                if (tabs.activeIndex == 0)
                  IconButton(
                    onPressed: () async {
                      logEvent(event: AnalyticsEvent.myEventFilterClick);

                      final FilterSettings? result = await context.router.push(
                        EventSortFilterRoute(
                          initialSettings: myEventState.filterSettings,
                          needInputArea: true,
                          needHiddenOriginalEventArea: true,
                          needDisplayOrderArea: true,
                          needParticipationArea: true,
                          needEventTypeArea: true,
                          needTagsArea: true,
                        ),
                      );
                      if (result != null) {
                        myEventViewModel.setFilterSettings(result);
                      }
                    },
                    icon: const Icon(Icons.sort),
                  ),
                if (tabs.activeIndex == 0)
                  IconButton(
                    icon: Icon(isSearching.value ? Icons.close : Icons.search),
                    onPressed: () {
                      isSearching.value = !isSearching.value;
                      if (!isSearching.value) {
                        searchController.clear();
                        myEventViewModel.setKeyword('');
                      }

                      logEvent(event: AnalyticsEvent.myEventSearchClick);
                    },
                  ),
                if (tabs.activeIndex == 1)
                  TextButton.icon(
                    onPressed: () => lincaCalendarViewModel.resetCalendar(),
                    icon: const Icon(Icons.today),
                    label: Text(context.l10n.common_today),
                  ),
              ]),
          drawer: HomeDrawer(
            lincaUser: lincaUser,
          ),
          body: FadeTransition(opacity: animation, child: child),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabs.activeIndex,
            onTap: (int index) {
              logEvent(
                event: AnalyticsEvent.homeTabClick,
                params: <String, Object>{'index': index},
              );

              tabs.setActiveIndex(index);

              if (index != 0) {
                isSearching.value = false;
              }
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.event),
                label: titles[0],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.event_note),
                label: titles[1],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: titles[2],
              ),
            ],
          ),
        );
      },
    );
  }
}
