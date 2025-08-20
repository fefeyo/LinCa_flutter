import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/router/app_router.gr.dart';

/// ルーティング設定するページ一覧

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: HomeRoute.page, initial: true),
  ];
}
