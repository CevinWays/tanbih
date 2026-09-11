package com.cevin.tanbih.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Re-arms adhan alarms after a reboot or an app update.
 *
 * Android drops every pending alarm across a restart. Without this the adhan
 * goes quiet until the user happens to open the app again — a failure with
 * no symptom, on a device that may not be opened for days.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            -> AdhanAlarmScheduler(context).restore()
        }
    }
}
