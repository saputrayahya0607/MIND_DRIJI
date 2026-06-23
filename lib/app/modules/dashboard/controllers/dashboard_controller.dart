import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Hanya fokus mengurus Index Bottom Navigation
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}