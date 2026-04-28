import 'package:get/get.dart';

class RegisterController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  void register() {
    if (name.value.isEmpty ||
        email.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar("Error", "Semua field wajib diisi");
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

    if (password.value != confirmPassword.value) {
      Get.snackbar("Error", "Password tidak sama");
      return;
    }

    // 🔥 Kalau lolos semua
    Get.snackbar("Sukses", "Registrasi berhasil (dummy)");
  }
}