import 'package:flutter/material.dart'; 
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usage_stats/usage_stats.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// PASTIKAN: Sesuaikan path import ini dengan nama package dan folder proyekmu
import 'package:mind_driji/app/modules/monitoring/controllers/monitoring_controller.dart'; 
import 'package:mind_driji/app/modules/notification/controllers/notification_controller.dart';

class HomeController extends GetxController with WidgetsBindingObserver {

  // Method channel ke native Kotlin untuk cek permission & ambil data live
  static const _platformChannel = MethodChannel('minddriji/intent');

  // =========================
  // DATA USER
  // =========================

  static Map<String, dynamic>? dataUserLogin;
  var namaUser = 'User'.obs;

  // =========================
  // HEALTH SCORE & DIMENSI DATA
  // =========================

  var healthScore = 100.obs; // Mulai dari 100 bersih sebelum kalkulasi turun
  var screenTime = '0j 0m'.obs; 
  var doomscrollStatus = 'Rendah'.obs; 
  var eyeCondition = 'Normal'.obs; 
  final eyeFatigueCount = 0.obs;

  // Skor mentah (0-100) tiap dimensi untuk kebutuhan kalkulasi rumus berbobot
  var screenTimeScore = 100.obs;     
  var doomscrollScore = 0.obs;       // Diubah ke 0 agar mulai dari kondisi bersih/aman
  var eyeMonitoringScore = 100.obs;   // Diubah ke 100 sebagai skor awal kondisi mata prima

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

    _restoreUserProfileIfNeeded();

    if (dataUserLogin != null && dataUserLogin!['nama_lengkap'] != null) {
      namaUser.value = dataUserLogin!['nama_lengkap'];
    } else if (Get.arguments != null && Get.arguments['nama_lengkap'] != null) {
      namaUser.value = Get.arguments['nama_lengkap'];
    }

    checkUsagePermission();
    checkAllPermissions(); 
    
    // DAFTARKAN LISTENER STREAM MATA DARI KOTLIN
    _initEyeStatusStreamListener();

    // Aktifkan mesin pengetuk pintu Kotlin (Polling 3 detik sekali)
    _startLiveDoomscrollPolling();

    // INTEGRASI: Dapatkan data live Screen Time dari MonitoringController
    _sinkronisasiDenganMonitoring();
  }

  @override
  void onReady() {
    super.onReady();
    updateNamaUser();
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
      
      // 🔥 OPTIMASI: Langsung jemput data ke Kotlin begitu aplikasi dibuka, 
      // tanpa perlu menunggu ketukan timer 3 detik berikutnya.
      _updateLiveDoomscrollDataOnce();
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
          granted ? "Monitoring Active" : "Ketuk untuk memberikan izin akses";
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

  // 🌟 FUNGSI BARU
  Future<void> _restoreUserProfileIfNeeded() async {
    if (dataUserLogin != null) return; // udah ada, gak perlu fetch ulang

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        dataUserLogin = profile;
        if (profile['nama_lengkap'] != null) {
          namaUser.value = profile['nama_lengkap'];
        }
        print("✅ dataUserLogin dipulihkan setelah restart: $profile");
      }
    } catch (e) {
      print("❌ Gagal memulihkan dataUserLogin: $e");
    }
  }

  void updateNamaUser() {
    if (dataUserLogin != null && dataUserLogin!['nama_lengkap'] != null) {
      namaUser.value = dataUserLogin!['nama_lengkap'].toString();
    } else if (Get.arguments != null && Get.arguments['nama_lengkap'] != null) {
      namaUser.value = Get.arguments['nama_lengkap'].toString();
    }
  }

  // =========================
  // INTEGRASI DATA LIVE DOOMSCROLLING
  // =========================

  void _startLiveDoomscrollPolling() {
    // Jalankan pengambilan data pertama kali saat fungsi dipanggil
    _updateLiveDoomscrollDataOnce();

    // Jalankan loop per 3 detik
    _liveDataPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateLiveDoomscrollDataOnce();
    });
  }

  // 🔥 FUNGSI MANDIRI: Dipecah agar bisa dipanggil oleh Timer maupun Lifecycle Resumed
  Future<void> _updateLiveDoomscrollDataOnce() async {
    if (hasAccessibilityPermission.value) {
      try {
        final Map<dynamic, dynamic>? liveData = 
            await _platformChannel.invokeMethod('getLiveDoomscrollData');

        if (liveData != null) {
          // 1. Simpan status sebelum di-update
          String statusLama = doomscrollStatus.value; 

          // 2. Update nilai baru dari AI
          doomscrollStatus.value = liveData['status'] ?? 'Rendah';
          doomscrollScore.value = liveData['score'] ?? 0;

          // 3. Logika Log Pintar (Hanya mencatat jika ada PERUBAHAN STATUS agar tidak spam)
          if (statusLama != doomscrollStatus.value) {
            
            // KONDISI A: Saat mulai terdeteksi doomscrolling (Status naik ke 'Sedang')
            if (doomscrollStatus.value == 'Sedang') {
              Get.find<NotificationController>().addLog(
                'Doomscrolling Terdeteksi 📱',
                'AI melihat Anda mulai asyik scrolling. Yuk, kendalikan Scrollingmu dari sekarang!',
                'doomscroll' // Ikon & warna otomatis menyesuaikan di View
              );
            }
            
            // KONDISI B: Saat indikator sudah mencapai tingkat bahaya (Status naik ke 'Tinggi')
            else if (doomscrollStatus.value == 'Tinggi') {
              Get.find<NotificationController>().addLog(
                'Kritis: Doomscrolling Tinggi! 🚨',
                'Anda sudah tenggelam terlalu lama dalam scrolling. Sangat disarankan untuk segera menutup aplikasi!',
                'doomscroll'
              );
            }
          }

          // 4. Hitung ulang total skor kesehatan digital
          _hitungTotalDigitalHealthScore();
        }
      } catch (e) {
        print("Pipa data MethodChannel getLiveDoomscrollData terputus: $e");
      }
    }
  }

  // SINKRONISASI OTOMATIS: Mengikat data dari MonitoringController secara realtime
  void _sinkronisasiDenganMonitoring() {
    try {
      final monitoringCtrl = Get.find<MonitoringController>();

      ever(monitoringCtrl.todayScreenTime, (String SOTTerbaru) {
        screenTime.value = SOTTerbaru;

        int totalMenit = _parseFormatTimeToMinutes(SOTTerbaru);

        int scoreSot = 100 - ((totalMenit > 120) ? ((totalMenit - 120) ~/ 5) * 2 : 0);
        screenTimeScore.value = scoreSot.clamp(10, 100);

        // ==========================================
        // 🔥 TAMBAHKAN LOG SCREEN TIME DI SINI
        // ==========================================
        // Menyentuh tepat 2 Jam (120 menit)
        if (totalMenit == 120) {
          Get.find<NotificationController>().addLog(
            'Batas Ideal Layar Tercapai',
            'Penggunaan layar Anda hari ini sudah mencapai 2 jam. Kurangi konsumsi gadget ya.',
            'sot'
          );
        } 
        // Menyentuh tepat 4 Jam (240 menit)
        else if (totalMenit == 240) {
          Get.find<NotificationController>().addLog(
            'Peringatan Screen Time! ⏱️',
            'SOT Anda sudah menembus 4 jam hari ini! Sangat disarankan untuk melakukan aktivitas fisik.',
            'sot'
          );
        }

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

  // Rumus Gabungan Digital Health Score Berbobot
  void _hitungTotalDigitalHealthScore() {
    // Rumus Bobot Rasional: (40% ScreenTime) + (30% Doomscrolling) + (30% EyeMonitoring)
    // Untuk Nilai Doomscrolling, karena 100 adalah kondisi terburuk (parah), kita balik logikanya (100 - score)
    int doomscrollInverseScore = 100 - doomscrollScore.value;

    double hasilKalkulasi = (0.40 * screenTimeScore.value) + 
                            (0.30 * doomscrollInverseScore) + 
                            (0.30 * eyeMonitoringScore.value);

    // Update nilai utama healthScore dengan pembulatan bilangan bulat terdekat
    healthScore.value = hasilKalkulasi.round().clamp(0, 100);
  }

  // =========================
  // EYE MONITORING SYSTEM (MEDIAPIPE STREAM INTEGRATION)
  // =========================

  // CARI FUNGSI INI DI HOME CONTROLLER
  void _initEyeStatusStreamListener() {
    _platformChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "onEyeStatusUpdate") {
        String statusMasuk = call.arguments ?? "Normal";
        statusLooping.value = "Mengamati: $statusMasuk";

        if (eyeCondition.value == statusMasuk) return;
        eyeCondition.value = statusMasuk;

        if (statusMasuk == "Lelah") {
          eyeFatigueCount.value++;
          eyeMonitoringScore.value = (eyeMonitoringScore.value - 8).clamp(10, 100);
          _hitungTotalDigitalHealthScore();

          // ==========================================
          // 🔥 TAMBAHKAN LOG EYE MONITORING DI SINI
          // ==========================================
          Get.find<NotificationController>().addLog(
            'Mata Terdeteksi Lelah! ⚠️',
            'AI mendeteksi mata Anda mulai sayu/lelah. Istirahat sejenak, Boss!',
            'eye' // type sesuai dengan switch case di View
          );

          Get.snackbar(
            'Mata Terdeteksi Lelah! ⚠️',
            'AI mendeteksi mata Anda mulai sayu/lelah akibat doomscrolling. Istirahat sejenak, Boss!',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
        }
        else if (statusMasuk == "Normal") {
          eyeMonitoringScore.value = (eyeMonitoringScore.value + 2).clamp(10, 100);
          _hitungTotalDigitalHealthScore();
        }
      }
    });
  }

  void toggleEyeMonitor(bool value) async {
    if (value) {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }

      if (status.isGranted) {
        isEyeMonitorActive.value = true;
        statusLooping.value = "Memulai deteksi AI Latar Belakang...";
        
        try {
          final String responNative = await _platformChannel.invokeMethod('startEyeCapture');
          print("Respons Native Android: $responNative"); 
        } catch (e) {
          print("Gagal menyalakan service kamera: $e");
          statusLooping.value = "Gagal terhubung ke background service";
        }
        
      } else {
        isEyeMonitorActive.value = false;
      }
    } else {
      isEyeMonitorActive.value = false;
      statusLooping.value = "Sistem Dimatikan";
      try {
        await _platformChannel.invokeMethod('stopEyeCapture');
      } catch (e) {
        print("Gagal mematikan background service: $e");
      }
    }
  }

  void onUserInteract() {
    print("User berinteraksi dengan UI MIND DRIJI");
    lastInteractionTime.value = DateTime.now();
  }
}