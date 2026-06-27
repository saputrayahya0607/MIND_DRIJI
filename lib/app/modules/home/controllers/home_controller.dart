import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:async';

// 🟡 PASTIKAN: Sesuaikan path import ini dengan nama package dan folder proyekmu
// import 'package:nama_project_kamu/app/modules/monitoring/controllers/monitoring_controller.dart';
import 'package:mind_driji/app/modules/monitoring/controllers/monitoring_controller.dart'; 

class HomeController extends GetxController with WidgetsBindingObserver {

  // Method channel ke native Kotlin untuk cek permission & ambil data live
  static const _platformChannel = MethodChannel('minddriji/intent');

  // =========================
  // DATA USER
  // =========================

  static Map<String, dynamic>? dataUserLogin;
  var namaUser = 'Saputra'.obs;

  // =========================
  // HEALTH SCORE & DIMENSI DATA
  // =========================

  var healthScore = 72.obs; // Variabel utama yang menampung rumus gabungan AI
  var screenTime = '0j 0m'.obs; // Diubah defaultnya ke 0j 0m karena nanti live dari MonitoringController
  var doomscrollStatus = 'Rendah'.obs; 
  var eyeCondition = 'Lelah'.obs;

  // Skor mentah (0-100) tiap dimensi untuk kebutuhan kalkulasi rumus berbobot
  var screenTimeScore = 100.obs;     // Dimulai dari angka aman (100)
  var doomscrollScore = 95.obs;      // Nilai dasar doomscrolling (dimulai dari aman: 95)
  var eyeMonitoringScore = 65.obs;   // Nilai dasar monitoring mata

  // =========================
  // MONITORING AKTIVITAS
  // =========================

  var hasUsagePermission = false.obs;
  var statusActivityLooping = "Ketuk untuk memberikan izin akses".obs;

  // =========================
  // PERMISSION: OVERLAY & ACCESSIBILITY
  // =========================

  var hasOverlayPermission     = false.obs;
  var hasAccessibilityPermission = false.obs;

  // Status label untuk ditampilkan di UI
  var statusOverlay       = "Belum diizinkan".obs;
  var statusAccessibility = "Belum diaktifkan".obs;

  // =========================
  // NOTIFIKASI CERDAS
  // =========================

  var isSmartNotifActive = false.obs;
  var statusSmartNotif   = "Menunggu diaktifkan".obs;

  // =========================
  // HEALTH INSIGHT
  // =========================

  var isHealthInsightActive = true.obs;

  // =========================
  // EYE MONITORING & INTERACTION
  // =========================

  var isEyeMonitorActive = false.obs;
  var statusLooping = "Menunggu diaktifkan".obs;
  var lastInteractionTime = DateTime.now().obs; 

  // =========================
  // DOOMSCROLLING LIVE POLLING (KOTLIN INTEGRATION)
  // =========================

  Timer? _liveDataPollingTimer; 

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    if (dataUserLogin != null && dataUserLogin!['nama_lengkap'] != null) {
      namaUser.value = dataUserLogin!['nama_lengkap'];
    } else if (Get.arguments != null && Get.arguments['nama_lengkap'] != null) {
      namaUser.value = Get.arguments['nama_lengkap'];
    }

    checkUsagePermission();
    checkAllPermissions(); 
    
    // 🟡 TASK 3.1: Aktifkan mesin pengetuk pintu Kotlin (Polling 3 detik sekali)
    _startLiveDoomscrollPolling();

    // 🟡 INTEGRASI: Dapatkan data live Screen Time dari MonitoringController
    _sinkronisasiDenganMonitoring();
  }

  @override
  void onReady() {
    super.onReady();
    checkUsagePermission();
    checkAllPermissions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveDataPollingTimer?.cancel(); 
    isEyeMonitorActive.value = false;
    super.onClose();
  }

  // =========================
  // DETEKSI LIFECYCLE
  // =========================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      checkUsagePermission();
      checkAllPermissions();
    }
  }

  // =========================
  // CEK SEMUA PERMISSION
  // =========================

  Future<void> checkAllPermissions() async {
    await checkOverlayPermission();
    await isAccessibilityEnabled();
  }

  // ── Overlay (SYSTEM_ALERT_WINDOW) ──

  Future<void> checkOverlayPermission() async {
    try {
      final bool granted =
          await _platformChannel.invokeMethod('checkOverlayPermission');
      hasOverlayPermission.value = granted;
      statusOverlay.value = granted ? "Diizinkan ✓" : "Belum diizinkan";
    } on PlatformException catch (e) {
      statusOverlay.value = "Gagal cek: ${e.message}";
    }
  }

  Future<void> openOverlaySettings() async {
    try {
      await _platformChannel.invokeMethod('openOverlaySettings');
    } on PlatformException catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka pengaturan overlay: ${e.message}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ── Accessibility Service ──

  Future<void> isAccessibilityEnabled() async {
    try {
      final bool granted =
          await _platformChannel.invokeMethod('isAccessibilityEnabled');
      hasAccessibilityPermission.value = granted;
      statusAccessibility.value =
          granted ? "Aktif ✓" : "Belum diaktifkan";
    } on PlatformException catch (e) {
      statusAccessibility.value = "Gagal cek: ${e.message}";
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _platformChannel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka pengaturan aksesibilitas: ${e.message}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // =========================
  // USAGE ACCESS
  // =========================

  Future<void> checkUsagePermission() async {
    try {
      bool granted = await UsageStats.checkUsagePermission() ?? false;
      hasUsagePermission.value = granted;
      statusActivityLooping.value =
          granted ? "Monitoring Aktif" : "Ketuk untuk memberikan izin akses";
    } catch (e) {
      statusActivityLooping.value = "Gagal memeriksa izin";
    }
  }

  Future<void> openUsageAccessSettings() async {
    try {
      await UsageStats.grantUsagePermission();
    } on PlatformException {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka halaman perizinan',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // =========================
  // INTEGRASI DATA LIVE DOOMSCROLLING
  // =========================

  void _startLiveDoomscrollPolling() {
    _liveDataPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (hasAccessibilityPermission.value) {
        try {
          final Map<dynamic, dynamic>? liveData = 
              await _platformChannel.invokeMethod('getLiveDoomscrollData');

          if (liveData != null) {
            doomscrollStatus.value = liveData['status'] ?? 'Rendah';
            doomscrollScore.value = liveData['score'] ?? 95;

            // Hitung ulang skor kesehatan digital setiap kali ada perubahan data doomscrolling
            _hitungTotalDigitalHealthScore();
          }
        } catch (e) {
          print("Pipa data MethodChannel getLiveDoomscrollData terputus: $e");
        }
      }
    });
  }

  // 🟡 SINKRONISASI OTOMATIS: Mengikat data dari MonitoringController secara realtime
  void _sinkronisasiDenganMonitoring() {
    try {
      final monitoringCtrl = Get.find<MonitoringController>();

      // 💡 UBAH DI SINI: Dengarkan 'todayScreenTime', bukan 'totalScreenTime'
      ever(monitoringCtrl.todayScreenTime, (String SOTTerbaru) {
        screenTime.value = SOTTerbaru;

        // Ubah string "Xj Ym" menjadi total integer menit
        int totalMenit = _parseFormatTimeToMinutes(SOTTerbaru);

        // Rumus Skor SOT Hari Ini: 
        // Ideal maks 2 jam (120 menit). Lebih dari itu, kurangi 2 poin tiap 5 menit.
        int scoreSot = 100 - ((totalMenit > 120) ? ((totalMenit - 120) ~/ 5) * 2 : 0);
        screenTimeScore.value = scoreSot.clamp(10, 100);

        // Hitung ulang total skor kesehatan digital dashboard
        _hitungTotalDigitalHealthScore();
      });
    } catch (e) {
      print("INFO: MonitoringController belum terdaftar.");
    }
  }

  // Fungsi helper memecah teks waktu ("5j 20m") menjadi angka menit (320)
  int _parseFormatTimeToMinutes(String timeString) {
    int totalMinutes = 0;
    final jamMatch = RegExp(r'(\d+)j').firstMatch(timeString);
    final menitMatch = RegExp(r'(\d+)m').firstMatch(timeString);
    
    if (jamMatch != null) {
      totalMinutes += int.parse(jamMatch.group(1)!) * 60;
    }
    if (menitMatch != null) {
      totalMinutes += int.parse(menitMatch.group(1)!);
    }
    return totalMinutes;
  }

  // 🟡 TASK 3.3: Rumus Gabungan Digital Health Score Berbobot
  void _hitungTotalDigitalHealthScore() {
    // Rumus Bobot Rasional: (40% ScreenTime) + (30% Doomscrolling) + (30% EyeMonitoring)
    double hasilKalkulasi = (0.40 * screenTimeScore.value) + 
                            (0.30 * doomscrollScore.value) + 
                            (0.30 * eyeMonitoringScore.value);

    // Update nilai utama healthScore dengan pembulatan bilangan bulat terdekat
    healthScore.value = hasilKalkulasi.round();
  }

  // =========================
  // HEALTH INSIGHT
  // =========================

  void toggleHealthInsight(bool value) => isHealthInsightActive.value = value;

  // =========================
  // NOTIFIKASI CERDAS
  // =========================

  void toggleSmartNotif(bool value) {
    isSmartNotifActive.value = value;
    if (value) {
      statusSmartNotif.value = "AI Engine siap mengirim peringatan real-time.";
      Get.snackbar(
        'Notifikasi Aktif',
        'Anda akan menerima peringatan jika terdeteksi kelelahan mata.',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      statusSmartNotif.value = "Sistem Dimatikan";
    }
  }

  // =========================
  // EYE MONITORING SYSTEM
  // =========================

  void toggleEyeMonitor(bool value) {
    isEyeMonitorActive.value = value;
    if (value) {
      statusLooping.value = "Sistem Aktif";
      _startEyeMonitoringLoop();
    } else {
      statusLooping.value = "Sistem Dimatikan";
    }
  }

  void onUserInteract() {
    print("User berinteraksi dengan UI MIND DRIJI");
    lastInteractionTime.value = DateTime.now();
  }

  Future<void> _startEyeMonitoringLoop() async {
    while (isEyeMonitorActive.value) {
      statusLooping.value = "Menganalisis wajah (10 detik)...";
      await Future.delayed(const Duration(seconds: 10));
      if (!isEyeMonitorActive.value) break;
      statusLooping.value = "Jeda (Mode Hemat Baterai)";
      await Future.delayed(const Duration(minutes: 5));
    }
  }
}