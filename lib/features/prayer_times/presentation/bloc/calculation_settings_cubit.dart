import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/usecases/get_calculation_settings.dart';
import '../../domain/usecases/save_calculation_settings.dart';

enum CalculationSettingsStatus { initial, loading, success, failure }

class CalculationSettingsState extends Equatable {
  const CalculationSettingsState({
    this.status = CalculationSettingsStatus.initial,
    this.settings = const CalculationSettings(),
    this.failure,
  });

  final CalculationSettingsStatus status;
  final CalculationSettings settings;
  final Failure? failure;

  CalculationSettingsState copyWith({
    CalculationSettingsStatus? status,
    CalculationSettings? settings,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CalculationSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, settings, failure];
}

/// The single source of truth for calculation settings while the app runs.
///
/// A singleton so the settings screens and the schedule cannot drift apart:
/// Home listens to this and recomputes, rather than the settings screens
/// having to know who depends on them.
@lazySingleton
class CalculationSettingsCubit extends Cubit<CalculationSettingsState> {
  CalculationSettingsCubit(this._getSettings, this._saveSettings)
    : super(const CalculationSettingsState());

  final GetCalculationSettings _getSettings;
  final SaveCalculationSettings _saveSettings;

  Future<void> load() async {
    emit(state.copyWith(status: CalculationSettingsStatus.loading));

    final result = await _getSettings(const NoParams());

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: CalculationSettingsStatus.failure,
          failure: failure,
        ),
        (settings) => state.copyWith(
          status: CalculationSettingsStatus.success,
          settings: settings,
          clearFailure: true,
        ),
      ),
    );
  }

  /// Applies [settings] immediately, then persists.
  ///
  /// The order matters: the user should see the schedule change the moment
  /// they flip a switch, and a storage failure should not roll the screen
  /// back to a value they did not choose.
  Future<void> update(CalculationSettings settings) async {
    emit(
      state.copyWith(
        status: CalculationSettingsStatus.success,
        settings: settings,
        clearFailure: true,
      ),
    );

    final result = await _saveSettings(settings);
    result.fold((failure) => emit(state.copyWith(failure: failure)), (_) {});
  }
}
