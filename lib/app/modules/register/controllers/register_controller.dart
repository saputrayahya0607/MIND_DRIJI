import 'package:get/get.dart';

class RegisterController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordView() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void register() {
    // Logika pendaftaran akun nanti di sini
    print("Proses pendaftaran akun...");
    // Setelah sukses, bisa arahkan kembali ke Login atau langsung ke Dashboard
  }

  void goToLogin() {
    Get.back(); // Karena kita dari login, cukup 'back' untuk kembali
  }
}