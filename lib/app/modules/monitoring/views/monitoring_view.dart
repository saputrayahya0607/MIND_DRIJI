import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monitoring_controller.dart';

const Color bgLight       = Color(0xFFF5F7FA);
const Color cardLight     = Color(0xFFFFFFFF);
const Color textDark      = Color(0xFF2D3142);
const Color textGrey      = Color(0xFF9094A6);
const Color accentCyan    = Color(0xFF00BFA5);
const Color warningYellow = Color(0xFFFFB300);
const Color barBg         = Color(0xFFE2E8F0);

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monitoring Aktivitas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau kebiasaan digitalmu.',
              style: TextStyle(color: textGrey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            _buildFilterTabs(),
            const SizedBox(height: 32),
            _buildTotalTimeCard(),
            const SizedBox(height: 32),

            const Text(
              'Grafik Penggunaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 16),
            _buildChartSection(),

            const SizedBox(height: 32),

            // ── Judul "Aplikasi" berubah dinamis sesuai bar yang dipilih ──
            _buildAppSectionHeader(),
            const SizedBox(height: 16),
            _buildAppUsageList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  HEADER APLIKASI — dinamis sesuai bar aktif
  // ════════════════════════════════════════════════════════════

  Widget _buildAppSectionHeader() {
    return Obx(() {
      final bool isBarSelected = controller.selectedBarIndex.value >= 0;
      final String label = isBarSelected &&
              controller.selectedBarIndex.value < controller.chartLabels.length
          ? controller.chartLabels[controller.selectedBarIndex.value]
          : '';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Judul utama
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              isBarSelected
                  ? 'Aplikasi — $label'
                  : 'Aplikasi Paling Sering Dibuka',
              key: ValueKey(isBarSelected ? label : '__all__'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),

          const Spacer(),

          // Tombol reset ke "semua" (hanya muncul saat bar aktif)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isBarSelected
                ? GestureDetector(
                    key: const ValueKey('reset_btn'),
                    onTap: () => controller.onBarTap(controller.selectedBarIndex.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.apps, size: 12, color: accentCyan),
                          SizedBox(width: 4),
                          Text(
                            'Semua',
                            style: TextStyle(
                              color: accentCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no_btn')),
          ),
        ],
      );
    });
  }

  // ════════════════════════════════════════════════════════════
  //  GRAFIK SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      'Rata-rata: ${controller.averageTime.value}',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const Icon(Icons.insights, color: accentCyan, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                height: 178,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentCyan),
                  ),
                ),
              );
            }

            if (controller.chartData.isEmpty) {
              return const SizedBox(
                height: 178,
                child: Center(
                  child: Text(
                    'Tidak ada data grafik',
                    style: TextStyle(color: textGrey, fontSize: 13),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(controller.chartLabels.length, (index) {
                    final bool isToday    = index == controller.todayIndex.value;
                    final bool isSelected = index == controller.selectedBarIndex.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        // ── onBarTap sekarang async — fetch apps per periode ──
                        onTap: () async => await controller.onBarTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: _buildPremiumBar(
                          controller.chartData[index],
                          controller.chartLabels[index],
                          120,
                          isToday: isToday,
                          isSelected: isSelected,
                          timeLabel: (isSelected || isToday)
                              ? controller.chartTimeLabels[index]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  FILTER TABS
  // ════════════════════════════════════════════════════════════

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: ['Hari', 'Minggu', 'Bulan'].map((filter) {
          return Expanded(
            child: Obx(() {
              final bool isSelected = controller.selectedFilter.value == filter;
              return GestureDetector(
                onTap: () {
                  if (!controller.isLoading.value) {
                    controller.changeFilter(filter);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3399FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  BAR WIDGET
  // ════════════════════════════════════════════════════════════

  Widget _buildPremiumBar(
    double heightPercentage,
    String label,
    double maxHeight, {
    bool isToday = false,
    bool isSelected = false,
    String? timeLabel,
  }) {
    return SizedBox(
      width: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 30,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: timeLabel != null
                  ? Container(
                      key: ValueKey(timeLabel + label),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isToday ? warningYellow : accentCyan).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          timeLabel,
                          style: TextStyle(
                            color: isToday ? warningYellow : accentCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 14,
                height: maxHeight,
                decoration: BoxDecoration(
                  color: barBg,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuart,
                width: 14,
                height: (heightPercentage / 100) * maxHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: isToday
                        ? [warningYellow, warningYellow.withOpacity(0.7)]
                        : [
                            accentCyan,
                            accentCyan.withOpacity(isSelected ? 0.9 : 0.4),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 20,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (isSelected || isToday) ? textDark : textGrey,
                fontSize: 10,
                fontWeight:
                    (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TOTAL TIME CARD
  // ════════════════════════════════════════════════════════════

  Widget _buildTotalTimeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    'Total Screen Time (${controller.selectedFilter.value})',
                    style: const TextStyle(color: textGrey, fontSize: 12),
                  )),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.totalScreenTime.value,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ],
          ),
          Icon(Icons.pie_chart, size: 50, color: accentCyan.withOpacity(0.8)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  APP USAGE LIST — sinkron dengan bar yang di-tap
  // ════════════════════════════════════════════════════════════

  Widget _buildAppUsageList() {
    return Obx(() {
      final bool isBarSelected  = controller.selectedBarIndex.value >= 0;
      final bool isLoadingMain  = controller.isLoading.value;
      final bool isLoadingBar   = controller.isLoadingBarApps.value;

      // ── Loading state keseluruhan (ganti filter) ─────────────
      if (isLoadingMain) {
        return _appListSkeleton();
      }

      // ── Loading state per bar (tap bar saat data sudah ada) ──
      if (isLoadingBar) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentCyan),
                  strokeWidth: 2,
                ),
                SizedBox(height: 12),
                Text(
                  'Memuat aplikasi...',
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }

      // ── Pilih data: per-bar atau keseluruhan ─────────────────
      final List<Map<String, dynamic>> displayApps =
          isBarSelected ? controller.selectedBarApps : controller.appUsageData;

      // ── Empty state ──────────────────────────────────────────
      if (displayApps.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone_android_outlined,
                  size: 36, color: textGrey.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(
                isBarSelected
                    ? 'Tidak ada data untuk periode ini'
                    : 'Tidak ada riwayat aplikasi',
                style: const TextStyle(color: textGrey, fontSize: 13),
              ),
            ],
          ),
        );
      }

      // ── List normal ──────────────────────────────────────────
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(isBarSelected
              ? 'bar_${controller.selectedBarIndex.value}'
              : 'all'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: displayApps.map((app) {
              final Color barColor = _colorFromName(app['color'] as String? ?? 'purple');
              return _buildAppUsageItem(
                app['name']     as String,
                app['time']     as String,
                (app['progress'] as double).clamp(0.0, 1.0),
                barColor,
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildAppUsageItem(
    String appName,
    String time,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  appName,
                  style: const TextStyle(
                      color: textDark, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: barBg,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            LayoutBuilder(builder: (context, constraints) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: 8,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ]),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════

  /// Skeleton placeholder saat loading pertama
  Widget _appListSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: List.generate(4, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 120, height: 14),
                    _shimmerBox(width: 50, height: 14),
                  ],
                ),
                const SizedBox(height: 10),
                _shimmerBox(width: double.infinity, height: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Color _colorFromName(String colorName) {
    switch (colorName) {
      case 'blue':   return Colors.blueAccent;
      case 'green':  return accentCyan;
      case 'orange': return Colors.orangeAccent;
      case 'red':    return Colors.redAccent;
      default:       return Colors.purpleAccent;
    }
  }
}