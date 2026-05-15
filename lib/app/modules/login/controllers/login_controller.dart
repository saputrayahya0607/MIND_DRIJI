import 'package:get/get.dart';
// Sesuaikan import rute dengan struktur Anda
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // Obscure password toggle
  var isPasswordHidden = true.obs;

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    // Nanti di sini logika autentikasi
    // Setelah sukses, langsung arahkan ke Dashboard dan hapus history
    Get.offAllNamed(Routes.DASHBOARD);
    print("Login diproses, menuju Dashboard...");
  }

  void loginWithGoogle() {
    print("Login dengan Google...");
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
    print("Menuju halaman Register...");
  }
}