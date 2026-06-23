import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: textDark.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentCyan.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: accentCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Silakan lengkapi data diri Anda di bawah ini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- FORM SECTION ---
                  _buildTextField(
                    controller.namaController,
                    'Nama Lengkap',
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller.emailController,
                    'Email',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // --- OTP SECTION ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.sendOtp,
                        icon: const Icon(Icons.mark_email_read_rounded),
                        label: Text(
                          controller.otpSent.value
                              ? 'Kirim Ulang OTP'
                              : 'Kirim OTP ke Email',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentCyan.withValues(alpha: 0.1),
                          foregroundColor: accentCyan,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Obx(
                    () => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: controller.otpSent.value
                          ? Column(
                              children: [
                                _buildTextField(
                                  controller.otpController,
                                  'Masukkan Kode OTP',
                                  Icons.security_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: controller.verifyOtp,
                                    icon: Icon(
                                      controller.otpVerified.value
                                          ? Icons.verified_rounded
                                          : Icons.shield_outlined,
                                    ),
                                    label: Text(
                                      controller.otpVerified.value
                                          ? 'OTP Terverifikasi'
                                          : 'Verifikasi OTP',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: controller.otpVerified.value
                                          ? Colors.green
                                          : Colors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox(),
                    ),
                  ),

                  _buildTextField(
                    controller.noHpController,
                    'Nomor WhatsApp / HP',
                    Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // --- ROW: GENDER & TANGGAL LAHIR (BERSEBELAHAN) ---
                  Row(
                    children: [
                      // Kolom 1: Jenis Kelamin
                      Expanded(
                        child: Container(
                          height: 56, // Tinggi disamakan dengan Date Picker
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: bgLight, 
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Obx(
                            () => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.jenisKelamin.value,
                                isExpanded: true,
                                dropdownColor: Colors.white, // Menu dropdown jadi putih saat ditekan
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textGrey),
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 14, // Dikecilkan sedikit agar muat sejajar
                                ),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    controller.jenisKelamin.value = value;
                                  }
                                },
                                items: ['Laki-laki', 'Perempuan']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12), // Jarak antara Gender dan Tanggal Lahir
                      
                      // Kolom 2: Tanggal Lahir
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => controller.pilihTanggalLahir(context),
                          child: Container(
                            height: 56, // Tinggi disamakan dengan Dropdown
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: bgLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded, 
                                  color: textGrey,
                                  size: 20, // Icon disesuaikan sedikit
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Obx(
                                    () => Text(
                                      "${controller.tanggalLahir.value.day}/${controller.tanggalLahir.value.month}/${controller.tanggalLahir.value.year}",
                                      style: const TextStyle(
                                        color: textDark,
                                        fontSize: 14, // Dikecilkan sedikit agar muat sejajar
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- PASSWORD SECTION ---
                  Obx(
                    () => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.isPasswordHidden.value,
                      style: const TextStyle(color: textDark, fontSize: 15),
                      decoration: _getInputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: textGrey,
                          ),
                          onPressed: controller.togglePasswordView,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Obx(
                    () => TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.isConfirmPasswordHidden.value,
                      style: const TextStyle(color: textDark, fontSize: 15),
                      decoration: _getInputDecoration(
                        label: 'Konfirmasi Password',
                        icon: Icons.lock_reset_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordHidden.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: textGrey,
                          ),
                          onPressed: controller.toggleConfirmPasswordView,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // --- SUBMIT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value ||
                                !controller.otpVerified.value
                            ? null
                            : controller.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentCyan,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: accentCyan.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                controller.otpVerified.value
                                    ? 'Daftar Sekarang'
                                    : 'Verifikasi OTP Dulu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BOTTOM LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: textGrey),
                      ),
                      GestureDetector(
                        onTap: controller.goToLogin,
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: accentCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: textDark, fontSize: 15),
      decoration: _getInputDecoration(label: label, icon: icon),
    );
  }

  // Helper Dekorasi Input
  InputDecoration _getInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textGrey),
      floatingLabelStyle: const TextStyle(color: accentCyan, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: textGrey),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: bgLight, 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, 
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentCyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
}