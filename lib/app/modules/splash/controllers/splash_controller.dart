import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    checkSession();
  }

  Future<void> checkSession() async {
    print("SPLASH START");

    await Future.delayed(
      const Duration(seconds: 2),
    );

    print("PINDAH KE LOGIN");

    Get.offAllNamed(
      Routes.LOGIN,
    );
  }
}