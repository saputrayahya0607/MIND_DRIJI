import 'package:get/get.dart';

class EyeMonitoringController extends GetxController {
  // State tiruan untuk UI Kamera
  var isCameraOn = true.obs;
  
  // Data hasil deteksi (bisa diubah-ubah nanti untuk demo)
  var eyeCondition = 'Lelah'.obs;
  var blinkRate = 'Rendah (12x/mnt)'.obs;
  var focusDuration = '45 Menit'.obs;
  var statusSaran = 'Istirahat Disarankan!'.obs;

  void toggleCamera(bool value) {
    isCameraOn.value = value;
  }
}