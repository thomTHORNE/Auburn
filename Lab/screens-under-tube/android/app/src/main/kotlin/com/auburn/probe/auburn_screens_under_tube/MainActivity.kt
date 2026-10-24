package com.auburn.probe.auburn_screens_under_tube

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs

class MainActivity : FlutterActivity() {
    // The refresh rate asked of the display; 0 leaves it to the system.
    private var wantedRefresh = 75f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applyRefresh()
    }

    // Asks for the display mode closest to the wanted rate. The system may still pick another.
    private fun applyRefresh() {
        val attrs = window.attributes
        if (wantedRefresh <= 0f) {
            attrs.preferredDisplayModeId = 0
            attrs.preferredRefreshRate = 0f
        } else {
            val modes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display?.supportedModes else windowManager.defaultDisplay.supportedModes
            val best = modes?.minByOrNull { abs(it.refreshRate - wantedRefresh) }
            attrs.preferredDisplayModeId = best?.modeId ?: 0
            attrs.preferredRefreshRate = wantedRefresh
        }
        window.attributes = attrs
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Sound Design mutes Auburn when the phone is on silent or vibrate; Dart asks for the ringer mode here.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "auburn/ringer").setMethodCallHandler { call, result ->
            if (call.method == "ringerMode") {
                val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                result.success(audio.ringerMode)
            } else {
                result.notImplemented()
            }
        }
        // The tube's frame-rate probe: the display's refresh rate and modes, and the battery temperature.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "auburn/perf").setMethodCallHandler { call, result ->
            when (call.method) {
                "setRefresh" -> {
                    wantedRefresh = (call.arguments as Number).toFloat()
                    applyRefresh()
                    result.success(null)
                }
                "status" -> {
                    @Suppress("DEPRECATION")
                    val d = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else windowManager.defaultDisplay
                    val battery = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                    val tenths = battery?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE) ?: Int.MIN_VALUE
                    result.success(mapOf(
                        "refresh" to (d?.refreshRate ?: 0f).toDouble(),
                        "modes" to (d?.supportedModes?.map { it.refreshRate.toDouble() }?.distinct()?.sorted() ?: listOf<Double>()),
                        "battery" to if (tenths == Int.MIN_VALUE) null else tenths / 10.0,
                    ))
                }
                else -> result.notImplemented()
            }
        }
    }
}
