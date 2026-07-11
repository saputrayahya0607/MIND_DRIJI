package com.hn.minddriji

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import android.util.Log

class MainActivity : FlutterActivity() {

    companion object {
        private const val REQUEST_OVERLAY_CODE = 1234
    }

    private val CHANNEL_APPS = "minddriji/apps"
    private val CHANNEL_INTENT = "minddriji/intent"
    private var triggerPopup = false
    private var channelIntent: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestOverlayPermission()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("trigger_popup", false)) {
            triggerPopup = true
        }
    }

    private fun requestOverlayPermission() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, REQUEST_OVERLAY_CODE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (intent?.getBooleanExtra("trigger_popup", false) == true) {
            triggerPopup = true
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_APPS)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAppName" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName.isNullOrEmpty()) {
                            result.error("BAD_ARGUMENT", "Package name is null or empty", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val pm = applicationContext.packageManager
                            val appInfo = pm.getApplicationInfo(packageName, 0)
                            val appName = pm.getApplicationLabel(appInfo).toString()
                            result.success(appName)
                        } catch (e: Exception) {
                            result.success(packageName)
                        }
                    }
                    "getScreenOnTime" -> {
                        val startTime = call.argument<Long>("startTime") ?: 0L
                        val endTime = call.argument<Long>("endTime") ?: 0L
                        val sotMinutes = getScreenOnTime(applicationContext, startTime, endTime)
                        result.success(sotMinutes)
                    }
                    else -> result.notImplemented()
                }
            }

        channelIntent = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_INTENT)
        channelIntent?.setMethodCallHandler { call, result ->
                when (call.method) {
                    // 🟢 SEKARANG MENYALAKAN BACKGROUND SERVICE RESMI
                    "startEyeCapture" -> {
                        if (EyeMonitoringService.isServiceRunning) {
                            result.success("Kamera Sudah Berjalan di Background")
                            return@setMethodCallHandler
                        }
                        
                        EyeMonitoringService.channelIntent = channelIntent
                        val serviceIntent = Intent(this@MainActivity, EyeMonitoringService::class.java)
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent)
                        } else {
                            startService(serviceIntent)
                        }
                        
                        result.success("Streaming_Background_Started") 
                    }

                    // 🟢 KONTROL TAMBAHAN: Agar Flutter bisa mematikan kamera saat saklar di-off
                    "stopEyeCapture" -> {
                        val serviceIntent = Intent(this@MainActivity, EyeMonitoringService::class.java)
                        stopService(serviceIntent)
                        result.success("Streaming_Background_Stopped")
                    }

                    "checkIntentExtra" -> {
                        result.success(triggerPopup)
                        triggerPopup = false
                    }

                    "isAccessibilityEnabled" -> {
                        result.success(isAccessibilityServiceEnabled())
                    }
                    "openAccessibilitySettings" -> {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    }

                    "checkOverlayPermission" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "openOverlaySettings" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    }

                    "getBlockStatus" -> {
                        val blockedMap = BlockPreferenceManager.getBlockedPackagesMap(this)
                        result.success(blockedMap)
                    }
                    
                    "clearBlock" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            BlockPreferenceManager.clearBlockForPackage(this, packageName)
                            Log.i("MIND_DRIJI", "Blokir manual dibuka untuk: $packageName")
                        } else {
                            BlockPreferenceManager.clearBlock(this)
                            Log.i("MIND_DRIJI", "Semua blokir dihapus secara global")
                        }
                        result.success(true)
                    }

                    "getLiveDoomscrollData" -> {
                        val dataData = mapOf<String, Any>(
                            "status" to DoomscrollAccessibilityService.liveStatus,
                            "score" to DoomscrollAccessibilityService.doomscrollScore
                        )
                        result.success(dataData)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun getScreenOnTime(context: Context, startTime: Long, endTime: Long): Long {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return 0L
        var totalScreenOnTime = 0L
        var screenOnTimestamp = 0L
        try {
            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val events = usageStatsManager.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()

            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType == 15) { 
                    screenOnTimestamp = event.timeStamp
                } else if (event.eventType == 16) { 
                    if (screenOnTimestamp != 0L) {
                        totalScreenOnTime += (event.timeStamp - screenOnTimestamp)
                        screenOnTimestamp = 0L
                    }
                }
            }
            if (screenOnTimestamp != 0L && endTime > screenOnTimestamp) {
                totalScreenOnTime += (endTime - screenOnTimestamp)
            }
        } catch (e: SecurityException) {
            return -1L 
        } catch (e: Exception) {
            return 0L
        }
        return totalScreenOnTime / 1000 / 60
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponentName = ComponentName(this, DoomscrollAccessibilityService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        val colonSplitterString: String = enabledServicesSetting
        colonSplitter.setString(colonSplitterString)
        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = ComponentName.unflattenFromString(componentNameString)
            if (enabledService != null && enabledService == expectedComponentName) {
                return true
            }
        }
        return false
    }
}