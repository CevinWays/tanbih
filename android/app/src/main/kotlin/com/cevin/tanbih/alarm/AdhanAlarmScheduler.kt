package com.cevin.tanbih.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Places the exact alarms that trigger full adhan playback.
 *
 * Separate from the notification schedule: a notification's channel sound is
 * capped in practice and cannot be stopped once it starts, whereas the adhan
 * runs for over two minutes and needs a stop control. The two are kept in
 * step by the Dart coordinator, which silences the notification whenever
 * full playback is on.
 */
class AdhanAlarmScheduler(private val context: Context) {

    private val alarmManager = context.getSystemService(AlarmManager::class.java)
    private val store = AdhanAlarmStore(context)

    /** Replaces every pending adhan alarm with [alarms]. */
    fun replaceAll(alarms: List<AdhanAlarm>) {
        cancelAll()

        val now = System.currentTimeMillis()
        val future = alarms.filter { it.triggerAtMillis > now }

        future.forEach(::schedule)
        store.save(future)

        Log.i(TAG, "scheduled ${future.size} adhan alarms")
    }

    /** Re-arms what was stored. Used after a reboot or an app update. */
    fun restore() {
        val now = System.currentTimeMillis()
        val remaining = store.load().filter { it.triggerAtMillis > now }
        remaining.forEach(::schedule)
        store.save(remaining)
        Log.i(TAG, "restored ${remaining.size} adhan alarms")
    }

    fun cancelAll() {
        store.load().forEach { alarm ->
            alarmManager.cancel(pendingIntentFor(alarm, mutable = false))
        }
        store.clear()
    }

    fun canScheduleExact(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }

    private fun schedule(alarm: AdhanAlarm) {
        val operation = pendingIntentFor(alarm, mutable = false)

        if (canScheduleExact()) {
            // setAlarmClock, not setExactAndAllowWhileIdle: it is the only
            // tier the OS never defers, it survives Doze, and it tells the
            // system this is a user-visible alarm — which is exactly what a
            // prayer time is.
            alarmManager.setAlarmClock(
                AlarmManager.AlarmClockInfo(
                    alarm.triggerAtMillis,
                    pendingIntentFor(alarm, mutable = false, showIntent = true),
                ),
                operation,
            )
        } else {
            // Without the permission the adhan still fires, just not
            // punctually. Late is bad; silent is worse.
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                alarm.triggerAtMillis,
                operation,
            )
        }
    }

    private fun pendingIntentFor(
        alarm: AdhanAlarm,
        mutable: Boolean,
        showIntent: Boolean = false,
    ): PendingIntent {
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (mutable) PendingIntent.FLAG_MUTABLE else PendingIntent.FLAG_IMMUTABLE

        if (showIntent) {
            return PendingIntent.getActivity(
                context,
                alarm.id,
                context.packageManager
                    .getLaunchIntentForPackage(context.packageName)
                    ?: Intent(),
                flags,
            )
        }

        val intent = Intent(context, AdhanAlarmReceiver::class.java)
            .putExtra(AdhanAlarmReceiver.EXTRA_ID, alarm.id)
            .putExtra(AdhanAlarmReceiver.EXTRA_LABEL, alarm.label)
            .putExtra(AdhanAlarmReceiver.EXTRA_ASSET, alarm.asset)

        return PendingIntent.getBroadcast(context, alarm.id, intent, flags)
    }

    private companion object {
        const val TAG = "AdhanScheduler"
    }
}
