import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA); 
const Color cardLight = Color(0xFFFFFFFF); 
const Color textDark = Color(0xFF2D3142); 
const Color textGrey = Color(0xFF9094A6); 
const Color accentCyan = Color(0xFF00BFA5); 

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight, // Background diubah ke terang
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: cardLight, // Warna card diubah ke putih
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Bayangan hitam lembut
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_outlined,
                  size: 60,
                  color: accentCyan,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark, // Teks diubah ke gelap
                  ),
                ),
                const SizedBox(height: 32),

                // Form Nama Lengkap
                TextField(
                  style: const TextStyle(color: textDark), // Teks inputan diubah ke gelap
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.person_outline, color: textGrey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: textGrey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: accentCyan),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Email
                TextField(
                  style: const TextStyle(color: textDark), // Teks inputan diubah ke gelap
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.email_outlined, color: textGrey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: textGrey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: accentCyan),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Password
                Obx(() => TextField(
                  obscureText: controller.isPasswordHidden.value,
                  style: const TextStyle(color: textDark), // Teks inputan diubah ke gelap
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        color: textGrey,
                      ),
                      onPressed: controller.togglePasswordView,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: textGrey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: accentCyan),
                    ),
                  ),
                )),
                const SizedBox(height: 16),

                // Form Konfirmasi Password
                Obx(() => TextField(
                  obscureText: controller.isConfirmPasswordHidden.value,
                  style: const TextStyle(color: textDark), // Teks inputan diubah ke gelap
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: textGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden.value 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        color: textGrey,
                      ),
                      onPressed: controller.toggleConfirmPasswordView,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: textGrey.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: accentCyan),
                    ),
                  ),
                )),
                const SizedBox(height: 32),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      foregroundColor: Colors.white, // Teks tombol diubah ke putih
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: accentCyan.withOpacity(0.3), // Efek glow tombol
                    ),
                    onPressed: controller.register,
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Link Masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ', style: TextStyle(color: textGrey)),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: accentCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}