// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i4;
import 'package:tanbih/features/menu/presentation/screens/menu_screen.dart'
    as _i3;
import 'package:tanbih/features/prayer_times/presentation/screens/all_prayer_screen.dart'
    as _i1;
import 'package:tanbih/features/prayer_times/presentation/screens/home_screen.dart'
    as _i2;

/// generated route for
/// [_i1.AllPrayerScreen]
class AllPrayerRoute extends _i4.PageRouteInfo<void> {
  const AllPrayerRoute({List<_i4.PageRouteInfo>? children})
    : super(AllPrayerRoute.name, initialChildren: children);

  static const String name = 'AllPrayerRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.AllPrayerScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.MenuScreen]
class MenuRoute extends _i4.PageRouteInfo<void> {
  const MenuRoute({List<_i4.PageRouteInfo>? children})
    : super(MenuRoute.name, initialChildren: children);

  static const String name = 'MenuRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.MenuScreen();
    },
  );
}
