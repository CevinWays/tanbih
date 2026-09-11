package com.cevin.tanbih

import com.cevin.tanbih.alarm.AdhanAlarm
import com.cevin.tanbih.alarm.AdhanAlarmScheduler
import com.cevin.tanbih.audio.AdhanPlaybackService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            val scheduler = AdhanAlarmScheduler(applicationContext)

            when (call.method) {
                "replaceAll" -> {
                    val raw = call.argument<List<Map<String, Any?>>>("alarms")
                        ?: emptyList()
                    scheduler.replaceAll(
                        raw.map { item ->
                            AdhanAlarm(
                                id = (item["id"] as Number).toInt(),
                                triggerAtMillis =
                                    (item["triggerAtMillis"] as Number).toLong(),
                                label = item["label"] as? String ?: "Adhan",
                                asset = item["asset"] as? String,
                            )
                        },
                    )
                    result.success(null)
                }

                "cancelAll" -> {
                    scheduler.cancelAll()
                    result.success(null)
                }

                "canScheduleExact" -> result.success(scheduler.canScheduleExact())

                // Lets the settings screen preview the full adhan through the
                // same path a real prayer uses, rather than a separate player
                // that might behave differently.
                "playNow" -> {
                    AdhanPlaybackService.start(
                        applicationContext,
                        call.argument<String>("label") ?: "Adhan",
                        call.argument<String>("body")
                            ?: getString(R.string.adhan_playing),
                        call.argument<String>("asset"),
                    )
                    result.success(null)
                }

                // Debug-only: arms a real alarm a few seconds out so the
                // full path — AlarmManager, broadcast, foreground service —
                // can be exercised with the app in the background. Waiting
                // for a real prayer time is the only alternative, and this
                // is the path most likely to be broken by an OEM.
                "scheduleTestAlarm" -> {
                    val seconds = call.argument<Int>("seconds") ?: 15
                    scheduler.replaceAll(
                        listOf(
                            AdhanAlarm(
                                id = TEST_ALARM_ID,
                                triggerAtMillis =
                                    System.currentTimeMillis() + seconds * 1000L,
                                label = call.argument<String>("label")
                                    ?: "Adhan",
                                asset = null,
                            ),
                        ),
                    )
                    result.success(null)
                }

                "stop" -> {
                    AdhanPlaybackService.stop(applicationContext)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private companion object {
        const val CHANNEL = "com.cevin.tanbih/adhan_alarm"

        /** Kept clear of the scheduler's derived ids. */
        const val TEST_ALARM_ID = 999999
    }
}
