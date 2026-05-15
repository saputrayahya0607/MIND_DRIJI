import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

const Color cardDark = Color(0xFF1D1E33);
const Color accentCyan = Color(0xFF1DE9B6);
const Color warningYellow = Color(0xFFFFD600);
const Color dangerRed = Color(0xFFFF5252);
const Color bgDark = Color(0xFF0A0E21);

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildHealthScoreCard(),
          const SizedBox(height: 32),
          const Text('Kontrol AI Monitoring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          
          // Widget Khusus Monitoring Aktivitas
          _buildActivityMonitorToggle(),
          
          // Widget Khusus Notifikasi Cerdas
          _buildSmartNotifToggle(),
          
          // Toggle Standar untuk Health Insight
          _buildToggle('Health Insight', 'Analisis dampak kesehatan', controller.isHealthInsightActive, controller.toggleHealthInsight),
          
          // Widget Khusus Eye Monitoring
          _buildEyeMonitorToggle(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Halo, Saputra 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Siap mengelola waktumu hari ini?', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.NOTIFICATION),
          child: const CircleAvatar(
            backgroundColor: cardDark, 
            child: Icon(Icons.notifications_none, color: accentCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardDark, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warningYellow.withOpacity(0.3))
      ),
      child: Column(children: [
        const Text('Skor Kesehatan Digital', style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 16),
        const Text('72/100', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: warningYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
          child: const Text('Status: Waspada', style: TextStyle(color: warningYellow, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MiniStat(icon: Icons.timer_outlined, label: '5j 20m', title: 'Screen Time'),
            _MiniStat(icon: Icons.warning_amber_rounded, label: 'Tinggi', title: 'Doomscroll'),
            _MiniStat(icon: Icons.remove_red_eye_outlined, label: 'Lelah', title: 'Kondisi Mata'),
          ],
        )
      ]),
    );
  }

  // WIDGET HELPER KHUSUS MONITORING AKTIVITAS
  Widget _buildActivityMonitorToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardDark, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: controller.isMonitoringActive.value ? accentCyan.withOpacity(0.5) : Colors.transparent,
          width: 1
        )
      ),
      child: Obx(() => Column(
        children: [
          ListTile(
            title: const Text('Monitoring Aktivitas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Lacak penggunaan aplikasi', style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Switch(
              value: controller.isMonitoringActive.value,
              activeColor: accentCyan,
              onChanged: controller.toggleMonitoring,
            ),
          ),
          
          if (controller.isMonitoringActive.value)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.data_usage, color: accentCyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status: ${controller.statusActivityLooping.value}', 
                        style: const TextStyle(color: accentCyan, fontSize: 12, fontStyle: FontStyle.italic)
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )),
    );
  }

  // WIDGET HELPER KHUSUS NOTIFIKASI CERDAS
  Widget _buildSmartNotifToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardDark, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: controller.isSmartNotifActive.value ? accentCyan.withOpacity(0.5) : Colors.transparent,
          width: 1
        )
      ),
      child: Obx(() => Column(
        children: [
          ListTile(
            title: const Text('Notifikasi Cerdas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Peringatan AI real-time', style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Switch(
              value: controller.isSmartNotifActive.value,
              activeColor: accentCyan,
              onChanged: controller.toggleSmartNotif,
            ),
          ),
          
          if (controller.isSmartNotifActive.value)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: accentCyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status: ${controller.statusSmartNotif.value}', 
                        style: const TextStyle(color: accentCyan, fontSize: 12, fontStyle: FontStyle.italic)
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )),
    );
  }

  // WIDGET HELPER KHUSUS EYE MONITORING
  Widget _buildEyeMonitorToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardDark, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: controller.isEyeMonitorActive.value ? accentCyan.withOpacity(0.5) : Colors.transparent,
          width: 1
        )
      ),
      child: Obx(() => Column(
        children: [
          ListTile(
            onTap: () => Get.toNamed(Routes.EYE_MONITORING),
            title: const Text('Eye Monitoring', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Mode Otomatis (Klik u/ Kalibrasi)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Switch(
              value: controller.isEyeMonitorActive.value,
              activeColor: accentCyan,
              onChanged: controller.toggleEyeMonitor,
            ),
          ),
          
          if (controller.isEyeMonitorActive.value)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(
                      controller.statusLooping.value.contains('Menganalisis') ? Icons.camera_front : Icons.timer, 
                      color: controller.statusLooping.value.contains('Menganalisis') ? dangerRed : accentCyan, 
                      size: 16
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status: ${controller.statusLooping.value}', 
                        style: TextStyle(
                          color: controller.statusLooping.value.contains('Menganalisis') ? dangerRed : accentCyan, 
                          fontSize: 12, fontStyle: FontStyle.italic
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )),
    );
  }

  // WIDGET HELPER TOGGLE STANDAR
  Widget _buildToggle(String title, String subtitle, RxBool rxValue, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(15)),
      child: Obx(() => ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Switch(value: rxValue.value, activeColor: accentCyan, onChanged: onChanged),
      )),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  const _MiniStat({required this.icon, required this.label, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.grey, size: 20),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
    ]);
  }
}