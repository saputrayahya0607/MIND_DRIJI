import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

const Color bgDark = Color(0xFF0A0E21);
const Color cardDark = Color(0xFF1D1E33);
const Color accentCyan = Color(0xFF1DE9B6);
const Color warningYellow = Color(0xFFFFD600);
const Color dangerRed = Color(0xFFFF5252);

class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Notifikasi AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: accentCyan),
            onPressed: () {
              // Aksi tandai semua dibaca
              Get.snackbar('Berhasil', 'Semua notifikasi ditandai sudah dibaca', 
                backgroundColor: cardDark, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('Hari Ini', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Notifikasi Bahaya (Merah)
          _buildNotifCard(
            icon: Icons.remove_red_eye, 
            iconColor: dangerRed, 
            title: 'Peringatan Kelelahan Mata!', 
            time: '10 menit yang lalu', 
            desc: 'Blink rate Anda turun drastis ke 12 BPM. Segera istirahatkan mata Anda dengan aturan 20-20-20.',
            isUnread: true,
          ),
          
          // Notifikasi Waspada (Kuning)
          _buildNotifCard(
            icon: Icons.warning_amber_rounded, 
            iconColor: warningYellow, 
            title: 'Indikasi Doomscrolling', 
            time: '1 jam yang lalu', 
            desc: 'Anda telah membuka TikTok selama 45 menit tanpa jeda. Mari istirahat sejenak.',
            isUnread: true,
          ),

          // Notifikasi Info (Cyan)
          _buildNotifCard(
            icon: Icons.health_and_safety, 
            iconColor: accentCyan, 
            title: 'Laporan Harian Tersedia', 
            time: '08:00 AM', 
            desc: 'Skor kesehatan digital Anda hari ini sudah diperbarui. Cek tab Insight sekarang.',
            isUnread: false,
          ),

          const SizedBox(height: 24),
          const Text('Kemarin', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildNotifCard(
            icon: Icons.timer_off_outlined, 
            iconColor: warningYellow, 
            title: 'Batas Screen Time Tercapai', 
            time: 'Kemarin, 21:30', 
            desc: 'Anda telah melewati batas penggunaan layar 4 jam. Mode fokus otomatis diaktifkan.',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard({required IconData icon, required Color iconColor, required String title, required String time, required String desc, required bool isUnread}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isUnread ? iconColor.withOpacity(0.5) : Colors.transparent, width: 1)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: accentCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: accentCyan, blurRadius: 5)])),
          ]
        ],
      ),
    );
  }
}