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
    AutoRoute(path: RouteName.allPrayer, page: AllPrayerRoute.page),
    AutoRoute(path: RouteName.menu, page: MenuRoute.page),
    AutoRoute(path: RouteName.settings, page: SettingsRoute.page),
    AutoRoute(
      path: RouteName.prayerTimesSettings,
      page: PrayerTimesSettingsRoute.page,
    ),
    AutoRoute(
      path: RouteName.manualAdjustments,
      page: ManualAdjustmentsRoute.page,
    ),
    AutoRoute(
      path: RouteName.locationSettings,
      page: LocationSettingsRoute.page,
    ),
    AutoRoute(path: RouteName.cityPicker, page: CityPickerRoute.page),
    AutoRoute(path: RouteName.hijriSettings, page: HijriSettingsRoute.page),
    AutoRoute(
      path: RouteName.notificationSettings,
      page: NotificationSettingsRoute.page,
    ),
    AutoRoute(path: RouteName.qibla, page: QiblaRoute.page),
  ];
}
