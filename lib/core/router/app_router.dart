import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';
import 'auth_guard.dart';

/// ルーティング設定するページ一覧

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(
          page: HomeRoute.page,
          children: <AutoRoute>[
            AutoRoute(page: MyEventRoute.page),
            AutoRoute(page: LincaCalendarRoute.page),
            AutoRoute(page: MyRoute.page),
          ],
          guards: const <AutoRouteGuard>[AuthGuard()],
          initial: true,
        ),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(
          page: LoginRoute.page,
        ),
        AutoRoute(page: ChooseEventRoute.page),
        AutoRoute(page: EventDetailRoute.page),
        AutoRoute(page: CreateEventRoute.page),
        AutoRoute(page: LincaDetailRoute.page),
        AutoRoute(page: LincaEditRoute.page),
        AutoRoute(page: TradedLincaListRoute.page),
        AutoRoute(page: QrCodeReadRoute.page),
        AutoRoute(page: CreatedEventListRoute.page),
        AutoRoute(page: AcquiredBadgeRoute.page),
        AutoRoute(page: SelectFavoriteTagRoute.page),
        AutoRoute(page: HighlightRoute.page),
        AutoRoute(page: OutputParticipateEventsRoute.page),
        CustomRoute<EventSortFilterRoute>(
          page: EventSortFilterRoute.page,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          duration: const Duration(milliseconds: 500),
        ),
      ];
}
