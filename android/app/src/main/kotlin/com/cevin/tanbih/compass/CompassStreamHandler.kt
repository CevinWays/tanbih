package com.cevin.tanbih.compass

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

/**
 * Streams the device heading, corrected to **true** north.
 *
 * Written natively rather than taken from a plugin for one reason that
 * matters to correctness: the qibla bearing is computed from true north,
 * while a raw compass reports magnetic north. The difference is the local
 * magnetic declination, and ignoring it points the user slightly wrong —
 * silently, and worse the further from the equator they are.
 * [GeomagneticField] gives that correction from position and date.
 *
 * It also reports sensor accuracy and whether the hardware exists at all,
 * so the UI can ask for a calibration figure-eight or fall back to a plain
 * numeric bearing on a phone with no magnetometer.
 */
class CompassStreamHandler(private val context: Context) :
    EventChannel.StreamHandler, SensorEventListener {

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    private var events: EventChannel.EventSink? = null
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0

    private val rotationMatrix = FloatArray(9)
    private val orientation = FloatArray(3)

    /** Last emitted heading, for smoothing out sensor jitter. */
    private var smoothed: Double? = null

    private var accuracy: Int = SensorManager.SENSOR_STATUS_UNRELIABLE

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events

        (arguments as? Map<*, *>)?.let { args ->
            latitude = (args["latitude"] as? Number)?.toDouble() ?: 0.0
            longitude = (args["longitude"] as? Number)?.toDouble() ?: 0.0
        }

        val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)

        if (sensor == null) {
            // No magnetometer: say so once and stop. The UI then shows the
            // bearing as a number instead of a dial that would never move.
            events?.success(
                mapOf("hasSensor" to false, "heading" to null, "accuracy" to -1),
            )
            return
        }

        sensorManager.registerListener(
            this,
            sensor,
            SensorManager.SENSOR_DELAY_UI,
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        events = null
        smoothed = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_ROTATION_VECTOR) return

        SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
        SensorManager.getOrientation(rotationMatrix, orientation)

        val magneticHeading = Math.toDegrees(orientation[0].toDouble())
        val trueHeading = normalize(magneticHeading + declination())

        // A low-pass filter over the shortest angular path: without it the
        // needle jitters by several degrees and reads as broken.
        val previous = smoothed
        smoothed = if (previous == null) {
            trueHeading
        } else {
            normalize(previous + shortestDelta(previous, trueHeading) * SMOOTHING)
        }

        events?.success(
            mapOf(
                "hasSensor" to true,
                "heading" to smoothed,
                "accuracy" to accuracy,
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        this.accuracy = accuracy
    }

    /** Local magnetic declination in degrees, east positive. */
    private fun declination(): Double =
        GeomagneticField(
            latitude.toFloat(),
            longitude.toFloat(),
            0f,
            System.currentTimeMillis(),
        ).declination.toDouble()

    private fun normalize(degrees: Double): Double = (degrees % 360 + 360) % 360

    /** Signed difference in [-180, 180], so smoothing never takes the long way round 0. */
    private fun shortestDelta(from: Double, to: Double): Double {
        val diff = (to - from + 540) % 360 - 180
        return diff
    }

    private companion object {
        const val SMOOTHING = 0.25
        const val CHANNEL = "com.cevin.tanbih/compass"
    }
}
