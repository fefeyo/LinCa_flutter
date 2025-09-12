import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/core/widgets/bottom_sheet/my_event_sort_bottom_sheet.dart';
import 'package:fefeyo_flutter_template/features/home/view/home_drawer.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      context.l10n.my_event_title,
      context.l10n.recent_event_title,
      context.l10n.my_page_title,
    ];

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
                  onPressed: () => MyEventSortBottomSheet.showWithInput(context),
                  icon: const Icon(Icons.sort),
                ),
            ],
          ),
          drawer: const HomeDrawer(),
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
