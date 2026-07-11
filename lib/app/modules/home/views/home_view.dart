import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

// PALET WARNA LIGHT MODE
const Color bgLight       = Color(0xFFF5F7FA);
const Color cardLight     = Color(0xFFFFFFFF);
const Color textDark      = Color(0xFF2D3142);
const Color textGrey      = Color(0xFF9094A6);
const Color accentCyan    = Color(0xFF00BFA5);
const Color warningYellow = Color(0xFFFFB300);
const Color dangerRed     = Color(0xFFFF5252);

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildHealthScoreCard(),
              const SizedBox(height: 32),
              const Text(
                'Kontrol AI Monitoring',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 16),

              // ── Permission cards ──
              _buildOverlayPermissionCard(),
              _buildAccessibilityPermissionCard(),

              // ── Card monitoring ──
              _buildActivityMonitoringStatus(),
              _buildEyeMonitorToggle(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARD: Display over other apps (OVERLAY)
  // ─────────────────────────────────────────────
  Widget _buildOverlayPermissionCard() {
    return Obx(() {
      final bool granted = controller.hasOverlayPermission.value;
      final Color borderColor =
          granted ? accentCyan.withOpacity(0.3) : warningYellow.withOpacity(0.5);
      final Color iconColor   = granted ? accentCyan : warningYellow;
      final IconData icon     = granted ? Icons.layers : Icons.layers_clear;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Tampil di Atas Aplikasi',
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
                    ? 'Popup peringatan bisa muncul langsung di atas TikTok & Instagram'
                    : 'Diperlukan agar popup muncul di atas aplikasi lain',
                style: const TextStyle(color: textGrey, fontSize: 12),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: granted
                            ? accentCyan.withOpacity(0.1)
                            : warningYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            granted
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_outlined,
                            color: iconColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.statusOverlay.value,
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!granted) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        controller.onUserInteract();
                        controller.openOverlaySettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warningYellow,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Izinkan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // CARD: Accessibility Service
  // ─────────────────────────────────────────────
  Widget _buildAccessibilityPermissionCard() {
    return Obx(() {
      final bool granted = controller.hasAccessibilityPermission.value;
      final Color borderColor =
          granted ? accentCyan.withOpacity(0.3) : dangerRed.withOpacity(0.4);
      final Color iconColor =
          granted ? accentCyan : dangerRed;
      final IconData icon =
          granted ? Icons.accessibility_new : Icons.accessibility;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Accessibility Service',
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
                    ? 'MIND DRIJI aktif mendeteksi doomscrolling di latar belakang'
                    : 'Wajib diaktifkan agar deteksi doomscrolling bisa berjalan',
                style: const TextStyle(color: textGrey, fontSize: 12),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: granted
                            ? accentCyan.withOpacity(0.1)
                            : dangerRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            granted
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: iconColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.statusAccessibility.value,
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!granted) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        controller.onUserInteract();
                        controller.openAccessibilitySettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Aktifkan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // CARD: Skor Kesehatan Digital & Live Status
  // ─────────────────────────────────────────────
  Widget _buildHealthScoreCard() {
    return Obx(() {
      final String status = controller.doomscrollStatus.value;
      Color statusColor = accentCyan;
      String statusText = 'Status: Baik';

      if (status == 'Tinggi') {
        statusColor = dangerRed;
        statusText = 'Status: Bahaya';
      } else if (status == 'Sedang') {
        statusColor = warningYellow;
        statusText = 'Status: Waspada';
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                  color: statusColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5))
            ]),
        child: Column(children: [
          const Text('Skor Kesehatan Digital',
              style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text('${controller.healthScore.value}/100',
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: textDark)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text(statusText,
                style: TextStyle(
                    color: statusColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                  icon: Icons.timer_outlined,
                  label: controller.screenTime.value,
                  title: 'Screen Time'),
              _MiniStat(
                  icon: Icons.warning_amber_rounded,
                  label: controller.doomscrollStatus.value,
                  title: 'Doomscroll',
                  iconColor: statusColor),
              _MiniStat(
                  icon: Icons.remove_red_eye_outlined,
                  label: controller.eyeCondition.value,
                  title: 'Kondisi Mata',
                  iconColor: controller.eyeCondition.value == 'Lelah'
                      ? dangerRed
                      : accentCyan),
            ],
          )
        ]),
      );
    });
  }

  // ─────────────────────────────────────────────
  // METODE SISA / PENDUKUNG UI
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
              'Halo, ${controller.namaUser.value} 👋',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark),
            )),
            const Text('Siap mengelola waktumu hari ini?',
                style: TextStyle(color: textGrey, fontSize: 12)),
          ],
        ),
        GestureDetector(
          onTap: () {
            controller.onUserInteract();
            Get.toNamed(Routes.NOTIFICATION);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: cardLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: const Icon(Icons.notifications_none, color: accentCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityMonitoringStatus() {
    return Obx(() {
      final bool granted = controller.hasUsagePermission.value;
      return GestureDetector(
        onTap: () {
          controller.onUserInteract();
          if (!granted) controller.openUsageAccessSettings();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(
                color: granted
                    ? accentCyan.withOpacity(0.3)
                    : warningYellow.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                        granted
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: granted ? accentCyan : warningYellow),
                    const SizedBox(width: 8),
                    const Text('Monitoring Aktivitas',
                        style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  granted
                      ? 'Mengumpulkan data penggunaan aplikasi secara otomatis'
                      : 'Aplikasi memerlukan izin Usage Access',
                  style: const TextStyle(color: textGrey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: granted
                          ? accentCyan.withOpacity(0.1)
                          : warningYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(
                          granted
                              ? Icons.check_circle_outline
                              : Icons.touch_app,
                          color: granted ? accentCyan : warningYellow),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.statusActivityLooping.value,
                          style: TextStyle(
                              color: granted ? accentCyan : warningYellow,
                              fontWeight: FontWeight.w600),
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

  Widget _buildEyeMonitorToggle() {
    return Obx(() {
      final bool isDetecting = controller.statusLooping.value.contains('mendeteksi');

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(
                color: controller.isEyeMonitorActive.value
                    ? accentCyan
                    : Colors.transparent,
                width: 1)),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                controller.onUserInteract();
                Get.toNamed(Routes.EYE_MONITORING);
              },
              title: const Text('Eye Monitoring',
                  style: TextStyle(
                      color: textDark, fontWeight: FontWeight.bold)),
              subtitle: const Text('Mode Otomatis (Klik u/ Kalibrasi)',
                  style: TextStyle(color: textGrey, fontSize: 12)),
              trailing: Switch(
                  value: controller.isEyeMonitorActive.value,
                  activeColor: accentCyan,
                  onChanged: (value) {
                    controller.onUserInteract();
                    controller.toggleEyeMonitor(value);
                  }),
            ),
            if (controller.isEyeMonitorActive.value)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: isDetecting
                          ? dangerRed.withOpacity(0.1)
                          : accentCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(
                          isDetecting
                              ? Icons.camera_front
                              : Icons.timer,
                          color: isDetecting
                              ? dangerRed
                              : accentCyan,
                          size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'Status: ${controller.statusLooping.value}',
                              style: TextStyle(
                                  color: isDetecting
                                      ? dangerRed
                                      : accentCyan,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final Color? iconColor;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.title,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: iconColor ?? textGrey, size: 20),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(
              color: textDark, fontWeight: FontWeight.bold)),
      Text(title, style: const TextStyle(color: textGrey, fontSize: 10)),
    ]);
  }
}