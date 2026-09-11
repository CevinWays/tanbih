package com.cevin.tanbih.alarm

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * One scheduled adhan.
 */
data class AdhanAlarm(
    val id: Int,
    val triggerAtMillis: Long,
    val label: String,
    val asset: String?,
)

/**
 * Remembers what was scheduled, in native storage.
 *
 * A reboot clears every AlarmManager alarm, and the broadcast that tells us
 * about it arrives with no Dart isolate running. The schedule therefore has
 * to be readable from native code alone — reading it back through Flutter
 * would mean starting the engine on boot, which the OS may not allow and the
 * user has not asked for.
 */
class AdhanAlarmStore(context: Context) {

    private val prefs =
        context.getSharedPreferences("tanbih.adhan_alarms", Context.MODE_PRIVATE)

    fun save(alarms: List<AdhanAlarm>) {
        val array = JSONArray()
        alarms.forEach { alarm ->
            array.put(
                JSONObject().apply {
                    put(KEY_ID, alarm.id)
                    put(KEY_AT, alarm.triggerAtMillis)
                    put(KEY_LABEL, alarm.label)
                    put(KEY_ASSET, alarm.asset)
                },
            )
        }
        prefs.edit().putString(KEY_ALARMS, array.toString()).apply()
    }

    fun load(): List<AdhanAlarm> {
        val raw = prefs.getString(KEY_ALARMS, null) ?: return emptyList()
        return try {
            val array = JSONArray(raw)
            (0 until array.length()).mapNotNull { index ->
                val item = array.optJSONObject(index) ?: return@mapNotNull null
                AdhanAlarm(
                    id = item.optInt(KEY_ID),
                    triggerAtMillis = item.optLong(KEY_AT),
                    label = item.optString(KEY_LABEL),
                    asset = item.optString(KEY_ASSET).ifEmpty { null },
                )
            }
        } catch (e: Exception) {
            // A corrupt store is recoverable: the app rebuilds the window
            // the next time it runs.
            emptyList()
        }
    }

    fun clear() = prefs.edit().remove(KEY_ALARMS).apply()

    private companion object {
        const val KEY_ALARMS = "alarms"
        const val KEY_ID = "id"
        const val KEY_AT = "at"
        const val KEY_LABEL = "label"
        const val KEY_ASSET = "asset"
    }
}
