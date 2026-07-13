import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../home/controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  final supabase = Supabase.instance.client;

  final String baseUrl =
      "https://minddrijiapp.my.id";

  void togglePasswordView() {
    isPasswordHidden.value =
        !isPasswordHidden.value;
  }

  // 🟡 TAMBAHKAN FUNGSI INI UNTUK AUTO-FILL DATA SAAT AUTO-LOGIN
  @override
  void onInit() {
    super.onInit();
    fetchProfileForAutoLogin();
  }

  Future<void> fetchProfileForAutoLogin() async {
    try {
      final currentUser = supabase.auth.currentUser;
      // Jika ternyata aplikasi di-auto login dan currentUser ada isinya
      if (currentUser != null && HomeController.dataUserLogin == null) {
        // 1. Cek dulu apakah dia login pakai Google atau Email
        final isGoogle = currentUser.appMetadata['provider'] == 'google';

        if (isGoogle) {
          // Jika user Google, langsung set datanya dari metadata
          HomeController.dataUserLogin = {
            'id': currentUser.id,
            'email': currentUser.email,
            'nama_lengkap': currentUser.userMetadata?['full_name'] ?? '',
            'no_hp': '',
            'jenis_kelamin': '',
            'tanggal_lahir': '',
          };
        } else {
          // Jika user Email, ambil datanya langsung dari tabel 'profiles' Supabase
          final profile = await supabase
              .from('profiles')
              .select()
              .eq('id', currentUser.id)
              .single();

          HomeController.dataUserLogin = profile;
        }
        print("⚡ [Auto-Login] Data profile berhasil dimuat otomatis!");
      }
    } catch (e) {
      print("❌ [Auto-Login] Gagal memuat profile otomatis: $e");
    }
  }

  // ==========================
  // LOGIN EMAIL PASSWORD
  // ==========================
  Future<void> login() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email dan Password wajib diisi!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final authResponse =
          await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final userId =
          authResponse.user?.id;

      if (userId != null) {
        final profile =
            await supabase
                .from('profiles')
                .select()
                .eq('id', userId)
                .single();

        HomeController.dataUserLogin =
            profile;

        print(
            "===== DATA PROFILE =====");
        print(profile);
        print(
            "========================");
      }
      
      // 🟡 SUNTIKKAN BARIS INI: Paksa Home update namanya setelah login email sukses!
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().updateNamaUser();
      }

      Get.snackbar(
        'Berhasil',
        'Login berhasil',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(
        const Duration(milliseconds: 1000),
      );

      Get.offAllNamed(
        Routes.DASHBOARD,
      );

      clearForm();
    } on AuthException catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // LOGIN GOOGLE
  // ==========================
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await GoogleSignIn.instance.initialize(
        serverClientId:
            '274749793163-a7i2q20ejgqs6qjr7cjtvj1ipaq0k771.apps.googleusercontent.com',
      );

      // 🟡 KEMBALI KE KODE ASLI KAMU (AMAN DARI ERROR)
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('ID Token tidak ditemukan');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = supabase.auth.currentUser;

      if (user != null) {
        // 🌟 PENTING: Pastikan row profile ada di tabel 'profiles'
        final existing = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle(); // pakai maybeSingle, bukan single, biar gak error kalau belum ada

        if (existing == null) {
          // Baru pertama kali login via Google -> buat row baru
          await supabase.from('profiles').upsert({
            'id': user.id,
            'email': user.email,
            'nama_lengkap': user.userMetadata?['full_name'] ?? '',
            'no_hp': '',
            'jenis_kelamin': '',
            'tanggal_lahir': null,
            'is_verified': true,
          });
        }
      }

      HomeController.dataUserLogin = {
        'id': user?.id,
        'email': user?.email,
        'nama_lengkap': user?.userMetadata?['full_name'] ?? '',
        'no_hp': '',
        'jenis_kelamin': '',
        'tanggal_lahir': '',
      };

      // 🔥 SUNTIKKAN BARIS INI: Agar nama langsung berubah tanpa perlu nunggu restart aplikasinya!
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().updateNamaUser();
      }

      Get.offAllNamed(
        Routes.DASHBOARD,
      );
    } catch (e) {
      Get.snackbar(
        'Google Login Gagal',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // LUPA PASSWORD
  // ==========================
  void showForgotPasswordDialog() { 
    final emailForgotController =
        TextEditingController();

    Get.defaultDialog(
      title: "Lupa Password",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller:
                emailForgotController,
            decoration:
                const InputDecoration(
              labelText: "Email",
              border:
                  OutlineInputBorder(),
            ),
          ),
        ],
      ),
      textConfirm: "Kirim OTP",
      textCancel: "Batal",
      onConfirm: () async {
        Get.back();

        await sendForgotPasswordOtp(
          emailForgotController.text
              .trim(),
        );
      },
    );
  }

  Future<void> sendForgotPasswordOtp(
      String email) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/forgot-password/send-otp',
        ),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Berhasil",
          "OTP berhasil dikirim",
        );

        showResetPasswordDialog(
          email,
        );
      } else {
        Get.snackbar(
          "Gagal",
          data['message'],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  void showResetPasswordDialog(
      String email) {
    final otpController =
        TextEditingController();

    final newPasswordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    Get.defaultDialog(
      title: "Reset Password",
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller:
                  otpController,
              decoration:
                  const InputDecoration(
                labelText: "OTP",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller:
                  newPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Password Baru",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller:
                  confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Konfirmasi Password",
              ),
            ),
          ],
        ),
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      onConfirm: () async {
        if (newPasswordController
                .text !=
            confirmPasswordController
                .text) {
          Get.snackbar(
            "Gagal",
            "Password tidak sama",
          );
          return;
        }

        Get.back();

        await resetPassword(
          email,
          otpController.text.trim(),
          newPasswordController.text,
        );
      },
    );
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/forgot-password/reset',
        ),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
        }),
      );

      final data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Berhasil",
          "Password berhasil diubah",
          backgroundColor:
              Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Gagal",
          data['message'],
          backgroundColor:
              Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  // ==========================
  // NAVIGASI
  // ==========================
  void goToRegister() {
    Get.toNamed(
      Routes.REGISTER,
    );
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
