import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/bloc/location_state.dart';
import '../../../notification/presentation/bloc/notification_settings_cubit.dart';
import '../../../settings/data/datasources/app_preferences_local_data_source.dart';

/// Asks for the two permissions the app cannot work without.
///
/// Location is requested by the location flow on startup. Notifications were
/// previously only asked for from a settings screen, which meant a first-run
/// user got a working schedule and silent reminders — the feature they
/// installed the app for, failing quietly.
///
/// The two are deliberately sequenced rather than fired together: stacking
/// system dialogs makes people dismiss whichever is on top without reading
/// it. This waits until the location flow has settled, explains why the
/// notification permission is needed, and only then hands over to the system
/// prompt.
class StartupPermissionGate extends StatefulWidget {
  const StartupPermissionGate({
    required this.preferences,
    required this.child,
    super.key,
  });

  final AppPreferencesLocalDataSource preferences;
  final Widget child;

  @override
  State<StartupPermissionGate> createState() => _StartupPermissionGateState();
}

class _StartupPermissionGateState extends State<StartupPermissionGate> {
  bool _handled = false;

  Future<void> _maybeAsk() async {
    if (_handled) return;

    final notifications = context.read<NotificationSettingsCubit>();

    // Nothing to do when it is already granted, and nothing to do twice:
    // Android stops showing its dialog after repeated refusals, so a nag on
    // every launch is how an app loses the permission permanently.
    if (notifications.state.hasPermission) return;
    if (widget.preferences.getNotificationPromptShown()) return;

    _handled = true;
    await widget.preferences.setNotificationPromptShown(true);

    if (!mounted) return;
    final accepted = await _showRationale();
    if (!accepted) return;

    await notifications.requestPermission();
  }

  Future<bool> _showRationale() async {
    final l10n = context.l10n;

    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.brandSolid,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.permissionIntroTitle,
                    style: AppTextStyle.h3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.permissionIntroBody, style: AppTextStyle.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(l10n.commonNotNow),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.commonAllow),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      // Settled either way: a refused location still leaves reminders worth
      // enabling, so the notification prompt is not held hostage to it.
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status != LocationStatus.resolving &&
          current.status != LocationStatus.initial,
      listener: (_, _) => _maybeAsk(),
      child: widget.child,
    );
  }
}
