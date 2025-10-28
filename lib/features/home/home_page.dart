import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/filter_settings.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/linca_user_extension.dart';
import 'package:linca_otaku_support/features/my_event/data/my_event_state.dart';

import '../../../core/utils/context_extension.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/widgets/bottom_sheet/event_sort_bottom_sheet.dart';
import '../my_event/view_model/my_event_view_model.dart';
import 'view/home_drawer.dart';

@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> titles = <String>[
      context.l10n.my_event_title,
      context.l10n.recent_event_title,
      context.l10n.my_page_title,
    ];
    final MyEventState myEventState = ref.watch(myEventViewModelProvider);
    final MyEventViewModel myEventViewModel =
        ref.read(myEventViewModelProvider.notifier);
    final LincaUser lincaUser = ref.watch(userControllerProvider).value!;

    return AutoTabsRouter(
      routes: const <PageRouteInfo<Object?>>[
        MyEventRoute(),
        RecentEventsRoute(),
        MyRoute(),
      ],
      transitionBuilder:
          (BuildContext context, Widget child, Animation<double> animation) {
        final TabsRouter tabs = AutoTabsRouter.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(titles[tabs.activeIndex]),
            actions: <Widget>[
              if (tabs.activeIndex == 0)
                IconButton(
                  onPressed: () async {
                    final FilterSettings? result =
                        await EventSortBottomSheet.show(
                      context,
                      myEventState.filterSettings,
                      needInputArea: true,
                      needDisplayOrderArea: true,
                      needParticipationArea: true,
                      needSeriesTagArea: true,
                    );
                    if (result != null) {
                      myEventViewModel.setFilterSettings(result);
                    }
                  },
                  icon: const Icon(Icons.sort),
                ),
            ],
          ),
          drawer: HomeDrawer(
            userProfile: lincaUser.userProfile,
          ),
          body: FadeTransition(opacity: animation, child: child),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabs.activeIndex,
            onTap: tabs.setActiveIndex,
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
