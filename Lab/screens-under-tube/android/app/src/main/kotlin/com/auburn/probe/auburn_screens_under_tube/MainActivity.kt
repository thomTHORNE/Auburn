package com.auburn.probe.auburn_screens_under_tube

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Sound Design mutes Auburn when the phone is on silent or vibrate; Dart asks for the ringer mode here.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "auburn/ringer").setMethodCallHandler { call, result ->
            if (call.method == "ringerMode") {
                val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                result.success(audio.ringerMode)
            } else {
                result.notImplemented()
            }
        }
    }
}
