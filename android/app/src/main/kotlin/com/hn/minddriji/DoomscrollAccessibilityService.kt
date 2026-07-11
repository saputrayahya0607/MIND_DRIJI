package com.hn.minddriji

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import android.widget.Button
import android.os.CountDownTimer
import android.widget.TextView
import android.os.Build

class DoomscrollAccessibilityService : AccessibilityService() {

    private var blockOverlayView: View? = null
    private var countdownTimer: CountDownTimer? = null
    private val handler = Handler(Looper.getMainLooper())
    private val commitSwipeRunnable = Runnable { commitOneSwipe() }
    
    // ── AUTOMATED INACTIVITY RESET RUNNABLE ──
    private val inactivityRunnable = Runnable {
        Log.w("MIND_DRIJI", "⏳ Sesi otomatis di-reset karena tidak ada aktivitas swipe selama 5 menit.")
        resetSession()
    }

    // Overlay Doomscrolling (Pilihan Durasi)
    private var overlayView: View? = null
    private var windowManager: WindowManager? = null

    // Scroll state
    private var lastScrollX: Int = Int.MIN_VALUE
    private var lastScrollY: Int = Int.MIN_VALUE  // MIN_VALUE = belum ada data sama sekali
    private var swipeDirection: Int = 0
    private var consecutiveDownCount: Int = 0

    // EMA & session
    private var emaVelocityMs: Double = 0.0
    private var lastSwipeTime: Long = 0L
    private var lastTriggerTime: Long = 0L
    private var swipeCount: Int = 0
    private var currentPackage: String = ""

    companion object {
        private val TARGET_PACKAGES = setOf(
            "com.zhiliaoapp.musically",
            "com.ss.android.ugc.trill",
            "com.instagram.android",
            "com.google.android.youtube",
            "com.snapchat.android"
        )
        var liveStatus: String = "Rendah"
        var doomscrollScore: Int = 0 
        private const val EMA_THRESHOLD_MS       = 600.0
        private const val SESSION_RESET_MS       = 3_000L
        private const val TRIGGER_COOLDOWN_MS    = 30_000L
        private const val EMA_ALPHA              = 0.3
        private const val MIN_SWIPES_FOR_TRIGGER = 6
        private const val FINGER_UP_DEBOUNCE_MS  = 200L
        private const val MIN_SCROLL_DELTA       = 5
        
        // ⏱️ Batas toleransi inaktivitas (5 Menit) sebelum skor kembali bersih
        private const val INACTIVITY_TIMEOUT_MS  = 300_000L
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        Log.i("MIND_DRIJI", "Service aktif | canDrawOverlays=${Settings.canDrawOverlays(this)}")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val pkg = event.packageName?.toString() ?: return

        // ── CEK BLOKIR: jika app yang dibuka sedang diblokir ──
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val currentPackageName = event.packageName?.toString() ?: return

            // 1. JIKA USER MEMBUKA APP MIND DRIJI ATAU KEMBALI KE SYSTEM UI/LAUNCHER, HAPUS SEMUA OVERLAY
            if (currentPackageName == packageName || 
                currentPackageName == "com.android.systemui" || 
                currentPackageName.contains("launcher") || 
                currentPackageName.contains("home")) {
                dismissOverlay()
                dismissBlockOverlay()
                return
            }

            // 2. CEK STATUS BLOKIR INDIVIDUAL BERDASARKAN NAMA PAKETNYA LANGSUNG
            if (BlockPreferenceManager.isBlocked(this, currentPackageName)) {
                currentPackage = currentPackageName // simpan package aktif untuk nama aplikasi
                // 🔥 Memanggil fungsi blokir asli dengan mengirimkan nama paketnya
                showBlockOverlay(currentPackageName) 
            } else {
                // JIKA USER BERHASIL KELUAR ATAU WAKTU HABIS, SEGERA HAPUS OVERLAY AGAR HP TIDAK MACET!
                dismissOverlay()
                dismissBlockOverlay()
            }
        }

        if (pkg !in TARGET_PACKAGES) return
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_SCROLLED) return

        val now = System.currentTimeMillis()
        if (now - lastTriggerTime < TRIGGER_COOLDOWN_MS) return

        // ── Deteksi arah scroll ──
        val scrolledDown = detectScrollDirection(event)

        // Jika null (horizontal / tidak valid), langsung TOLAK dan keluar!
        if (scrolledDown == null) {
            return
        }

        // Scroll ke atas → reset counter arah, jangan commit
        if (scrolledDown == false) {
            Log.v("MIND_DRIJI", "Scroll ke atas → reset")
            consecutiveDownCount = 0
            swipeDirection = -1
            handler.removeCallbacks(commitSwipeRunnable)
            return
        }

        // Ganti app → reset sesi
        if (pkg != currentPackage) {
            Log.d("MIND_DRIJI", "Ganti app: $currentPackage → $pkg")
            resetSession()
            currentPackage = pkg
        }

        swipeDirection = 1

        // Debounce: timer di-reset setiap event datang
        handler.removeCallbacks(commitSwipeRunnable)
        handler.postDelayed(commitSwipeRunnable, FINGER_UP_DEBOUNCE_MS)

        Log.v("MIND_DRIJI", "[$pkg] Scroll aktif (menunggu jari diangkat...)")
    }

    /**
     * Deteksi arah scroll dengan strategi berlapis.
     */
    private fun detectScrollDirection(event: AccessibilityEvent): Boolean? {
        val deltaY = try { event.scrollDeltaY } catch (e: Exception) { Int.MIN_VALUE }
        if (deltaY != Int.MIN_VALUE && deltaY != 0) {
            return deltaY > 0  
        }

        val currentScrollY = event.scrollY
        if (currentScrollY >= 0 && lastScrollY != Int.MIN_VALUE && lastScrollY >= 0) {
            val diff = currentScrollY - lastScrollY
            if (Math.abs(diff) >= MIN_SCROLL_DELTA) {
                lastScrollY = currentScrollY
                return diff > 0
            }
            if (Math.abs(diff) < MIN_SCROLL_DELTA) return null
        }

        if (currentScrollY >= 0) lastScrollY = currentScrollY
        return null  
    }

    /**
     * Dipanggil SEKALI per swipe, tepat setelah jari diangkat.
     */
    private fun commitOneSwipe() {
        val now = System.currentTimeMillis()

        if (lastSwipeTime > 0 && now - lastSwipeTime > SESSION_RESET_MS) {
            Log.d("MIND_DRIJI", "Reset sesi lama: jeda ${now - lastSwipeTime}ms")
            resetSession()
        }

        val intervalMs = if (lastSwipeTime > 0) (now - lastSwipeTime).toDouble() else 0.0

        swipeCount++
        consecutiveDownCount++

        // Update EMA interval antar swipe
        val msVelocity = when {
            lastSwipeTime == 0L -> 0.0
            swipeCount == 1     -> intervalMs
            else                -> EMA_ALPHA * intervalMs + (1 - EMA_ALPHA) * emaVelocityMs
        }
        emaVelocityMs = msVelocity

        lastSwipeTime  = now
        swipeDirection = 0

        // 🔥 Hitung & update doomscrollScore secara real-time di sini
        updateDoomscrollScore()

        Log.d("MIND_DRIJI", buildString {
            append("SWIPE #$swipeCount selesai")
            append(" | interval=${intervalMs.toInt()}ms")
            append(" | EMA=${emaVelocityMs.toInt()}ms")
            append(" | down=$consecutiveDownCount")
            append(" | Skor Saat Ini=$doomscrollScore ($liveStatus)")
        })

        // ── Cek trigger doomscrolling ──
        val cukupSwipe   = swipeCount >= MIN_SWIPES_FOR_TRIGGER
        val terlalucepat = emaVelocityMs in 1.0..EMA_THRESHOLD_MS
        val konsistenBawah = consecutiveDownCount >= 4

        Log.d("MIND_DRIJI", "Cek: cukupSwipe=$cukupSwipe cepatEMA=$terlalucepat konsisten=$konsistenBawah")

        if (cukupSwipe && terlalucepat && konsistenBawah) {
            Log.w("MIND_DRIJI", "🚨 DOOMSCROLLING TERDETEKSI! Menampilkan overlay...")
            lastTriggerTime = now
            
            // 🛑 MODIFIKASI: resetSession() DIHAPUS dari sini agar skor bertengger tinggi 
            // dan sempat dibaca oleh MethodChannel milik Flutter Home dashboard.
            
            showOverlay()
        }

        // 🔄 REFRESH TIMER INAKTIVITAS:
        // Setiap kali sukses mendaftarkan swipe baru, hapus antrean inaktif lama dan jadwalkan ulang ke 5 menit ke depan.
        handler.removeCallbacks(inactivityRunnable)
        handler.postDelayed(inactivityRunnable, INACTIVITY_TIMEOUT_MS)
    }

    /**
     * Fungsi baru kalkulasi scoring dinamis (Skala 0 - 100)
     */
    private fun updateDoomscrollScore() {
        // 1. SKOR KECEPATAN (Bobot: 40%)
        val speedScore = if (emaVelocityMs <= 0.0) 0.0 else {
            val clampedVelocity = emaVelocityMs.coerceIn(300.0, 1500.0)
            ((1500.0 - clampedVelocity) / (1500.0 - 300.0)) * 100.0
        }

        // 2. SKOR VOLUME (Bobot: 40%)
        val maxSwipeCap = 25.0
        val volumeScore = (swipeCount.toDouble() / maxSwipeCap).coerceIn(0.0, 1.0) * 100.0

        // 3. SKOR KONSISTENSI DI REKAMAN KE BAWAH (Bobot: 20%)
        val maxConsecutiveCap = 10.0
        val consistencyScore = (consecutiveDownCount.toDouble() / maxConsecutiveCap).coerceIn(0.0, 1.0) * 100.0

        // 4. TOTAL AKUMULASI BOBOT NILAI
        val finalScore = (speedScore * 0.4) + (volumeScore * 0.4) + (consistencyScore * 0.2)

        // Masukkan hasil kalkulasi ke companion object variable
        doomscrollScore = finalScore.toInt().coerceIn(0, 100)

        // Tentukan label status live
        liveStatus = when {
            doomscrollScore < 35 -> "Rendah"
            doomscrollScore < 75 -> "Sedang"
            else -> "Tinggi"
        }
    }

    // ── Overlay langsung di atas app saat terdeteksi Doomscrolling (Pilihan Menit) ──
    private fun showOverlay() {
        if (overlayView != null) return

        if (!Settings.canDrawOverlays(this)) {
            Log.e("MIND_DRIJI", "canDrawOverlays = FALSE → minta permission")
            requestOverlayPermission()
            return
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_DIM_BEHIND,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity   = Gravity.CENTER
            dimAmount = 0.6f
        }

        val view = LayoutInflater.from(this).inflate(R.layout.overlay_doomscroll, null)

        view.findViewById<Button>(R.id.btn_15m).setOnClickListener {
            dismissOverlay()
            BlockPreferenceManager.startBlock(this, currentPackage, 15 * 60 * 1000L)
        }

        view.findViewById<Button>(R.id.btn_30m).setOnClickListener {
            dismissOverlay()
            BlockPreferenceManager.startBlock(this, currentPackage, 30 * 60 * 1000L)
        }

        view.findViewById<Button>(R.id.btn_1h).setOnClickListener {
            dismissOverlay()
            BlockPreferenceManager.startBlock(this, currentPackage, 60 * 60 * 1000L)
        }

        view.findViewById<Button>(R.id.btn_continue).setOnClickListener {
            dismissOverlay()
        }

        try {
            windowManager?.addView(view, params)
            overlayView = view
            Log.i("MIND_DRIJI", "✅ Overlay Berhasil Tampil")
        } catch (e: Exception) {
            Log.e("MIND_DRIJI", "❌ Gagal tampil overlay: ${e.message}")
        }
    }

    private fun dismissOverlay() {
        overlayView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                Log.e("MIND_DRIJI", "Gagal hapus overlay: ${e.message}")
            }
            overlayView = null
        }
    }

    // ── Overlay TOTAL BLOCKIR DENGAN REAL-TIME TIMER INDIVIDUAL ──
    private fun showBlockOverlay(blockedPkg: String) {
        if (blockOverlayView != null) return
        if (!Settings.canDrawOverlays(this)) return

        val remaining = BlockPreferenceManager.remainingMsForPackage(this, blockedPkg)
        if (remaining <= 0L) return

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,      
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity   = Gravity.CENTER
            dimAmount = 0.85f
        }

        val view = LayoutInflater.from(this).inflate(R.layout.overlay_block_countdown, null)

        startCountdownTimer(view, remaining, blockedPkg)

        view.findViewById<Button>(R.id.btn_open_minddriji).setOnClickListener {
            dismissBlockOverlay()
            openMindDriji(fromBlock = true)
        }

        try {
            windowManager?.addView(view, params)
            blockOverlayView = view
            Log.i("MIND_DRIJI", "Block overlay ditayangkan untuk: $blockedPkg")
        } catch (e: Exception) {
            Log.e("MIND_DRIJI", "Gagal tampil block overlay: ${e.message}")
        }
    }

    private fun startCountdownTimer(view: View, remainingMs: Long, blockedPkg: String) {
        val tvCountdown = view.findViewById<TextView>(R.id.tv_countdown)
        val tvAppName   = view.findViewById<TextView>(R.id.tv_blocked_app)

        tvAppName.text = try {
            val info = packageManager.getApplicationInfo(blockedPkg, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (e: Exception) { "Aplikasi Terkunci" }

        countdownTimer?.cancel()
        countdownTimer = object : CountDownTimer(remainingMs, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                val h  = millisUntilFinished / 3_600_000
                val m  = (millisUntilFinished % 3_600_000) / 60_000
                val s  = (millisUntilFinished % 60_000) / 1_000
                
                tvCountdown.text = if (h > 0) {
                    String.format("%02d:%02d:%02d", h, m, s)
                } else {
                    String.format("%02d:%02d", m, s)
                }
            }
            override fun onFinish() {
                BlockPreferenceManager.clearBlockForPackage(this@DoomscrollAccessibilityService, blockedPkg)
                dismissBlockOverlay()
                Log.i("MIND_DRIJI", "Blokiran aplikasi $blockedPkg selesai otomatis")
            }
        }.start()
    }

    private fun dismissBlockOverlay() {
        countdownTimer?.cancel()
        blockOverlayView?.let {
            try { 
                windowManager?.removeView(it) 
            } catch (e: Exception) { e.printStackTrace() }
            blockOverlayView = null
        }
    }

    private fun openMindDriji(fromBlock: Boolean = false) {
        val intent = Intent().apply {
            setClassName("com.hn.minddriji", "com.hn.minddriji.MainActivity")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("trigger_popup", !fromBlock)
            putExtra("from_block", fromBlock)
        }
        try { 
            startActivity(intent) 
        } catch (e: Exception) {
            Log.e("MIND_DRIJI", "Gagal buka MindDriji: ${e.message}")
        }
    }

    private fun requestOverlayPermission() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            android.net.Uri.parse("package:$packageName")
        ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        try { startActivity(intent) } catch (e: Exception) {
            Log.e("MIND_DRIJI", "Gagal buka settings overlay: ${e.message}")
        }
    }

    private fun resetSession() {
        handler.removeCallbacks(commitSwipeRunnable)
        handler.removeCallbacks(inactivityRunnable) // Amankan antrean agar tidak tumpang tindih
        emaVelocityMs        = 0.0
        lastSwipeTime        = 0L
        swipeCount           = 0
        lastScrollY          = Int.MIN_VALUE
        swipeDirection       = 0
        consecutiveDownCount = 0
        
        // 🔥 Reset skor dan status kembali ke awal saat sesi berakhir (Inaktif tercapai)
        doomscrollScore      = 0
        liveStatus           = "Rendah"
    }

    override fun onInterrupt() = resetSession()

    override fun onDestroy() {
        super.onDestroy()
        dismissOverlay()
        dismissBlockOverlay()
        handler.removeCallbacksAndMessages(null)
    }
}