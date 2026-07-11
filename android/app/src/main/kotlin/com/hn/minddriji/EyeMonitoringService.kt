package com.hn.minddriji

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.YuvImage
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarker
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import com.google.mediapipe.framework.image.BitmapImageBuilder
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.sqrt

class EyeMonitoringService : Service() {

    companion object {
        var channelIntent: MethodChannel? = null
        var isServiceRunning = false
    }

    private lateinit var cameraExecutor: ExecutorService
    private var faceLandmarker: FaceLandmarker? = null
    private var isAnalyzingFrame = false 
    private var cameraProvider: ProcessCameraProvider? = null

    // ⏱️ Variabel Interval Kontrol Batch Processing
    private var lastScanTime = 0L
    private val SCAN_INTERVAL_MS = 30000L 
    private val FRAMES_PER_BATCH = 5      
    private var currentBatchFrameCount = 0
    private var lelahCountInBatch = 0
    private var isScanningBatch = false

    private val NOTIFICATION_ID = 8888
    private val CHANNEL_ID = "eye_monitoring_channel"

    override fun onCreate() {
        super.onCreate()
        cameraExecutor = Executors.newSingleThreadExecutor()
        initMediaPipe()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!isServiceRunning) {
            isServiceRunning = true
            startForegroundNotification()
            captureAndAnalyzeEye()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        try {
            cameraProvider?.unbindAll()
        } catch (e: Exception) {
            Log.e("MIND_DRIJI_SERVICE", "Error cleanup service: ${e.message}")
        }
        faceLandmarker?.close()
        cameraExecutor.shutdown()
        Log.d("MIND_DRIJI_SERVICE", "🛑 Service Pemantau Mata Dimatikan Total.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startForegroundNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "MIND DRIJI Eye Monitoring",
                NotificationManager.IMPORTANCE_LOW
            )
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MIND DRIJI Pelindung Mata Aktif")
            .setContentText("AI sedang menjaga matamu dari kelelahan...")
            .setSmallIcon(android.R.drawable.ic_menu_camera) 
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true) // Menjaga agar notifikasi tidak bisa di-swipe hapus oleh user
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun initMediaPipe() {
        try {
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("face_landmarker.task")
                .build()

            val options = FaceLandmarker.FaceLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setMinFaceDetectionConfidence(0.5f)
                .setRunningMode(RunningMode.IMAGE)
                .build()

            faceLandmarker = FaceLandmarker.createFromOptions(this, options)
            Log.i("MIND_DRIJI_SERVICE", "MediaPipe Face Landmarker Berhasil di-load di Background Service!")
        } catch (e: Exception) {
            Log.e("MIND_DRIJI_SERVICE", "Gagal inisialisasi MediaPipe di Service: ${e.message}")
        }
    }

    private fun captureAndAnalyzeEye() {
        val handler = android.os.Handler(android.os.Looper.getMainLooper())
        handler.post {
            val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
            cameraProviderFuture.addListener({
                cameraProvider = cameraProviderFuture.get()

                // Mengonfigurasi analisis gambar (tanpa butuh surface visual preview)
                val imageAnalysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
                    .build()

                val customLifecycleOwner = SimpleLifecycleOwner()

                imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
                    val currentTime = System.currentTimeMillis()

                    if (!isScanningBatch && (currentTime - lastScanTime < SCAN_INTERVAL_MS)) {
                        imageProxy.close()
                        return@setAnalyzer
                    }

                    if (!isScanningBatch) {
                        isScanningBatch = true
                        currentBatchFrameCount = 0
                        lelahCountInBatch = 0
                        
                        handler.post {
                            channelIntent?.invokeMethod("onEyeStatusUpdate", "Memindai...")
                        }
                    }

                    if (isAnalyzingFrame) {
                        imageProxy.close()
                        return@setAnalyzer
                    }

                    isAnalyzingFrame = true 
                    
                    try {
                        val bitmap = imageProxy.toBitmap()

                        if (bitmap != null) {
                            val rotationDegrees = imageProxy.imageInfo.rotationDegrees
                            val rotatedBitmap = rotateBitmapIfNeeded(bitmap, rotationDegrees)

                            val mpImage = BitmapImageBuilder(rotatedBitmap).build()
                            val result = faceLandmarker?.detect(mpImage)

                            if (result != null && result.faceLandmarks().isNotEmpty()) {
                                val landmarks = result.faceLandmarks()[0]

                                val indeksMataKanan = intArrayOf(33, 160, 158, 133, 153, 144)
                                val indeksMataKiri = intArrayOf(263, 385, 386, 362, 374, 380)

                                val earKanan = hitungSingleEAR(landmarks, indeksMataKanan)
                                val earKiri = hitungSingleEAR(landmarks, indeksMataKiri)
                                val rataRataEAR = (earKanan + earKiri) / 2.0f

                                Log.d("MIND_DRIJI_EAR", "[Invisible Service Batch #${currentBatchFrameCount + 1}] EAR: $rataRataEAR")

                                if (rataRataEAR < 0.17f) {
                                    lelahCountInBatch++
                                }
                                currentBatchFrameCount++

                            } else {
                                currentBatchFrameCount++
                            }

                            if (bitmap != rotatedBitmap) bitmap.recycle()
                            rotatedBitmap.recycle()
                        }
                    } catch (e: Exception) {
                        Log.e("MIND_DRIJI_CAM", "Error stream di Service: ${e.message}")
                    } finally {
                        imageProxy.close()
                        isAnalyzingFrame = false 
                    }

                    if (currentBatchFrameCount >= FRAMES_PER_BATCH) {
                        val statusAkhirBatch = if (lelahCountInBatch >= 3) "Lelah" else "Normal"

                        Log.d("MIND_DRIJI_BATCH", "=== Hasil Evaluasi Latar Belakang Senyap: $statusAkhirBatch ===")

                        handler.post { 
                            channelIntent?.invokeMethod("onEyeStatusUpdate", statusAkhirBatch)
                        }

                        isScanningBatch = false
                        lastScanTime = System.currentTimeMillis()
                    }
                }

                try {
                    cameraProvider?.unbindAll()

                    // 🟢 KUNCI UTAMA: Hanya bind imageAnalysis saja ke Lifecycle. 
                    // Tidak ada 'preview' ataupun 'setSurfaceProvider' lagi di sini.
                    cameraProvider?.bindToLifecycle(
                        customLifecycleOwner,
                        CameraSelector.DEFAULT_FRONT_CAMERA,
                        imageAnalysis
                    )
                    Log.d("MIND_DRIJI_SERVICE", "📷 Kamera depan berhasil berjalan senyap di latar belakang!")
                } catch (e: Exception) {
                    Log.e("MIND_DRIJI_SERVICE", "Gagal binding Kamera di Service: ${e.message}")
                }
            }, ContextCompat.getMainExecutor(this))
        }
    }

    // ── HELPERS CONVERSIONS FOR SERVICE ──

    private fun ImageProxy.toBitmap(): Bitmap? {
        val nv21 = yuv420ToNv21(this)
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(android.graphics.Rect(0, 0, width, height), 100, out)
        return BitmapFactory.decodeByteArray(out.toByteArray(), 0, out.size())
    }

    private fun yuv420ToNv21(image: ImageProxy): ByteArray {
        val yBuffer = image.planes[0].buffer
        val uBuffer = image.planes[1].buffer
        val vBuffer = image.planes[2].buffer
        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()
        val nv21 = ByteArray(ySize + uSize + vSize)
        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)
        return nv21
    }

    private fun rotateBitmapIfNeeded(bitmap: Bitmap, degrees: Int): Bitmap {
        if (degrees == 0) return bitmap
        val matrix = Matrix()
        matrix.postRotate(degrees.toFloat())
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    private fun hitungJarak(p1: NormalizedLandmark, p2: NormalizedLandmark): Float {
        val dx = p1.x() - p2.x() 
        val dy = p1.y() - p2.y() 
        return sqrt((dx * dx + dy * dy).toDouble()).toFloat()
    }

    private fun hitungSingleEAR(landmarks: List<NormalizedLandmark>, indeksMata: IntArray): Float {
        val p1 = landmarks[indeksMata[0]] 
        val p2 = landmarks[indeksMata[1]] 
        val p3 = landmarks[indeksMata[2]] 
        val p4 = landmarks[indeksMata[3]] 
        val p5 = landmarks[indeksMata[4]] 
        val p6 = landmarks[indeksMata[5]] 
        val jarakVertikal1 = hitungJarak(p2, p6)
        val jarakVertikal2 = hitungJarak(p3, p5)
        val jarakHorizontal = hitungJarak(p1, p4)
        return (jarakVertikal1 + jarakVertikal2) / (2.0f * jarakHorizontal)
    }

    private class SimpleLifecycleOwner : LifecycleOwner {
        private val lifecycleRegistry = LifecycleRegistry(this)
        init { lifecycleRegistry.currentState = Lifecycle.State.RESUMED }
        override val lifecycle: Lifecycle get() = lifecycleRegistry
    }
}