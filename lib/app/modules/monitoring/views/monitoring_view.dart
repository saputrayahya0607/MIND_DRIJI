import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monitoring_controller.dart';

const Color cardDark = Color(0xFF1D1E33);
const Color accentCyan = Color(0xFF1DE9B6);
const Color warningYellow = Color(0xFFFFD600);
const Color bgDark = Color(0xFF0A0E21);

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          const Text('Monitoring Aktivitas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Pantau kebiasaan digitalmu.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),

          // 2. SEGMENTED CONTROL (Hari | Minggu | Bulan)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardDark, 
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: ['Hari', 'Minggu', 'Bulan'].map((String filter) {
                return Expanded(
                  child: Obx(() {
                    bool isSelected = controller.selectedFilter.value == filter;
                    return GestureDetector(
                      onTap: () => controller.changeFilter(filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          // Warna biru cerah persis seperti referensi
                          color: isSelected ? const Color(0xFF3399FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
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
          ),
          const SizedBox(height: 32),

          // 3. CARD TOTAL SCREEN TIME (Reaktif)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardDark, 
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: accentCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text('Total Screen Time (${controller.selectedFilter.value})', style: const TextStyle(color: Colors.grey, fontSize: 12))),
                    const SizedBox(height: 8),
                    Obx(() => Text(controller.totalScreenTime.value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                  ],
                ),
                Icon(Icons.pie_chart_outline, size: 50, color: accentCyan.withOpacity(0.8)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 4. GRAFIK HARIAN (Reaktif)
          const Text('Grafik Penggunaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text('Rata-rata: ${controller.averageTime.value}', style: const TextStyle(color: Colors.grey, fontSize: 12))),
                    const Icon(Icons.insights, color: accentCyan, size: 16),
                  ],
                ),
                const SizedBox(height: 32),
                Obx(() {
                  // Daftar hari
                  List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      return _buildPremiumBar(
                        controller.chartData[index], 
                        days[index], 
                        120, // max height untuk bar
                        isToday: index == controller.todayIndex.value, 
                        timeLabel: index == controller.todayIndex.value ? controller.todayTimeLabel.value : null,
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 5. DAFTAR APLIKASI (Reaktif)
          const Text('Aplikasi Paling Sering Dibuka', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: controller.appUsageData.map((app) {
              // Menentukan warna progress bar berdasarkan string data
              Color barColor = Colors.purpleAccent;
              if (app['color'] == 'blue') barColor = Colors.blueAccent;
              if (app['color'] == 'green') barColor = Colors.greenAccent;
              if (app['color'] == 'red') barColor = const Color(0xFFFF5252);

              return _buildAppUsageItem(
                app['name'] as String, 
                app['time'] as String, 
                app['progress'] as double, 
                barColor
              );
            }).toList(),
          )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET HELPERS
  // ==========================================
  
  Widget _buildPremiumBar(double heightPercentage, String day, double maxHeight, {bool isToday = false, String? timeLabel}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (timeLabel != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(color: warningYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Text(timeLabel, style: const TextStyle(color: warningYellow, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Jalur background
            Container(width: 14, height: maxHeight, decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10))),
            // Bar utama dengan animasi
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              width: 14,
              height: (heightPercentage / 100) * maxHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: isToday ? [warningYellow.withOpacity(0.6), warningYellow] : [accentCyan.withOpacity(0.2), accentCyan],
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                ),
                boxShadow: isToday ? [BoxShadow(color: warningYellow.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(day, style: TextStyle(color: isToday ? Colors.white : Colors.grey, fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildAppUsageItem(String appName, String time, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(appName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)), Text(time, style: const TextStyle(color: Colors.grey))],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8, width: double.infinity,
            decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: AnimatedContainer( 
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}