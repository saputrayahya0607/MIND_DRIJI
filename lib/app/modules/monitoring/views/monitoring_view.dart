import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monitoring_controller.dart';

const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3142);
const Color textGrey = Color(0xFF9094A6);
const Color accentCyan = Color(0xFF00BFA5);
const Color warningYellow = Color(0xFFFFB300);
const Color barBg = Color(0xFFE2E8F0);

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monitoring Aktivitas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 4),
            const Text('Pantau kebiasaan digitalmu.', style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 24),

            _buildFilterTabs(),
            const SizedBox(height: 32),
            _buildTotalTimeCard(),
            const SizedBox(height: 32),

            const Text('Grafik Penggunaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            _buildChartSection(), // SEKSI GRAFIK
            
            const SizedBox(height: 32),
            const Text('Aplikasi Paling Sering Dibuka', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            _buildAppUsageList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- GRAFIK SECTION (DIBUAT CENTER) ---
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text('Rata-rata: ${controller.averageTime.value}', style: const TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                const Icon(Icons.insights, color: accentCyan, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // ROW GRAFIK DINAMIS & CENTER
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center, // Kunci agar bar di tengah
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(controller.chartLabels.length, (index) {
              bool isToday = index == controller.todayIndex.value;
              bool isSelected = index == controller.selectedBarIndex.value;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4), // Jarak antar bar
                child: GestureDetector(
                  onTap: () => controller.onBarTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: _buildPremiumBar(
                    controller.chartData[index], 
                    controller.chartLabels[index], 
                    120, 
                    isToday: isToday, 
                    isSelected: isSelected,
                    timeLabel: (isSelected || isToday) ? controller.chartTimeLabels[index] : null,
                  ),
                ),
              );
            }),
          )),
        ],
      ),
    );
  }

  // --- FILTER TABS ---
  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: ['Hari', 'Minggu', 'Bulan'].map((filter) {
          return Expanded(
            child: Obx(() {
              bool isSelected = controller.selectedFilter.value == filter;
              return GestureDetector(
                onTap: () => controller.changeFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3399FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : textGrey, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  // --- BAR WIDGET ---
  Widget _buildPremiumBar(double heightPercentage, String label, double maxHeight, {bool isToday = false, bool isSelected = false, String? timeLabel}) {
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
                child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation), child: child),
              ),
              child: (timeLabel != null)
                  ? Container(
                      key: ValueKey(timeLabel + label),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(color: (isToday ? warningYellow : accentCyan).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(timeLabel, style: TextStyle(color: isToday ? warningYellow : accentCyan, fontSize: 9, fontWeight: FontWeight.bold)),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(width: 14, height: maxHeight, decoration: BoxDecoration(color: barBg, borderRadius: BorderRadius.circular(10))),
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
                      : [accentCyan, accentCyan.withOpacity(isSelected ? 0.9 : 0.4)],
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
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
              style: TextStyle(color: (isSelected || isToday) ? textDark : textGrey, fontSize: 10, fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }

  // (Widget Total Card & App Usage List tetap sama seperti kode sebelumnya)
  Widget _buildTotalTimeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardLight, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Obx(() => Text('Total Screen Time (${controller.selectedFilter.value})', style: const TextStyle(color: textGrey, fontSize: 12))),
            const SizedBox(height: 8),
            Obx(() => Text(controller.totalScreenTime.value, style: const TextStyle(color: textDark, fontSize: 32, fontWeight: FontWeight.bold))),
          ]),
          Icon(Icons.pie_chart, size: 50, color: accentCyan.withOpacity(0.8)),
        ],
      ),
    );
  }

  Widget _buildAppUsageList() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardLight, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: controller.appUsageData.map((app) {
          Color barColor = app['color'] == 'blue' ? Colors.blueAccent : (app['color'] == 'green' ? accentCyan : Colors.purpleAccent);
          return _buildAppUsageItem(app['name'] as String, app['time'] as String, app['progress'] as double, barColor);
        }).toList(),
      ),
    ));
  }

  Widget _buildAppUsageItem(String appName, String time, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(appName, style: const TextStyle(color: textDark, fontWeight: FontWeight.w600)),
          Text(time, style: const TextStyle(color: textGrey, fontSize: 13, fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 10),
        Stack(children: [
          Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: barBg, borderRadius: BorderRadius.circular(10))),
          LayoutBuilder(builder: (context, constraints) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 8,
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            );
          }),
        ]),
      ]),
    );
  }
}