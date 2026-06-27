import 'package:get/get.dart';
import 'package:mind_driji/app/modules/home/controllers/home_controller.dart';
import 'package:mind_driji/app/modules/monitoring/controllers/monitoring_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inject kedua controller secara permanen sejak aplikasi pertama kali dibuka
    Get.put(MonitoringController(), permanent: true);
    Get.put(HomeController(), permanent: true);
  }
}