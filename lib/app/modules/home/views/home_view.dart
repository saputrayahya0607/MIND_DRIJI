import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA); 
const Color cardLight = Color(0xFFFFFFFF); 
const Color textDark = Color(0xFF2D3142); 
const Color textGrey = Color(0xFF9094A6); 
const Color accentCyan = Color(0xFF00BFA5); 
const Color warningYellow = Color(0xFFFFB300);
const Color dangerRed = Color(0xFFFF5252);

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildHealthScoreCard(),
              const SizedBox(height: 32),
              const Text('Kontrol AI Monitoring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 16),
              
              _buildActivityMonitoringStatus(),
              _buildSmartNotifToggle(),
              _buildToggle('Health Insight', 'Analisis dampak kesehatan', controller.isHealthInsightActive, controller.toggleHealthInsight),
              _buildEyeMonitorToggle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Menggunakan Obx agar nama berubah secara realtime mengikuti user login
            Obx(() => Text(
              'Halo, ${controller.namaUser.value} 👋', 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
            )),
            const Text('Siap mengelola waktumu hari ini????', style: TextStyle(color: textGrey, fontSize: 12)),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.NOTIFICATION),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardLight,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: const Icon(Icons.notifications_none, color: accentCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardLight, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warningYellow.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: warningYellow.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(children: [
        const Text('Skor Kesehatan Digital', style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        const Text('72/100', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textDark)),
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

  Widget _buildActivityMonitoringStatus() {
  return Obx(() {
    final bool granted =
        controller.hasUsagePermission.value;

    return GestureDetector(
      onTap: granted
          ? null
          : controller.openUsageAccessSettings,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: granted
                ? accentCyan.withOpacity(0.3)
                : warningYellow.withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    granted
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: granted
                        ? accentCyan
                        : warningYellow,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Monitoring Aktivitas',
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                granted
                    ? 'Mengumpulkan data penggunaan aplikasi secara otomatis'
                    : 'Aplikasi memerlukan izin Usage Access',
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: granted
                      ? accentCyan.withOpacity(0.1)
                      : warningYellow.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      granted
                          ? Icons.check_circle_outline
                          : Icons.touch_app,
                      color: granted
                          ? accentCyan
                          : warningYellow,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller
                            .statusActivityLooping
                            .value,
                        style: TextStyle(
                          color: granted
                              ? accentCyan
                              : warningYellow,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

  Widget _buildSmartNotifToggle() {
    // Obx dipindah ke paling luar agar Container ikut di-rebuild
    return Obx(() => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardLight, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(
          // Sekarang warna border ini akan reaktif!
          color: controller.isSmartNotifActive.value ? accentCyan : Colors.transparent,
          width: 1
        )
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Notifikasi Cerdas', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
            subtitle: const Text('Peringatan AI real-time', style: TextStyle(color: textGrey, fontSize: 12)),
            trailing: Switch(value: controller.isSmartNotifActive.value, activeColor: accentCyan, onChanged: controller.toggleSmartNotif),
          ),
          if (controller.isSmartNotifActive.value)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: accentCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: accentCyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Status: ${controller.statusSmartNotif.value}', style: const TextStyle(color: accentCyan, fontSize: 12, fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildEyeMonitorToggle() {
    return Obx(() => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardLight, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(
          color: controller.isEyeMonitorActive.value ? accentCyan : Colors.transparent,
          width: 1
        )
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => Get.toNamed(Routes.EYE_MONITORING),
            title: const Text('Eye Monitoring', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
            subtitle: const Text('Mode Otomatis (Klik u/ Kalibrasi)', style: TextStyle(color: textGrey, fontSize: 12)),
            trailing: Switch(value: controller.isEyeMonitorActive.value, activeColor: accentCyan, onChanged: controller.toggleEyeMonitor),
          ),
          if (controller.isEyeMonitorActive.value)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: controller.statusLooping.value.contains('Menganalisis') ? dangerRed.withOpacity(0.1) : accentCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(controller.statusLooping.value.contains('Menganalisis') ? Icons.camera_front : Icons.timer, color: controller.statusLooping.value.contains('Menganalisis') ? dangerRed : accentCyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Status: ${controller.statusLooping.value}', style: TextStyle(color: controller.statusLooping.value.contains('Menganalisis') ? dangerRed : accentCyan, fontSize: 12, fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildToggle(String title, String subtitle, RxBool rxValue, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardLight, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Obx(() => ListTile(
        title: Text(title, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: textGrey, fontSize: 12)),
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
      Icon(icon, color: textGrey, size: 20),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold)),
      Text(title, style: const TextStyle(color: textGrey, fontSize: 10)),
    ]);
  }
}