import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
// import '../../../core/theme/app_colors.dart'; // Aktifkan jika pakai app_colors.dart

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA); 
const Color cardLight = Color(0xFFFFFFFF); 
const Color textDark = Color(0xFF2D3142); 
const Color textGrey = Color(0xFF9094A6); 
const Color accentCyan = Color(0xFF00BFA5); 

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight, // Diubah ke warna latar terang
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: cardLight, // Diubah ke warna card putih
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), // Bayangan hitam halus untuk tema terang
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Header
                const Icon(
                  Icons.shield_outlined,
                  size: 60,
                  color: accentCyan,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selamat Datang di\nMIND DRIJI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark, // Teks diubah ke gelap
                  ),
                ),
                const SizedBox(height: 32),

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
                
                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(color: textGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Masuk
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      foregroundColor: Colors.white, // Teks tombol login jadi putih
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: accentCyan.withOpacity(0.3), // Glow tipis warna cyan
                    ),
                    onPressed: controller.login,
                    child: const Text(
                      'Masuk',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Google
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: textGrey.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: controller.loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 30, color: textDark), // Ikon google diubah ke gelap
                    label: const Text(
                      'Lanjutkan dengan Google',
                      style: TextStyle(color: textDark), // Teks google diubah ke gelap
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Link Daftar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? ', style: TextStyle(color: textGrey)),
                    GestureDetector(
                      onTap: controller.goToRegister,
                      child: const Text(
                        'Daftar',
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