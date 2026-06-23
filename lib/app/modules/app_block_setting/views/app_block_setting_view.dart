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

  @override
  Widget build(BuildContext context) {
    // Karena Anda menggunakan "Get.toNamed", pastikan controller tidak hilang
    Get.put(AppBlockSettingController());

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: textDark), onPressed: () => Get.back()),
        title: const Text('Kelola Blokir Aplikasi', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Aplikasi Dibatasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 8),
            const Text('Aplikasi di bawah ini sedang dikunci sementara oleh AI untuk mencegah doomscrolling.', style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 24),
            
            // Render Daftar Aplikasi dengan Waktu Mundur
            Expanded(
              child: Obx(() => controller.blockedApps.isEmpty 
                ? const Center(child: Text('Tidak ada aplikasi yang diblokir saat ini.', style: TextStyle(color: textGrey)))
                : ListView.builder(
                    itemCount: controller.blockedApps.length,
                    itemBuilder: (context, index) {
                      var app = controller.blockedApps[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardLight, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dangerRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(app['icon'], color: dangerRed)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                                  const SizedBox(height: 4),
                                  // Tampilan Waktu Mundur Dinamis (Berdentak setiap detik)
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
                              style: ElevatedButton.styleFrom(backgroundColor: bgLight, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () => controller.unblockApp(index),
                              child: const Text('Buka', style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ),
            ),

            // Tombol Simulasi untuk Demokan Pop-up AI
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
                label: const Text('Simulasi Pop-up AI (Demo Sidang)', style: TextStyle(color: dangerRed, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}