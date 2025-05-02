package com.example.autofarmer

import io.flutter.app.FlutterApplication
import android.os.Build

class MyApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        
        // Install log filter
        LogFilter.install()
        
        // Additional OpenGL configurations for emulators
        if (Build.FINGERPRINT.contains("generic")) {
            // Set properties for emulator
            System.setProperty("debug.hwui.renderer", "skiagl")
            System.setProperty("debug.egl.hw", "1")
        }
    }
} 