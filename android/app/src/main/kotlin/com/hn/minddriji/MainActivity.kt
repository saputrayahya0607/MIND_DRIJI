package com.hn.minddriji

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "minddriji/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            // 1. FITUR BAWAAN KAMU (Ambil Nama Aplikasi)
            if (call.method == "getAppName") {
                val packageName = call.argument<String>("packageName")
                try {
                    val pm = applicationContext.packageManager
                    val appInfo = pm.getApplicationInfo(packageName!!, 0)
                    val appName = pm.getApplicationLabel(appInfo).toString()
                    result.success(appName)
                } catch (e: Exception) {
                    result.success(packageName)
                }
            } 
            
            // 2. FITUR BARU (Hitung Screen-On Time Murni dari Hardware)
            else if (call.method == "getScreenOnTime") {
                val startTime = call.argument<Long>("startTime") ?: 0L
                val endTime = call.argument<Long>("endTime") ?: 0L
                val sotMinutes = getScreenOnTime(applicationContext, startTime, endTime)
                result.success(sotMinutes)
            } 
            
            else {
                result.notImplemented()
            }
        }
    }

    // Fungsi sakti pembaca sensor interaksi layar Android
    private fun getScreenOnTime(context: Context, startTime: Long, endTime: Long): Long {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return 0L // Butuh minimal Android 8 Oreo
        
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(startTime, endTime)
        
        var totalScreenOnTime = 0L
        var screenOnTimestamp = 0L
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            // Event 15 = Layar Menyala (SCREEN_INTERACTIVE)
            if (event.eventType == 15) { 
                screenOnTimestamp = event.timeStamp
            } 
            // Event 16 = Layar Mati / Terkunci (SCREEN_NON_INTERACTIVE)
            else if (event.eventType == 16) { 
                if (screenOnTimestamp != 0L) {
                    totalScreenOnTime += (event.timeStamp - screenOnTimestamp)
                    screenOnTimestamp = 0L
                }
            }
        }
        
        // Antisipasi jika user sedang aktif membuka HP saat query berjalan
        if (screenOnTimestamp != 0L && endTime > screenOnTimestamp) {
            totalScreenOnTime += (endTime - screenOnTimestamp)
        }

        return totalScreenOnTime / 1000 / 60 // Konversi milidetik ke MENIT
    }
}