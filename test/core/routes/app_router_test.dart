import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/routes/app_router.dart';
import 'package:tanbih/core/routes/route_name.dart';

/// Guards the route table.
///
/// Every screen was built and reachable in code, but the router only ever
/// listed Home — an edit had failed silently and nothing caught it. Analyze
/// was clean, the suite was green, and every navigation on the device died
/// at runtime with "Failed to navigate to SettingsRoute".
void main() {
  test('every screen the UI navigates to is registered', () {
    final paths = AppRouter().routes.map((r) => r.path).toSet();

    expect(
      paths,
      containsAll(<String>[
        RouteName.splash,
        RouteName.allPrayer,
        RouteName.menu,
        RouteName.settings,
        RouteName.prayerTimesSettings,
        RouteName.manualAdjustments,
        RouteName.locationSettings,
        RouteName.cityPicker,
        RouteName.hijriSettings,
        RouteName.notificationSettings,
      ]),
    );
  });

  test('exactly one route is the entry point', () {
    final initial = AppRouter().routes.where((r) => r.initial);
    expect(initial, hasLength(1));
    expect(initial.single.path, RouteName.splash);
  });

  test('paths are unique', () {
    final paths = AppRouter().routes.map((r) => r.path).toList();
    expect(paths.toSet().length, paths.length);
  });
}
