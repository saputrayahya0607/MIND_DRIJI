import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background diubah menjadi full putih
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo Mind Driji.png',
              width: 220, // Gambar logo diperbesar sedikit (sebelumnya 180)
            ),
            
            // Jarak antara logo dan loading indicator
            const SizedBox(height: 40), 

            const CircularProgressIndicator(
              color: Color(0xFF1DE9B6),
            ),
          ],
        ),
      ),
    );
  }
}