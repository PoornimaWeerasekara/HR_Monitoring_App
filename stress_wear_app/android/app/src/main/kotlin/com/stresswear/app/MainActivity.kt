package com.stresswear.app

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity – Flutter host activity with a Platform Channel for heart-rate
 * sensor access on Wear OS / Galaxy Watch 5 Pro.
 *
 * Channel name: com.stresswear.app/heart_rate
 *
 * Stage 1 – dummy values
 * ----------------------
 * [getHeartRateSamples] immediately returns a fixed list.
 *
 * Stage 2 – real sensor
 * ----------------------
 * Replace the dummy implementation with the [_startRealSensorCollection]
 * block (uncommented below).  The sensor listener collects [TARGET_SAMPLES]
 * readings and returns them when done.
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.stresswear.app/heart_rate"
        private const val TARGET_SAMPLES = 3
    }

    // ── Stage 2: Real sensor fields ──────────────────────────────────────────
    private var sensorManager: SensorManager? = null
    private var heartRateSensor: Sensor? = null
    private val samples = mutableListOf<Double>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getHeartRateSamples" -> getHeartRateSamples(result)
                    "openInbuiltMonitor" -> {
                        val intent = android.content.Intent("com.samsung.android.app.shealth.action.MEASURE_HEART_RATE")
                        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                        try {
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INTENT_ERROR", "Could not open system HR app", e.message)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ── Stage 2: Real sensor (Platform Channel) ──────────────────────────────
    private fun getHeartRateSamples(result: MethodChannel.Result) {
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        heartRateSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_HEART_RATE)
        samples.clear()

        if (heartRateSensor == null) {
            result.error("NO_SENSOR", "Heart rate sensor not available", null)
            return
        }

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (event.sensor.type == Sensor.TYPE_HEART_RATE) {
                    val hr = event.values[0].toDouble()
                    println("[DEBUG] HR Sample received: $hr")
                    if (hr > 0) {
                        samples.add(hr)
                        println("[DEBUG] Sample added. Current count: ${samples.size}")
                    }
                }
                if (samples.size >= TARGET_SAMPLES) {
                    println("[DEBUG] Target samples reached. Unregistering listener.")
                    sensorManager?.unregisterListener(this)
                    result.success(samples.toList())
                }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                println("[DEBUG] Sensor accuracy changed: $accuracy")
            }
        }

        println("[DEBUG] Registering heart rate sensor listener...")
        val registered = sensorManager?.registerListener(
            listener,
            heartRateSensor,
            SensorManager.SENSOR_DELAY_NORMAL,
        )
        println("[DEBUG] Listener registered: $registered")
    }
}
