package com.cevin.tanbih.audio

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.graphics.drawable.Icon
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.cevin.tanbih.MainActivity
import com.cevin.tanbih.R

/**
 * Plays the full adhan when a prayer time arrives.
 *
 * A foreground service rather than a bare MediaPlayer: playback outlives the
 * broadcast that started it, has to survive the app being swapped away, and
 * needs a visible, cancellable presence while it runs. Android would kill a
 * background player within seconds.
 *
 * Deliberately native and free of Flutter: it is started from an
 * AlarmManager broadcast, which can fire long after the Dart isolate is
 * gone. Nothing here needs a plugin registrar.
 */
class AdhanPlaybackService : android.app.Service() {

    private var player: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopPlayback()
                return START_NOT_STICKY
            }
        }

        val label = intent?.getStringExtra(EXTRA_LABEL) ?: "Adhan"
        val body = intent?.getStringExtra(EXTRA_BODY) ?: ""
        val assetPath = intent?.getStringExtra(EXTRA_ASSET)
            ?: DEFAULT_ASSET

        startForegroundWithNotification(label, body)
        play(assetPath)

        // Not sticky: a restarted service would replay the adhan at some
        // arbitrary later moment, which is worse than missing it.
        return START_NOT_STICKY
    }

    private fun startForegroundWithNotification(label: String, body: String) {
        val manager = getSystemService(NotificationManager::class.java)

        if (manager.getNotificationChannel(CHANNEL_ID) == null) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Adhan playback",
                    NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    description = "Shown while the adhan is playing."
                    setSound(null, null)
                },
            )
        }

        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE,
        )

        val stop = PendingIntent.getService(
            this,
            1,
            Intent(this, AdhanPlaybackService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE,
        )

        val stopAction = Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.ic_media_pause),
            getString(R.string.adhan_stop),
            stop,
        ).build()

        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle(label)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(open)
            .setOngoing(true)
            .addAction(stopAction)
            // MediaStyle with the action pinned to the compact view is what
            // makes Stop reachable without expanding the notification. An
            // ongoing notification shows collapsed by default, and on the
            // test device the button was simply unreachable — leaving no way
            // to end two and a half minutes of audio short of force-stopping
            // the app.
            .setStyle(
                Notification.MediaStyle().setShowActionsInCompactView(0),
            )
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun play(assetPath: String) {
        stopPlayer()

        val attributes = AudioAttributes.Builder()
            // USAGE_ALARM keeps the adhan audible under Do Not Disturb's
            // alarms-only filter, which is what the app's own silent mode
            // leaves the phone in.
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        requestAudioFocus(attributes)

        try {
            val afd = assets.openFd(assetPath)
            player = MediaPlayer().apply {
                setAudioAttributes(attributes)
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                setOnCompletionListener { stopPlayback() }
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error what=$what extra=$extra")
                    stopPlayback()
                    true
                }
                prepare()
                start()
            }
            afd.close()
        } catch (e: Exception) {
            // A missing or unreadable asset must not leave a foreground
            // service running with nothing to play.
            Log.e(TAG, "Could not play $assetPath", e)
            stopPlayback()
        }
    }

    private fun requestAudioFocus(attributes: AudioAttributes) {
        audioManager = getSystemService(AudioManager::class.java)
        focusRequest = AudioFocusRequest
            .Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            .setAudioAttributes(attributes)
            .build()
            .also { audioManager?.requestAudioFocus(it) }
    }

    private fun stopPlayer() {
        player?.runCatching {
            if (isPlaying) stop()
            release()
        }
        player = null
    }

    private fun stopPlayback() {
        stopPlayer()
        focusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
        focusRequest = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopPlayer()
        super.onDestroy()
    }

    companion object {
        private const val TAG = "AdhanPlayback"
        private const val CHANNEL_ID = "adhan_playback_v1"
        private const val NOTIFICATION_ID = 9001

        const val ACTION_PLAY = "com.cevin.tanbih.PLAY_ADHAN"
        const val ACTION_STOP = "com.cevin.tanbih.STOP_ADHAN"
        const val EXTRA_LABEL = "label"
        const val EXTRA_BODY = "body"
        const val EXTRA_ASSET = "asset"

        /**
         * Flutter packs assets under this prefix inside the APK, so the
         * same file serves both the Dart preview player and this service —
         * no second copy of a megabyte of audio.
         */
        const val DEFAULT_ASSET = "flutter_assets/assets/audio/adhan_full.ogg"

        fun start(
            context: Context,
            label: String,
            body: String,
            asset: String?,
        ) {
            val intent = Intent(context, AdhanPlaybackService::class.java)
                .setAction(ACTION_PLAY)
                .putExtra(EXTRA_LABEL, label)
                .putExtra(EXTRA_BODY, body)
                .putExtra(EXTRA_ASSET, asset ?: DEFAULT_ASSET)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            context.startService(
                Intent(context, AdhanPlaybackService::class.java)
                    .setAction(ACTION_STOP),
            )
        }
    }
}
