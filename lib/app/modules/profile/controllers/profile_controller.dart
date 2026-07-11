import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  var userName = 'User'.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    // 🟡 Ambil data dari static variable HomeController yang sudah kita isi saat login
    final dataProfile = HomeController.dataUserLogin;
    final userAuth = supabase.auth.currentUser;

    if (userAuth != null) {
      userEmail.value = userAuth.email ?? '';
    }

    if (dataProfile != null) {
      // 🟡 Ambil nama_lengkap dari data profile database / google metadata
      final nama = dataProfile['nama_lengkap'];
      
      if (nama != null && nama.toString().isNotEmpty) {
        userName.value = nama.toString();
      } else {
        userName.value = userAuth?.email?.split('@').first ?? 'User';
      }
    } else {
      // Backup jika dataProfile belum sempat termuat
      userName.value = userAuth?.email?.split('@').first ?? 'User';
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    HomeController.dataUserLogin = null;
    Get.offAllNamed(Routes.LOGIN);
  }
}