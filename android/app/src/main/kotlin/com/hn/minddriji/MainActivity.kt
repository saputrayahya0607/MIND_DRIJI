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

    // 1. PANGGIL PERIZINAN SAAT PERTAMA KALI DIKREASI
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestOverlayPermission()
    }

    // Tangkap data jika aplikasi di background dipaksa naik ke layar (Hot Resume)
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
            // Menggunakan startActivityForResult agar terdokumentasi dengan REQUEST_OVERLAY_CODE
            startActivityForResult(intent, REQUEST_OVERLAY_CODE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Tangkap data jika aplikasi mati total lalu dinyalakan mendadak (Cold Start)
        if (intent?.getBooleanExtra("trigger_popup", false) == true) {
            triggerPopup = true
        }

        // ==========================================
        // HANDLER CHANNEL 1: FITUR BAWAAN
        // ==========================================
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
                            result.success(packageName) // Fallback kembalikan package name jika gagal
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

        // ==========================================
        // HANDLER CHANNEL 2: FITUR BLOKIR & DOOMSCROLLING
        // ==========================================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_INTENT)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkIntentExtra" -> {
                        result.success(triggerPopup)
                        triggerPopup = false
                    }

                    // ── Accessibility ──
                    "isAccessibilityEnabled" -> {
                        result.success(isAccessibilityServiceEnabled())
                    }
                    "openAccessibilitySettings" -> {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    }

                    // ── Overlay ──
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
                        // Mengambil Map berisi data spesifik, contoh: {"com.instagram.android": 900000}
                        val blockedMap = BlockPreferenceManager.getBlockedPackagesMap(this)
                        result.success(blockedMap)
                    }
                    
                    "clearBlock" -> {
                        // Ambil parameter nama package yang dikirim dari Flutter
                        val packageName = call.argument<String>("packageName")
                        
                        if (packageName != null) {
                            // 🔥 HAPUS HANYA UNTUK APLIKASI INI SAJA
                            BlockPreferenceManager.clearBlockForPackage(this, packageName)
                            Log.i("MIND_DRIJI", "Blokir manual dibuka untuk: $packageName")
                        } else {
                            // Jalur aman: Jika dari flutter tidak mengirim nama package, hapus semua
                            BlockPreferenceManager.clearBlock(this)
                            Log.i("MIND_DRIJI", "Semua blokir dihapus secara global")
                        }
                        result.success(true)
                    }

                    "getLiveDoomscrollData" -> {
                        // 💡 SOLUSI: Menambahkan <String, Any> secara eksplisit agar tipe data terdeteksi sempurna
                        val dataData = mapOf<String, Any>(
                            "status" to DoomscrollAccessibilityService.liveStatus,
                            "score" to DoomscrollAccessibilityService.doomscrollScore
                        )
                        
                        // Kirim kembali hasil ke Flutter
                        result.success(dataData)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // Pembaca sensor interaksi layar Android dengan proteksi Crash
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
                if (event.eventType == 15) { // SCREEN_INTERACTIVE
                    screenOnTimestamp = event.timeStamp
                } else if (event.eventType == 16) { // SCREEN_NON_INTERACTIVE
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
            Log.e("MIND_DRIJI", "Izin PACKAGE_USAGE_STATS belum diberikan oleh user: ${e.message}")
            return -1L // Kembalikan -1 sebagai kode di Flutter bahwa izin belum aktif
        } catch (e: Exception) {
            Log.e("MIND_DRIJI", "Gagal mengambil data SOT: ${e.message}")
            return 0L
        }

        return totalScreenOnTime / 1000 / 60
    }

    // Memeriksa status Accessibility Service
    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponentName = ComponentName(this, DoomscrollAccessibilityService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)
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