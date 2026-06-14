import 'package:flutter/widgets.dart'; // <-- TAMBAHKAN INI UNTUK APP LIFECYCLE
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usage_stats/usage_stats.dart'; 
import 'dart:async';

// Tambahkan "with WidgetsBindingObserver" di sini
class HomeController extends GetxController with WidgetsBindingObserver {
  // =========================
  // DATA USER
  // =========================

  static Map<String, dynamic>? dataUserLogin;

  var namaUser = 'Saputra'.obs;

  // =========================
  // HEALTH SCORE
  // =========================

  var healthScore = 72.obs;
  var screenTime = '5j 20m'.obs;
  var doomscrollStatus = 'Tinggi'.obs;
  var eyeCondition = 'Lelah'.obs;

  // =========================
  // MONITORING AKTIVITAS
  // =========================

  var hasUsagePermission = false.obs;

  var statusActivityLooping =
      "Ketuk untuk memberikan izin akses".obs;

  // =========================
  // NOTIFIKASI CERDAS
  // =========================

  var isSmartNotifActive = false.obs;
  var statusSmartNotif = "Menunggu diaktifkan".obs;

  // =========================
  // HEALTH INSIGHT
  // =========================

  var isHealthInsightActive = true.obs;

  // =========================
  // EYE MONITORING
  // =========================

  var isEyeMonitorActive = false.obs;
  var statusLooping = "Menunggu diaktifkan".obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();
    
    // 1. Daftarkan controller ini sebagai observer lifecycle aplikasi
    WidgetsBinding.instance.addObserver(this);

    if (dataUserLogin != null &&
        dataUserLogin!['nama_lengkap'] != null) {
      namaUser.value = dataUserLogin!['nama_lengkap'];

      print(
        "Berhasil sinkronisasi nama dari dataUserLogin: ${namaUser.value}",
      );
    } else if (Get.arguments != null &&
        Get.arguments['nama_lengkap'] != null) {
      namaUser.value = Get.arguments['nama_lengkap'];
    }

    checkUsagePermission();
  }

  @override
  void onReady() {
    super.onReady();

    // Cek lagi ketika halaman aktif
    checkUsagePermission();
  }

  @override
  void onClose() {
    // 2. Hapus observer saat controller dihancurkan agar tidak memory leak
    WidgetsBinding.instance.removeObserver(this);
    
    isEyeMonitorActive.value = false;
    super.onClose();
  }

  // =========================
  // DETEKSI LIFECYCLE (BARU)
  // =========================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Jika aplikasi kembali ke layar utama (setelah user buka Settings)
    if (state == AppLifecycleState.resumed) {
      checkUsagePermission(); // Otomatis cek izin secara real-time!
    }
  }

  // =========================
  // USAGE ACCESS
  // =========================

  Future<void> checkUsagePermission() async {
    try {
      bool granted = await UsageStats.checkUsagePermission() ?? false;

      hasUsagePermission.value = granted;

      if (granted) {
        statusActivityLooping.value = "Monitoring Aktif";
      } else {
        statusActivityLooping.value = "Ketuk untuk memberikan izin akses";
      }
    } catch (e) {
      statusActivityLooping.value = "Gagal memeriksa izin";
    }
  }

  Future<void> openUsageAccessSettings() async {
    try {
      // Buka halaman pengaturan Android
      await UsageStats.grantUsagePermission();

      // NOTED: Fungsi Future.delayed di sini dihapus karena logic pengecekan 
      // sudah digantikan oleh didChangeAppLifecycleState yang jauh lebih akurat.
      
    } on PlatformException {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka halaman perizinan',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // =========================
  // HEALTH INSIGHT
  // =========================

  void toggleHealthInsight(bool value) {
    isHealthInsightActive.value = value;
  }

  // =========================
  // NOTIFIKASI CERDAS
  // =========================

  void toggleSmartNotif(bool value) {
    isSmartNotifActive.value = value;

    if (value) {
      statusSmartNotif.value =
          "AI Engine siap mengirim peringatan real-time.";

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
  // EYE MONITORING
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

  Future<void> _startEyeMonitoringLoop() async {
    while (isEyeMonitorActive.value) {
      statusLooping.value =
          "Menganalisis wajah (10 detik)...";

      await Future.delayed(
        const Duration(seconds: 10),
      );

      if (!isEyeMonitorActive.value) {
        break;
      }

      statusLooping.value =
          "Jeda (Mode Hemat Baterai)";

      await Future.delayed(
        const Duration(minutes: 5),
      );
    }
  }
}