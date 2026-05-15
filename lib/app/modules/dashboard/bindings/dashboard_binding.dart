import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../monitoring/controllers/monitoring_controller.dart';
import '../../insight/controllers/insight_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MonitoringController>(() => MonitoringController());
    Get.lazyPut<InsightController>(() => InsightController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}