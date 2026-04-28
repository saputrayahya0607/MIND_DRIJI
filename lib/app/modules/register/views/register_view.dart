import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

final nameC = TextEditingController();
final emailC = TextEditingController();
final passC = TextEditingController();
final confirmPassC = TextEditingController();

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2747),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white12,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                // 🔵 TITLE
                const Text(
                  "Buat Akun",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Mulai hidup digital yang lebih sehat",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 25),

                // 🔵 NAMA
                _buildInput(
                  hint: "Nama Lengkap",
                  icon: Icons.person,
                  controller: nameC,
                ),

                const SizedBox(height: 16),

                // 🔵 EMAIL
                _buildInput(
                  hint: "Email",
                  icon: Icons.email,
                  controller: emailC,
                ),

                const SizedBox(height: 16),

                // 🔵 PASSWORD
                _buildInput(
                  hint: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: passC,
                ),

                const SizedBox(height: 16),

                // 🔵 KONFIRMASI PASSWORD
                _buildInput(
                  hint: "Konfirmasi Password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: confirmPassC,
                ),

                const SizedBox(height: 20),

                // 🔵 BUTTON REGISTER
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7EE8FA),
                        Color(0xFF80FFDB),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                        controller.name.value = nameC.text;
                        controller.email.value = emailC.text;
                        controller.password.value = passC.text;
                        controller.confirmPassword.value = confirmPassC.text;

                        controller.register();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Daftar →",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 LOGIN LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: Color(0xFF80FFDB),
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

  // 🔧 WIDGET INPUT
  Widget _buildInput({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}