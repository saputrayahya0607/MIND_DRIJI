import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  // Controller untuk Teks
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State untuk Password Hide/Show
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  // State untuk Dropdown & DatePicker
  var jenisKelamin = 'Laki-laki'.obs;
  var tanggalLahir = DateTime(2000, 1, 1).obs; // Default tahun 2000

  void togglePasswordView() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordView() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  // Fungsi memunculkan kalender
  Future<void> pilihTanggalLahir(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggalLahir.value,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00BFA5), // Warna header kalender (Cyan)
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3142),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      tanggalLahir.value = picked;
    }
  }

  void register() {
    // FORMAT MAP UNTUK DIKIRIM KE BACKEND (FLASK)
    Map<String, dynamic> registerData = {
      'nama_lengkap': namaController.text,
      'tanggal_lahir': tanggalLahir.value.toIso8601String(),
      'jenis_kelamin': jenisKelamin.value,
      'email': emailController.text,
      'no_hp': noHpController.text,
      'password': passwordController.text,
    };

    print("DATA REGISTER SIAP DIKIRIM: $registerData");
    // Lanjutkan logika API/pindah halaman di sini...
  }

  void goToLogin() {
    Get.back(); // Atau Get.offAllNamed(Routes.LOGIN);
  }
}