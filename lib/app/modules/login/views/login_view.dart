import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA); 
const Color cardLight = Color(0xFFFFFFFF); 
const Color textDark = Color(0xFF2D3142); 
const Color textGrey = Color(0xFF9094A6); 
const Color accentCyan = Color(0xFF00BFA5); 

// Tetap gunakan GetView sesuai standar GetX arsitektur kamu
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛠️ JARING PENGAMAN GETX: 
    // Jika LoginController terlanjur terhapus oleh 'Get.offAllNamed', 
    // baris ini akan otomatis melahirkan controller baru yang fresh, anti-disposed!
    final loginCtrl = Get.isRegistered<LoginController>() 
        ? Get.find<LoginController>() 
        : Get.put(LoginController());

    return Scaffold(
      backgroundColor: bgLight, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: cardLight, 
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5), 
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Header
                Image.asset(
                  'assets/images/Logo Mind Driji.png',
                  width: 120,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selamat Datang di\nMIND DRIJI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark, 
                  ),
                ),
                const SizedBox(height: 32),

                // Form Email
                TextField(
                  controller: loginCtrl.emailController, // Menggunakan jaring pengaman loginCtrl
                  style: const TextStyle(color: textDark), 
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.email_outlined, color: textGrey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: textGrey.withValues(alpha: 0.5)),
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
                  controller: loginCtrl.passwordController, // Menggunakan jaring pengaman loginCtrl
                  obscureText: loginCtrl.isPasswordHidden.value,
                  style: const TextStyle(color: textDark), 
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginCtrl.isPasswordHidden.value 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        color: textGrey,
                      ),
                      onPressed: loginCtrl.togglePasswordView,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: textGrey.withValues(alpha: 0.5)),
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
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: accentCyan.withValues(alpha: 0.3), 
                    ),
                    onPressed: loginCtrl.isLoading.value ? null : () => loginCtrl.login(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: loginCtrl.isLoading.value ? 0.3 : 1.0,
                          child: const Text(
                            'Masuk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (loginCtrl.isLoading.value)
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                      ],
                    ),
                  )),
                ),
                const SizedBox(height: 16),

                // Tombol Google
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: textGrey.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: loginCtrl.loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 30, color: textDark), 
                    label: const Text(
                      'Lanjutkan dengan Google',
                      style: TextStyle(color: textDark), 
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
                      onTap: loginCtrl.goToRegister,
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