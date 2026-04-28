import 'package:get/get.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;

  void login() {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Email dan Password wajib diisi");
      return;
    }

    if (!GetUtils.isEmail(email.value)) {
      Get.snackbar("Error", "Format email tidak valid");
      return;
    }

    if (password.value.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter");
      return;
    }

    // 🔥 PINDAH KE DASHBOARD
    Get.offAllNamed('/dashboard');
  }
}