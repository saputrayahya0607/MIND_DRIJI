import 'package:get/get.dart';
// ➡️ 1. IMPORT HomeController UNTUK MENGAMBIL DATA GLOBAL
import '../../home/controllers/home_controller.dart'; 

class ProfileController extends GetxController {
  // ➡️ 2. BUAT STATE REAKTIF UNTUK NAMA & EMAIL (Sediakan default fallback)
  var userName = 'User'.obs;
  var userEmail = 'user@driji.ai'.obs;

  @override
  void onInit() {
    super.onInit();
    
    // ➡️ 3. BACA DATA DARI WADAH STATIS LOGIN
    if (HomeController.dataUserLogin != null) {
      if (HomeController.dataUserLogin!['nama_lengkap'] != null) {
        userName.value = HomeController.dataUserLogin!['nama_lengkap'];
      }
      if (HomeController.dataUserLogin!['email'] != null) {
        userEmail.value = HomeController.dataUserLogin!['email'];
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}