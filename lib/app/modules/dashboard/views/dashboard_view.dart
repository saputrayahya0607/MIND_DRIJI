import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),

      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF0F2747),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selamat Datang 👋",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Kamu berhasil login ke MindGuard",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Get.offAllNamed('/login');
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}