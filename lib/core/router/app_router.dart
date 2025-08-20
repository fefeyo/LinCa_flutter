import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';

/// ルーティング設定するページ一覧

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: MyEventRoute.page),
    AutoRoute(page: RecentEventsRoute.page),
    AutoRoute(page: MyRoute.page),
    AutoRoute(page: ChooseEventRoute.page),
    AutoRoute(page: EventListRoute.page),
    AutoRoute(page: EventDetailRoute.page),
    AutoRoute(page: CreateEventRoute.page),
    AutoRoute(page: LincaDetailRoute.page),
    AutoRoute(page: LincaEditRoute.page),
    AutoRoute(page: TradedLincaListRoute.page),
    AutoRoute(page: QrCodeReadRoute.page),
    AutoRoute(page: CreatedEventListRoute.page),

  ];
}
