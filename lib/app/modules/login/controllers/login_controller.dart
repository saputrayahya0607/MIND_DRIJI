import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import '../../../routes/app_pages.dart';
import 'package:flutter_application_1/app/modules/home/controllers/home_controller.dart'; 

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Gagal', 
        'Email dan Password wajib diisi!',
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.orange, 
        colorText: Colors.white
      );
      return;
    }

    isLoading.value = true; 

    try {
      final url = Uri.parse('http://192.168.0.101:5000/api/login');

      Map<String, dynamic> loginData = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      };

      print("MENCOBA LOGIN: $loginData");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Get.snackbar(
          'Login Sukses', 
          responseData['message'] ?? 'Selamat datang kembali!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );

        // Menyimpan data objek 'user' dari Flask ke variabel statis HomeController
        HomeController.dataUserLogin = responseData['user']; 

        await Future.delayed(const Duration(milliseconds: 1500));

        Get.offAllNamed(Routes.DASHBOARD);
        print("Menuju Dashboard...");

        clearForm();
      } else {
        Get.snackbar(
          'Login Gagal', 
          responseData['message'] ?? 'Email atau password salah.',
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white
        );
      }

    } catch (e) {
      Get.snackbar(
        'Error', 
        'Tidak bisa terhubung ke backend Flask: $e',
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false; 
    }
  }

  void loginWithGoogle() {
    print("Login dengan Google...");
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
    print("Menuju halaman Register...");
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