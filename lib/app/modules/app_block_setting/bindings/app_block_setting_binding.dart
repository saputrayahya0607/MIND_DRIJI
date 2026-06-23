import 'package:get/get.dart';

import '../controllers/app_block_setting_controller.dart';

class AppBlockSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppBlockSettingController>(
      () => AppBlockSettingController(),
    );
  }
}
