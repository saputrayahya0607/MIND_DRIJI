// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_block_setting_controller.dart';

const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3142);
const Color textGrey = Color(0xFF9094A6);
const Color accentCyan = Color(0xFF00BFA5);
const Color dangerRed = Color(0xFFFF5252);

class AppBlockSettingView extends GetView<AppBlockSettingController> {
  const AppBlockSettingView({Key? key}) : super(key: key);
  // Fungsi tambahan untuk merapikan nama aplikasi yang tidak terdeteksi
  String _getCleanAppName(String rawName) {
    switch (rawName) {
      case 'com.ss.android.ugc.trill':
      case 'com.zhiliaoapp.musically':
        return 'TikTok';
      case 'com.google.android.youtube':
        return 'YouTube';
      case 'com.snapchat.android':
        return 'Snapchat';
      case 'com.instagram.android':
        return 'Instagram';
      default:
        return rawName; // Jika sudah rapi (ex: Instagram), biarkan tetap sama
    }
  }

  // Fungsi tambahan untuk memasang ikon yang sesuai secara dinamis
  IconData _getCleanAppIcon(String rawName, IconData defaultIcon) {
    // Cek jika teksnya mengandung package name atau nama asli
    if (rawName.contains('trill') || rawName.contains('musically') || rawName == 'TikTok') {
      return Icons.music_note_rounded; // Ikon balok not untuk TikTok
    } else if (rawName.contains('youtube') || rawName == 'YouTube') {
      return Icons.play_arrow_rounded;
    } else if (rawName.contains('instagram') || rawName == 'Instagram') {
      return Icons.camera_alt_rounded;
    } else if (rawName.contains('snapchat') || rawName == 'Snapchat') {
      return Icons.filter_center_focus_rounded;
    }
    return defaultIcon; // Kembalikan ikon bawaan jika tidak terdaftar
  }

  @override
  Widget build(BuildContext context) {
    // 💡 OPTIMALISASI: Gunakan Get.alignment/find atau biarkan Get.put memeriksa dependensi 
    // dengan aman tanpa membebani performa memori saat widget me-rebuild tiap detik.
    if (!Get.isRegistered<AppBlockSettingController>()) {
      Get.put(AppBlockSettingController());
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark), 
          onPressed: () => Get.back()
        ),
        title: const Text(
          'Kelola Blokir Aplikasi', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Aplikasi Dibatasi', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi di bawah ini sedang dikunci sementara oleh AI untuk mencegah doomscrolling.', 
              style: TextStyle(color: textGrey, fontSize: 12)
            ),
            const SizedBox(height: 20),
            
            // ========================================================
            // BANNER STATUS & SHORTCUT PERIZINAN AKSESIBILITAS
            // ========================================================
            Obx(() {
              // Skenario 1: Jika Izin Aksesibilitas BELUM diberikan di HP
              if (!controller.isAccessibilityGranted.value) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: dangerRed.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gavel_rounded, color: dangerRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Izin Deteksi Diperlukan', 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14)
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Aktifkan aksesibilitas agar AI bisa mendeteksi doomscrolling di TikTok/IG secara real-time.', 
                                  style: TextStyle(fontSize: 11, color: textDark, height: 1.3)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dangerRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => controller.openAccessibilitySettings(),
                          child: const Text(
                            'Aktifkan Sekarang (Langsung ke Izin)', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Skenario 2: Jika Izin Aksesibilitas SUDAH diaktifkan di HP
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: accentCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: accentCyan.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: accentCyan, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'AI Detektor Latar Belakang Aktif', 
                      style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ],
                ),
              );
            }),

            // ========================================================
            // RENDER DAFTAR APLIKASI DENGAN WAKTU MUNDUR (RIIL DARI KOTLIN)
            // ========================================================
            Expanded(
              child: Obx(() => controller.blockedApps.isEmpty 
                ? const Center(
                    child: Text(
                      'Tidak ada aplikasi yang diblokir saat ini.', 
                      style: TextStyle(color: textGrey)
                    )
                  )
                : ListView.builder(
                    itemCount: controller.blockedApps.length,
                    itemBuilder: (context, index) {
                      var app = controller.blockedApps[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardLight, 
                          borderRadius: BorderRadius.circular(15), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03), 
                              blurRadius: 10
                            )
                          ]
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12), 
                              decoration: BoxDecoration(
                                color: dangerRed.withOpacity(0.1), 
                                borderRadius: BorderRadius.circular(10)
                              ), 
                              child: Icon(_getCleanAppIcon(app['name'], app['icon']), color: dangerRed)
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getCleanAppName(app['name']),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 14, color: dangerRed),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Sisa waktu: ${controller.formatTime(app['remaining_seconds'])}',
                                        style: const TextStyle(color: dangerRed, fontSize: 12, fontWeight: FontWeight.bold)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgLight, 
                                elevation: 0, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              // Fungsi ini sekarang otomatis mematikan pengunci di Native Android
                              onPressed: () => controller.unblockApp(index),
                              child: const Text(
                                'Buka', 
                                style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold, fontSize: 12)
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ),
            ),

            // ========================================================
            // TOMBOL SIMULASI UNTUK DEMO SIDANG
            // ========================================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: dangerRed),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () => controller.triggerDoomscrollWarning('Instagram', '2 Jam 30 Menit', 'Tinggi'),
                icon: const Icon(Icons.bug_report, color: dangerRed),
                label: const Text(
                  'Simulasi Pop-up AI (Demo Sidang)', 
                  style: TextStyle(color: dangerRed, fontWeight: FontWeight.bold)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}