import 'package:get/get.dart';
import 'dart:async';

class HomeController extends GetxController {
  // State Toggle Umum
  var isHealthInsightActive = true.obs;

  // State Khusus Monitoring Aktivitas
  var isMonitoringActive = false.obs;
  var statusActivityLooping = "Menunggu diaktifkan".obs;

  // State Khusus Notifikasi Cerdas (BARU)
  var isSmartNotifActive = false.obs;
  var statusSmartNotif = "Menunggu diaktifkan".obs;

  // State Khusus Eye Monitoring
  var isEyeMonitorActive = false.obs;
  var statusLooping = "Menunggu diaktifkan".obs; 

  void toggleHealthInsight(bool value) => isHealthInsightActive.value = value;

  // === LOGIKA NOTIFIKASI CERDAS ===
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

  // === LOGIKA MONITORING AKTIVITAS ===
  void toggleMonitoring(bool value) {
    isMonitoringActive.value = value;
    if (value) {
      statusActivityLooping.value = "Merekam Screen Time di latar belakang...";
    } else {
      statusActivityLooping.value = "Sistem Dimatikan";
    }
  }

  // === LOGIKA EYE MONITORING ===
  void toggleEyeMonitor(bool value) {
    isEyeMonitorActive.value = value;
    if (value) {
      statusLooping.value = "Sistem Aktif";
      _startEyeMonitoringLoop();
    } else {
      statusLooping.value = "Sistem Dimatikan";
    }
  }

  void _startEyeMonitoringLoop() async {
    while (isEyeMonitorActive.value == true) {
      statusLooping.value = "Menganalisis wajah (10 detik)...";
      await Future.delayed(const Duration(seconds: 10));
      if (isEyeMonitorActive.value == false) break;
      statusLooping.value = "Jeda (Mode Hemat Baterai)";
      await Future.delayed(const Duration(minutes: 5));
    }
  }
}