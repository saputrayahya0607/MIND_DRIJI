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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Center(
                  child: Icon(Icons.person_add_outlined, size: 60, color: accentCyan),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Nama Lengkap
                _buildTextField(controller.namaController, 'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 16),

                // Form Email
                _buildTextField(controller.emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // Form Nomor HP
                _buildTextField(controller.noHpController, 'Nomor WhatsApp / HP', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                // Form Jenis Kelamin (Dropdown)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: textGrey.withOpacity(0.5)),
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.jenisKelamin.value,
                      isExpanded: true,
                      style: const TextStyle(color: textDark, fontSize: 14),
                      icon: const Icon(Icons.arrow_drop_down, color: textGrey),
                      onChanged: (String? newValue) {
                        if (newValue != null) controller.jenisKelamin.value = newValue;
                      },
                      items: <String>['Laki-laki', 'Perempuan'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                    ),
                  )),
                ),
                const SizedBox(height: 16),

                // Form Tanggal Lahir (DatePicker)
                InkWell(
                  onTap: () => controller.pilihTanggalLahir(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: textGrey.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          "${controller.tanggalLahir.value.day}/${controller.tanggalLahir.value.month}/${controller.tanggalLahir.value.year}",
                          style: const TextStyle(color: textDark, fontSize: 14),
                        )),
                        const Icon(Icons.calendar_month_outlined, color: textGrey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Password
                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  style: const TextStyle(color: textDark),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: textGrey),
                      onPressed: controller.togglePasswordView,
                    ),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: textGrey.withOpacity(0.5))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentCyan)),
                  ),
                )),
                const SizedBox(height: 16),

                // Form Konfirmasi Password
                Obx(() => TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.isConfirmPasswordHidden.value,
                  style: const TextStyle(color: textDark),
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    labelStyle: const TextStyle(color: textGrey),
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: textGrey),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isConfirmPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: textGrey),
                      onPressed: controller.toggleConfirmPasswordView,
                    ),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: textGrey.withOpacity(0.5))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentCyan)),
                  ),
                )),
                const SizedBox(height: 32),

                // Tombol Daftar dengan Efek Loading di Tengah Teks (Stack)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentCyan,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      shadowColor: accentCyan.withOpacity(0.3),
                    ),
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () => controller.register(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Teks tetap ada, cuma transparan 70% saat loading biar fokus ke spinner
                        Opacity(
                          opacity: controller.isLoading.value ? 0.3 : 1.0,
                          child: const Text(
                            'Daftar Sekarang', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Loading berputar manis tepat di tengah-tengah teks
                        if (controller.isLoading.value)
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
                const SizedBox(height: 24),

                // Link Masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ', style: TextStyle(color: textGrey)),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: const Text('Masuk', style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold)),
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

  // Widget Bantuan untuk merapikan Textfield yang berulang
  Widget _buildTextField(TextEditingController textController, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: textController,
      keyboardType: keyboardType,
      style: const TextStyle(color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textGrey),
        prefixIcon: Icon(icon, color: textGrey),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: textGrey.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentCyan)),
      ),
    );
  }
}