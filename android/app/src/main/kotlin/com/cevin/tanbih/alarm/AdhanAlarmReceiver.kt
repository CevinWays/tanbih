package com.cevin.tanbih.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.cevin.tanbih.R
import com.cevin.tanbih.audio.AdhanPlaybackService

/**
 * Turns a fired alarm into adhan playback.
 *
 * Starting a foreground service from the background is normally blocked, but
 * an exact alarm grants a short allowlist window precisely so the app it woke
 * can start one. That is why this hands straight over rather than doing work
 * here.
 */
class AdhanAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val label = intent.getStringExtra(EXTRA_LABEL) ?: "Adhan"
        val asset = intent.getStringExtra(EXTRA_ASSET)

        AdhanPlaybackService.start(
            context,
            label,
            context.getString(R.string.adhan_playing),
            asset,
        )
    }

    companion object {
        const val EXTRA_ID = "id"
        const val EXTRA_LABEL = "label"
        const val EXTRA_ASSET = "asset"
    }
}
