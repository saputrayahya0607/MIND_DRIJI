import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

// Import semua view modul
import '../../home/views/home_view.dart';
import '../../monitoring/views/monitoring_view.dart';
import '../../insight/views/insight_view.dart';
import '../../profile/views/profile_view.dart';

const Color bgDark = Color(0xFF0A0E21);
const Color cardDark = Color(0xFF1D1E33);
const Color accentCyan = Color(0xFF1DE9B6);

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Obx(() {
          // Navigasi Super Bersih!
          switch (controller.tabIndex.value) {
            case 0: return const HomeView();
            case 1: return const MonitoringView();
            case 2: return const InsightView();
            case 3: return const ProfileView();
            default: return const HomeView();
          }
        }),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        backgroundColor: cardDark,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: accentCyan,
        unselectedItemColor: Colors.grey,
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Monitoring'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: 'Insight'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      )),
    );
  }
}