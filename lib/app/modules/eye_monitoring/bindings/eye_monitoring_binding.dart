import 'package:get/get.dart';
import '../controllers/eye_monitoring_controller.dart';

class EyeMonitoringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EyeMonitoringController>(() => EyeMonitoringController());
  }
}