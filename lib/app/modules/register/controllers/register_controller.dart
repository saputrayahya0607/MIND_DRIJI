import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

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
  var tanggalLahir = DateTime(2000, 1, 1).obs; 

  // State isLoading untuk efek loading di tombol UI
  var isLoading = false.obs;

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
              primary: Color(0xFF00BFA5), 
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

  // Fungsi Register untuk menangani API Request
  Future<void> register() async {
    // Validasi input dasar
    if (namaController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Gagal', 'Nama, Email, dan Password wajib diisi!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Validasi kecocokan password
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Gagal', 'Password dan Konfirmasi Password tidak cocok!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true; // Aktifkan loading animasi di UI

    try {
      // Ubah tanggal lahir ke format YYYY-MM-DD agar sesuai database
      String formattedDate = "${tanggalLahir.value.toLocal()}".split(' ')[0];

      // Alamat endpoint backend Flask
      final url = Uri.parse('http://192.168.0.103:5000/api/register');

      // Format map data ke Flask
      Map<String, dynamic> registerData = {
        'nama_lengkap': namaController.text, 
        'tanggal_lahir': formattedDate,
        'jenis_kelamin': jenisKelamin.value,
        'email': emailController.text,
        'no_hp': noHpController.text.isEmpty ? '-' : noHpController.text,
        'password': passwordController.text,
      };

      print("MENGIRIM DATA KE BACKEND: $registerData");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 'success') {
        // 1. Tampilkan Pop-up Sukses di atas layar
        Get.snackbar(
          'Registrasi Berhasil', 
          'Selamat! Akun kamu sudah sukses terdaftar.',
          snackPosition: SnackPosition.TOP, 
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
        
        // 2. Beri jeda 1.5 detik biar user sempat baca pop-up nya
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // 3. 🛠️ FIX: Bersihkan form DULUAN sebelum halaman dihancurkan dari memori
        clearForm();
        
        // 4. 🚀 BARU PINDAH HALAMAN (Mereset total stack navigasi ke login)
        goToLogin(); 
      } else {
        Get.snackbar('Gagal', responseData['message'] ?? 'Terjadi kesalahan sistem.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.snackbar('Error', 'Tidak bisa terhubung ke backend Flask: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // Matikan loading animasi
    }
  }

  void clearForm() {
    namaController.clear();
    emailController.clear();
    noHpController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    jenisKelamin.value = 'Laki-laki';
    tanggalLahir.value = DateTime(2000, 1, 1);
  }

  void goToLogin() {
    // Memaksa balik ke rute login secara absolut dan bersih
    Get.offAllNamed('/login'); 
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}