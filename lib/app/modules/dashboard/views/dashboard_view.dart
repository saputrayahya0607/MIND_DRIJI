import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

// Import semua view modul
import '../../home/views/home_view.dart';
import '../../monitoring/views/monitoring_view.dart';
import '../../insight/views/insight_view.dart';
import '../../profile/views/profile_view.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color accentCyan = Color(0xFF00BFA5);
const Color textGrey = Color(0xFF9094A6);

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight, // Background utama diubah ke terang
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Bayangan halus di atas navbar
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Obx(() => BottomNavigationBar(
          backgroundColor: cardLight, // Navbar menjadi putih
          type: BottomNavigationBarType.fixed,
          elevation: 0, // Dihilangkan karena sudah pakai boxShadow di Container
          selectedItemColor: accentCyan,
          unselectedItemColor: textGrey, // Ikon tidak aktif menjadi abu-abu
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Monitoring'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: 'Insight'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        )),
      ),
    );
  }
}