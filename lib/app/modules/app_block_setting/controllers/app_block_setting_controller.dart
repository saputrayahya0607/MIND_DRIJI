import 'dart:async'; // Wajib ditambahkan untuk Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBlockSettingController extends GetxController {
  // Palet Warna
  final Color bgLight = const Color(0xFFF5F7FA);
  final Color cardLight = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF2D3142);
  final Color textGrey = const Color(0xFF9094A6);
  final Color accentCyan = const Color(0xFF00BFA5);
  final Color dangerRed = const Color(0xFFFF5252);
  final Color warningYellow = const Color(0xFFFFB300);

  // Data aplikasi menggunakan format detik mundur
  var blockedApps = <Map<String, dynamic>>[].obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    // Memasukkan data awal (Simulasi 1 aplikasi dengan waktu 5 Menit = 300 detik)
    blockedApps.add({
      'name': 'TikTok',
      'icon': Icons.tiktok,
      'remaining_seconds': 300, 
    });
    
    // Menjalankan Timer secara global setiap 1 detik
    _startGlobalTimer();
  }

  @override
  void onClose() {
    // Matikan timer saat halaman ini dihancurkan agar tidak boros memori
    _countdownTimer?.cancel();
    super.onClose();
  }

  // FUNGSI UTAMA: Menghitung waktu mundur
  void _startGlobalTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool needsRefresh = false;
      
      // Kita loop dari belakang agar aman saat menghapus data di tengah perulangan
      for (int i = blockedApps.length - 1; i >= 0; i--) {
        if (blockedApps[i]['remaining_seconds'] > 0) {
          blockedApps[i]['remaining_seconds']--;
          needsRefresh = true;
        } else {
          // JIKA WAKTU HABIS = BUKA BLOKIR OTOMATIS
          String appName = blockedApps[i]['name'];
          blockedApps.removeAt(i);
          needsRefresh = true;
          
          Get.snackbar(
            'Sesi Selesai', 
            'Waktu blokir $appName telah habis. Aplikasi otomatis dibuka.', 
            backgroundColor: textDark, 
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.lock_open, color: Colors.white),
          );
        }
      }

      // Memperbarui UI di tampilan secara real-time
      if (needsRefresh) {
        blockedApps.refresh();
      }
    });
  }

  // Fungsi konversi detik ke format MM:SS
  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Buka blokir paksa (manual klik tombol Buka)
  void unblockApp(int index) {
    String appName = blockedApps[index]['name'];
    blockedApps.removeAt(index);
    Get.snackbar(
      'Blokir Dibuka Manual', 
      '$appName sekarang dapat diakses kembali.', 
      backgroundColor: textDark, 
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16)
    );
  }

  // Pop-up AI saat terdeteksi Adiksi
  void triggerDoomscrollWarning(String appName, String usageTime, String riskLevel) {
    Color levelColor = riskLevel == 'Tinggi' ? dangerRed : (riskLevel == 'Sedang' ? warningYellow : accentCyan);
    
    Get.defaultDialog(
      backgroundColor: cardLight,
      barrierDismissible: false, 
      title: 'Doomscrolling $riskLevel',
      titlePadding: const EdgeInsets.only(top: 24, bottom: 8),
      titleStyle: TextStyle(color: levelColor, fontWeight: FontWeight.bold, fontSize: 18),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Icon(Icons.warning_rounded, color: levelColor, size: 60),
            const SizedBox(height: 16),
            Text(
              'Kamu sudah menggunakan $appName selama $usageTime tanpa henti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textDark, fontWeight: FontWeight.w600, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Demi kesehatan matamu, kami sarankan untuk memblokir aplikasi ini sementara waktu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
          Get.snackbar('Diabaikan', 'Peringatan akan muncul lagi jika durasi bertambah.', backgroundColor: bgLight, colorText: textGrey);
        },
        child: Text('Skip', style: TextStyle(color: textGrey, fontWeight: FontWeight.bold)),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: accentCyan, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () {
          Get.back(); 
          // SIMULASI: Tambahkan aplikasi ke blokir selama 1 MENIT (60 Detik) agar cepat didemokan
          blockedApps.add({
            'name': appName,
            'icon': Icons.camera_alt,
            'remaining_seconds': 60, // Di-set 60 detik untuk demo
          });
          Get.snackbar('Diblokir', '$appName dikunci selama 1 menit.', backgroundColor: textDark, colorText: Colors.white);
        },
        child: const Text('Oke, Blokir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}