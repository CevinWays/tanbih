import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/adhan_audio/domain/adhan_alarm_port.dart';

/// Talks to the native adhan alarm layer.
///
/// Every method is a no-op off Android: full background playback depends on
/// AlarmManager and a foreground service, neither of which iOS provides.
/// Failing quietly here is deliberate — the notification path still fires,
/// so a missing native layer degrades rather than breaks.
@LazySingleton(as: AdhanAlarmPort)
class AdhanAlarmChannel implements AdhanAlarmPort {
  AdhanAlarmChannel(this._talker);

  final Talker _talker;

  static const MethodChannel _channel = MethodChannel(
    'com.cevin.tanbih/adhan_alarm',
  );

  bool get _supported => Platform.isAndroid;

  @override
  Future<void> replaceAll(List<ScheduledAdhan> alarms) async {
    if (!_supported) return;

    await _invoke('replaceAll', {
      'alarms': [
        for (final alarm in alarms)
          {
            'id': alarm.id,
            'triggerAtMillis': alarm.at.millisecondsSinceEpoch,
            'label': alarm.label,
            'asset': null,
          },
      ],
    });
  }

  @override
  Future<void> cancelAll() => _invoke('cancelAll');

  @override
  Future<bool> canScheduleExact() async {
    if (!_supported) return false;
    final result = await _invoke<bool>('canScheduleExact');
    return result ?? false;
  }

  @override
  Future<void> playNow({required String label, String? body}) =>
      _invoke('playNow', {'label': label, 'body': body});

  @override
  Future<void> stop() => _invoke('stop');

  @override
  Future<void> scheduleTestAlarm({
    required int seconds,
    required String label,
  }) => _invoke('scheduleTestAlarm', {'seconds': seconds, 'label': label});

  Future<T?> _invoke<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    if (!_supported) return null;

    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e, stack) {
      // The notification path is unaffected, so this is logged rather than
      // surfaced: losing the full adhan is a degradation, not a failure.
      _talker.handle(e, stack, 'adhan alarm channel: $method failed');
      return null;
    } on MissingPluginException catch (e, stack) {
      _talker.handle(e, stack, 'adhan alarm channel unavailable');
      return null;
    }
  }
}
