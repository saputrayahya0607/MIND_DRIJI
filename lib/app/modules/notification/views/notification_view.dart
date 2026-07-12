import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';
import 'package:mind_driji/app/data/models/log_model.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3142);
const Color textGrey = Color(0xFF9094A6);
const Color accentCyan = Color(0xFF00BFA5);
const Color warningYellow = Color(0xFFFFB300);
const Color dangerRed = Color(0xFFFF5252);

class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text('Log Aktivitas AI', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // MENGGUNAKAN CLEAR LOGS UNTUK MEMBERSIHKAN RIWAYAT
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: dangerRed),
            onPressed: () {
              if (controller.logList.isNotEmpty) {
                controller.clearLogs();
                Get.snackbar('Berhasil', 'Semua log aktivitas telah dihapus', 
                  backgroundColor: textDark, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
              }
            },
          )
        ],
      ),
      // MENGGUNAKAN OBX DENGAN KONDISI EMPTY STATE YANG RAPI
      body: Obx(() {
        if (controller.logList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off_rounded, size: 64, color: textGrey),
                SizedBox(height: 16),
                Text(
                  'Belum ada log aktivitas tercatat',
                  style: TextStyle(color: textGrey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: controller.logList.length,
          itemBuilder: (context, index) {
            final log = controller.logList[index];
            return _buildNotifCard(log);
          },
        );
      }),
    );
  }

  // WIDGET CARD YANG OTOMATIS MENENTUKAN IKON & WARNA BERDASARKAN TIPE LOG
  Widget _buildNotifCard(ActivityLog log) {
    IconData icon;
    Color iconColor;

    // Memetakan tipe log string ke komponen UI Visual secara dinamis
    switch (log.type) {
      case 'eye':
        icon = Icons.remove_red_eye;
        iconColor = dangerRed;
        break;
      case 'doomscroll':
        icon = Icons.warning_amber_rounded;
        iconColor = warningYellow;
        break;
      case 'sot':
        icon = Icons.timer_off_outlined;
        iconColor = accentCyan;
        break;
      case 'profile':
        icon = Icons.person_outline_rounded;
        iconColor = Colors.blue;
        break;
      case 'password':
        icon = Icons.lock_outline_rounded;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = textGrey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: iconColor.withOpacity(0.15), width: 1)
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
                    Expanded(
                      child: Text(
                        log.title, 
                        style: const TextStyle(color: textDark, fontWeight: FontWeight.bold)
                      )
                    ),
                    Text(
                      log.timestamp, 
                      style: const TextStyle(color: textGrey, fontSize: 10)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.desc, 
                  style: const TextStyle(color: textGrey, fontSize: 12, height: 1.5)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}