import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injector.config.dart';

/// Service locator. Resolve from it only in `bootstrap.dart` and in
/// `BlocProvider` factories — everything else takes its dependencies through
/// the constructor. See CLAUDE.md § Dependency Injection.
final sl = GetIt.instance;

@InjectableInit(generateForDir: ['lib'])
Future<void> configureDependencies() async => sl.init();
