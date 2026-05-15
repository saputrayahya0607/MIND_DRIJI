import 'package:get/get.dart';

class MonitoringController extends GetxController {
  // Default ke Minggu
  var selectedFilter = 'Minggu'.obs; 

  var totalScreenTime = '35j 10m'.obs;
  var averageTime = '4j 15m'.obs;
  var chartData = <double>[40, 65, 95, 30, 50, 80, 75].obs;
  var todayIndex = 2.obs; 
  var todayTimeLabel = '5j 20m'.obs;

  var appUsageData = [
    {'name': 'Instagram', 'time': '2j 15m', 'progress': 0.7, 'color': 'purple'},
    {'name': 'TikTok', 'time': '1j 45m', 'progress': 0.5, 'color': 'blue'},
    {'name': 'WhatsApp', 'time': '45m', 'progress': 0.3, 'color': 'green'},
  ].obs;

  void changeFilter(String newFilter) {
    selectedFilter.value = newFilter;
    
    // Simulasi perubahan data berdasarkan tab yang diklik
    if (newFilter == 'Hari') {
      totalScreenTime.value = '5j 20m';
      averageTime.value = '5j 20m';
      chartData.value = [0, 0, 95, 0, 0, 0, 0]; // Cuma hari ini yang menonjol
      todayIndex.value = 2;
      todayTimeLabel.value = '5j 20m';
    } else if (newFilter == 'Bulan') {
      totalScreenTime.value = '120j 45m';
      averageTime.value = '4j 01m';
      chartData.value = [60, 70, 85, 90, 65, 100, 80];
      todayIndex.value = 5;
      todayTimeLabel.value = '6j 10m';
    } else {
      // Data Minggu
      totalScreenTime.value = '35j 10m';
      averageTime.value = '4j 15m';
      chartData.value = [40, 65, 95, 30, 50, 80, 75];
      todayIndex.value = 2;
      todayTimeLabel.value = '5j 20m';
    }
  }
}