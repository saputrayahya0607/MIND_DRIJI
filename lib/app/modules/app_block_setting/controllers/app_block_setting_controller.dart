import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppBlockSettingController extends GetxController with WidgetsBindingObserver {
  // Channel komunikasi ke Android Native
  static const platform = MethodChannel('minddriji/intent');

  // List reactive berisi aplikasi yang sedang diblokir
  var blockedApps = <Map<String, dynamic>>[].obs;

  Timer? _countdownTimer;

  // VARIABLE STATUS PERIZINAN
  var isAccessibilityGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    
    // 1. Ambil data blokir riil dari Native Kotlin saat pertama dibuka
    fetchBlockStatusFromNative();
    checkAccessibilityStatus();
    
    _startTimer();
  }

  @override
  void onReady() {
    super.onReady();
    _checkIncomingIntent(); 
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 2. Setiap kali user kembali ke MIND DRIJI (Hot Resume), paksa refresh data dari Native
    if (state == AppLifecycleState.resumed) {
      _checkIncomingIntent(); 
      checkAccessibilityStatus(); 
      fetchBlockStatusFromNative(); // <-- WAJIB DI-REFRESH DI SINI
    }
  }

  // ========================================================
  // LOGIKA BARU: SINKRONISASI DATA DENGAN NATIVE KOTLIN
  // ========================================================

  // Fungsi untuk menarik data dari BlockPreferenceManager Kotlin
  Future<void> fetchBlockStatusFromNative() async {
    try {
      // Mengambil data Map dari Kotlin
      final Map<dynamic, dynamic> blockedMap = await platform.invokeMethod('getBlockStatus');
      
      List<Map<String, dynamic>> tempList = [];
      
      blockedMap.forEach((key, value) {
        String pkg = key.toString();
        int remainingMs = value as int; // sisa waktu per aplikasi dari Kotlin
        
        String displayName = _convertPackageToName(pkg);
        
        IconData appIcon;
        switch (displayName) {
          case 'TikTok': appIcon = Icons.music_note_rounded; break;
          case 'Instagram': appIcon = Icons.camera_alt_rounded; break;
          case 'YouTube': appIcon = Icons.play_arrow_rounded; break;
          case 'Snapchat': appIcon = Icons.filter_center_focus_rounded; break;
          default: appIcon = Icons.block_rounded;
        }
        
        tempList.add({
          'package': pkg,
          'name': displayName,
          'icon': appIcon,
          'remaining_seconds': remainingMs ~/ 1000, // Konversi ke detik untuk countdown UI Flutter
        });
      });

      // Update UI List kamu (Sesuaikan sintaks ini dengan state management-mu, misal: GetX blockedApps.assignAll(tempList))
      blockedApps.value = tempList; 
      
    } catch (e) {
      print("Gagal mengambil status blokir mandiri: $e");
    }
  }

  // Fungsi helper menyederhanakan nama package Android
  String _convertPackageToName(String packageName) {
    if (packageName.contains('musically') || packageName.contains('tiktok') || packageName.contains('trill')) {
      return 'TikTok';
    } else if (packageName.contains('instagram')) {
      return 'Instagram';
    } else if (packageName.contains('youtube')) {
      return 'YouTube';
    } else if (packageName.contains('snapchat')) {
      return 'Snapchat';
    }
    return packageName; // kembalikan string package asli jika tidak terdaftar
  }

  // Fungsi untuk membuka blokir aplikasi (Trigger lewat tombol di UI Flutter)
  Future<void> unblockApp(int index) async {
    try {
      // 1. Ambil data nama paket dan nama aplikasi berdasarkan indeks yang diklik
      String packageName = blockedApps[index]['package'];
      String appName = blockedApps[index]['name'];

      // 2. Perintahkan Kotlin dengan menyertakan argumen 'packageName'
      final bool success = await platform.invokeMethod('clearBlock', {
        'packageName': packageName,
      }) ?? false;
      
      if (success) {
        // 3. 🔥 HAPUS HANYA aplikasi ini saja dari list UI GetX (bukan .clear() semuanya)
        blockedApps.removeAt(index);

        Get.snackbar(
          "Akses Dibuka",
          "Blokir untuk aplikasi $appName telah dinonaktifkan.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF00BFA5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Gagal membuka blokir via MethodChannel: $e");
      Get.snackbar("Error", "Gagal membuka blokir aplikasi.");
    }
  }

  // ==========================================
  // FITUR BAWAAN KAMU YANG SUDAH ADA
  // ==========================================

  Future<void> checkAccessibilityStatus() async {
    try {
      final bool isEnabled = await platform.invokeMethod('isAccessibilityEnabled') ?? false;
      isAccessibilityGranted.value = isEnabled;
    } catch (e) {
      print("Gagal cek status aksesibilitas: $e");
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      Get.snackbar("Error", "Gagal membuka Pengaturan Aksesibilitas");
    }
  }

  Future<void> _checkIncomingIntent() async {
    try {
      final bool shouldTrigger = await platform.invokeMethod('checkIntentExtra') ?? false;
      if (shouldTrigger) {
        triggerDoomscrollWarning('TikTok', '45 Menit', 'Tinggi');
      }
    } catch (e) {
      print("Gagal membaca intent di AppBlockController: $e");
    }
  }

  // Timer hitung mundur lokal di Flutter agar detik berjalan real-time di UI
  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (blockedApps.isEmpty) return;
      
      for (int i = 0; i < blockedApps.length; i++) {
        var app = Map<String, dynamic>.from(blockedApps[i]);
        if (app['remaining_seconds'] > 0) {
          app['remaining_seconds']--;
          blockedApps[i] = app;
        } else {
          blockedApps.removeAt(i);
          i--; 
        }
      }
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // UI Pop-up Kunci Total Rekomendasi
  void triggerDoomscrollWarning(String appName, String duration, String severity) {
    const Color cardLight = Color(0xFFFFFFFF);
    const Color textDark = Color(0xFF2D3142);
    const Color textGrey = Color(0xFF9094A6);
    const Color accentCyan = Color(0xFF00BFA5);
    const Color dangerRed = Color(0xFFFF5252);

    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      PopScope(
        canPop: false, 
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: cardLight,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Doomscrolling $severity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: dangerRed)),
                const SizedBox(height: 20),
                const Icon(Icons.warning_rounded, color: dangerRed, size: 72),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: textDark, fontSize: 14, height: 1.5),
                    children: [
                      const TextSpan(text: "Kamu sudah menggunakan "),
                      TextSpan(text: appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: " selama "),
                      TextSpan(text: duration, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: " tanpa henti."),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Demi kesehatan matamu, kami sarankan untuk memblokir aplikasi ini sementara waktu.", textAlign: TextAlign.center, style: TextStyle(color: textGrey, fontSize: 12, height: 1.4)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text("Skip", style: TextStyle(color: textGrey, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          // Kamu bisa menambahkan pemicu blokir manual ke native di sini jika dibutuhkan ke depan
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: accentCyan, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                        child: const Text("Oke, Blokir", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}