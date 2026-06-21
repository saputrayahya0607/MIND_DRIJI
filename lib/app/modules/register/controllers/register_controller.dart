import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
final namaController = TextEditingController();
final emailController = TextEditingController();
final noHpController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();
final otpController = TextEditingController();

var isPasswordHidden = true.obs;
var isConfirmPasswordHidden = true.obs;

var jenisKelamin = 'Laki-laki'.obs;
var tanggalLahir = DateTime(2000, 1, 1).obs;

var isLoading = false.obs;
var otpSent = false.obs;
var otpVerified = false.obs;

final supabase = Supabase.instance.client;

// GANTI DENGAN IP FLASK KAMU
final String baseUrl =
"http://10.109.50.93:5000";

void togglePasswordView() {
isPasswordHidden.value =
!isPasswordHidden.value;
}

void toggleConfirmPasswordView() {
isConfirmPasswordHidden.value =
!isConfirmPasswordHidden.value;
}

Future<void> pilihTanggalLahir(
BuildContext context) async {
final picked = await showDatePicker(
context: context,
initialDate: tanggalLahir.value,
firstDate: DateTime(1970),
lastDate: DateTime.now(),
);

if (picked != null) {
  tanggalLahir.value = picked;
}

}

// =========================
// KIRIM OTP
// =========================
Future<void> sendOtp() async {
try {
if (emailController.text.isEmpty) {
Get.snackbar(
'Gagal',
'Masukkan email terlebih dahulu',
);
return;
}

  isLoading.value = true;

  final response = await http.post(
    Uri.parse('$baseUrl/api/send-otp'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email':
          emailController.text.trim(),
    }),
  );

  final data =
      jsonDecode(response.body);

  if (response.statusCode == 200) {
    otpSent.value = true;

    Get.snackbar(
      'Berhasil',
      'OTP berhasil dikirim',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } else {
    Get.snackbar(
      'Gagal',
      data['message'],
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
} catch (e) {
  Get.snackbar(
    'Error',
    e.toString(),
  );
} finally {
  isLoading.value = false;
}

}

// =========================
// VERIFIKASI OTP
// =========================
Future<void> verifyOtp() async {
try {
isLoading.value = true;

  final response = await http.post(
    Uri.parse('$baseUrl/api/verify-otp'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email':
          emailController.text.trim(),
      'otp': otpController.text.trim(),
    }),
  );

  final data =
      jsonDecode(response.body);

  if (response.statusCode == 200) {
    otpVerified.value = true;

    Get.snackbar(
      'Berhasil',
      'OTP valid',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } else {
    Get.snackbar(
      'Gagal',
      data['message'],
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
} catch (e) {
  Get.snackbar(
    'Error',
    e.toString(),
  );
} finally {
  isLoading.value = false;
}

}

// =========================
// REGISTER SUPABASE
// =========================
Future<void> register() async {
try {
if (!otpVerified.value) {
Get.snackbar(
'Gagal',
'Verifikasi OTP terlebih dahulu',
backgroundColor: Colors.red,
colorText: Colors.white,
);
return;
}

  isLoading.value = true;

  final response =
      await supabase.auth.signUp(
    email: emailController.text.trim(),
    password: passwordController.text,
  );

  final user = response.user;

  if (user != null) {
    await supabase
        .from('profiles')
        .upsert({
      'id': user.id,
      'nama_lengkap':
          namaController.text.trim(),
      'email':
          emailController.text.trim(),
      'no_hp':
          noHpController.text.trim(),
      'jenis_kelamin':
          jenisKelamin.value,
      'tanggal_lahir':
          tanggalLahir.value
              .toIso8601String()
              .split('T')[0],
      'is_verified': true,
    });

    Get.defaultDialog(
      title: 'Berhasil',
      middleText:
          'Registrasi berhasil',
      onConfirm: () {
        Get.back();
        Get.back();
      },
    );

    clearForm();
  }
} catch (e) {
  Get.snackbar(
    'Error',
    e.toString(),
  );
} finally {
  isLoading.value = false;
}

}

void clearForm() {
namaController.clear();
emailController.clear();
noHpController.clear();
passwordController.clear();
confirmPasswordController.clear();
otpController.clear();

otpSent.value = false;
otpVerified.value = false;

}

@override
void goToLogin() {
  Get.back();
}
void onClose() {
namaController.dispose();
emailController.dispose();
noHpController.dispose();
passwordController.dispose();
confirmPasswordController.dispose();
otpController.dispose();
super.onClose();
}
}
