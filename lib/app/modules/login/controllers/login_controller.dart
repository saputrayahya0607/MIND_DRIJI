import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  final supabase = Supabase.instance.client;

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
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

      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Get.snackbar(
        'Berhasil',
        'Login berhasil',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(
        const Duration(milliseconds: 1000),
      );

      Get.offAllNamed(Routes.DASHBOARD);

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
  // LOGIN GOOGLE POPUP ANDROID
  // ==========================
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await GoogleSignIn.instance.initialize(
        serverClientId:
            '274749793163-a7i2q20ejgqs6qjr7cjtvj1ipaq0k771.apps.googleusercontent.com',
      );

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

      Get.offAllNamed(Routes.DASHBOARD);
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

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
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