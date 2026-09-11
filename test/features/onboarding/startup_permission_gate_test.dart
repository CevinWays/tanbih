import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/features/location/presentation/bloc/location_bloc.dart';
import 'package:tanbih/features/location/presentation/bloc/location_state.dart';
import 'package:tanbih/features/notification/presentation/bloc/notification_settings_cubit.dart';
import 'package:tanbih/features/onboarding/presentation/widgets/startup_permission_gate.dart';
import 'package:tanbih/features/settings/data/datasources/app_preferences_local_data_source.dart';

class MockPreferences extends Mock implements AppPreferencesLocalDataSource {}

class MockNotificationCubit extends MockCubit<NotificationSettingsState>
    implements NotificationSettingsCubit {}

/// A stand-in that lets the test drive the location status directly.
class FakeLocationBloc extends Cubit<LocationState> implements LocationBloc {
  FakeLocationBloc() : super(const LocationState());

  void settle(LocationStatus status) => emit(LocationState(status: status));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockPreferences preferences;
  late MockNotificationCubit notifications;
  late FakeLocationBloc location;

  setUp(() {
    preferences = MockPreferences();
    notifications = MockNotificationCubit();
    location = FakeLocationBloc();

    when(() => preferences.getNotificationPromptShown()).thenReturn(false);
    when(
      () => preferences.setNotificationPromptShown(any()),
    ).thenAnswer((_) async {});
    when(() => notifications.requestPermission()).thenAnswer((_) async {});
    when(
      () => notifications.state,
    ).thenReturn(const NotificationSettingsState());
  });

  Future<void> pumpGate(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocationBloc>.value(value: location),
          BlocProvider<NotificationSettingsCubit>.value(value: notifications),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('id'), Locale('en')],
          home: StartupPermissionGate(
            preferences: preferences,
            child: const Scaffold(body: Text('home')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('asks for notifications once the location flow settles', (
    tester,
  ) async {
    await pumpGate(tester);
    // Nothing while location is still resolving: two system dialogs at once
    // get dismissed unread.
    expect(find.text('Allow notifications'), findsNothing);

    location.settle(LocationStatus.success);
    await tester.pumpAndSettle();

    expect(find.text('Allow notifications'), findsOneWidget);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    verify(() => notifications.requestPermission()).called(1);
  });

  testWidgets('still asks when the location flow failed', (tester) async {
    // A refused location leaves reminders worth enabling, so the prompt is
    // not held hostage to it.
    await pumpGate(tester);
    location.settle(LocationStatus.failure);
    await tester.pumpAndSettle();

    expect(find.text('Allow notifications'), findsOneWidget);
  });

  testWidgets('"Not now" records the ask without requesting', (tester) async {
    await pumpGate(tester);
    location.settle(LocationStatus.success);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    verifyNever(() => notifications.requestPermission());
    verify(() => preferences.setNotificationPromptShown(true)).called(1);
  });

  testWidgets('never asks twice', (tester) async {
    // Android stops showing its dialog after repeated refusals, so nagging
    // is how the permission gets lost for good.
    when(() => preferences.getNotificationPromptShown()).thenReturn(true);

    await pumpGate(tester);
    location.settle(LocationStatus.success);
    await tester.pumpAndSettle();

    expect(find.text('Allow notifications'), findsNothing);
  });

  testWidgets('does not ask when permission is already granted', (
    tester,
  ) async {
    when(
      () => notifications.state,
    ).thenReturn(const NotificationSettingsState(hasPermission: true));

    await pumpGate(tester);
    location.settle(LocationStatus.success);
    await tester.pumpAndSettle();

    expect(find.text('Allow notifications'), findsNothing);
    verifyNever(() => preferences.setNotificationPromptShown(any()));
  });
}
