import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'app_router.gr.dart';
import 'route_name.dart';

/// Route table. Screens are annotated with `@RoutePage()`; run build_runner
/// after adding one.
@singleton
@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: RouteName.splash, page: HomeRoute.page, initial: true),
  ];
}
