import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mind_driji/app/data/models/log_model.dart';
import 'package:intl/intl.dart';

class NotificationController extends GetxController {
  final box = GetStorage();
  var logList = <ActivityLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    final List<dynamic>? storedLogs = box.read<List<dynamic>>('activity_logs');
    print("🔍 [onInit NotificationController] Baca dari storage: $storedLogs");
    
    if (storedLogs != null) {
      logList.value = storedLogs.map((e) => ActivityLog.fromJson(e)).toList();
    }
    print("🔍 logList setelah load: ${logList.length} item");
  }

  void addLog(String title, String desc, String type) {
    String time = DateFormat('HH:mm').format(DateTime.now());
    logList.insert(0, ActivityLog(title: title, desc: desc, timestamp: time, type: type));
    if (logList.length > 50) logList.removeLast();
    _saveToStorage();
    print("✅ Log ditambahkan. Total logList sekarang: ${logList.length}");
    print("📦 Isi storage setelah save: ${box.read('activity_logs')}");
  }

    void _saveToStorage() {
      box.write('activity_logs', logList.map((e) => e.toJson()).toList());
    }

  void clearLogs() {
    logList.clear();
    box.remove('activity_logs');
  }
}