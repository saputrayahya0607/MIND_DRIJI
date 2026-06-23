import 'package:get/get.dart';

class MonitoringController extends GetxController {
  var selectedFilter = 'Minggu'.obs;
  var totalScreenTime = '35j 10m'.obs;
  var averageTime = '4j 15m'.obs;

  var chartData = <double>[40, 65, 95, 30, 50, 80, 75].obs;
  var chartLabels = <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].obs;
  var chartTimeLabels = <String>['2j 10m', '3j 45m', '5j 20m', '1j 30m', '2j 50m', '4j 15m', '4j 00m'].obs;
  
  var todayIndex = 2.obs; 
  var selectedBarIndex = (-1).obs;

  var appUsageData = [
    {'name': 'Instagram', 'time': '2j 15m', 'progress': 0.7, 'color': 'purple'},
    {'name': 'TikTok', 'time': '1j 45m', 'progress': 0.5, 'color': 'blue'},
    {'name': 'WhatsApp', 'time': '45m', 'progress': 0.3, 'color': 'green'},
  ].obs;

  void changeFilter(String newFilter) {
    selectedFilter.value = newFilter;
    selectedBarIndex.value = -1;

    if (newFilter == 'Hari') {
      totalScreenTime.value = '5j 20m';
      averageTime.value = '1j 20m/sesi';
      // Hanya 4 data
      chartData.value = [30, 85, 60, 45];
      chartLabels.value = ['Pagi', 'Siang', 'Sore', 'Malam'];
      chartTimeLabels.value = ['1j 10m', '2j 30m', '1j 20m', '1j 00m'];
      todayIndex.value = 1; 
    } 
    else if (newFilter == 'Bulan') {
      totalScreenTime.value = '120j 45m';
      averageTime.value = '30j 11m/minggu';
      // Hanya 4 data
      chartData.value = [75, 90, 60, 85];
      chartLabels.value = ['Mng 1', 'Mng 2', 'Mng 3', 'Mng 4'];
      chartTimeLabels.value = ['28j', '35j', '22j', '32j'];
      todayIndex.value = 3; 
    } 
    else {
      // 7 data
      totalScreenTime.value = '35j 10m';
      averageTime.value = '4j 15m/hari';
      chartData.value = [40, 65, 95, 30, 50, 80, 75];
      chartLabels.value = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      chartTimeLabels.value = ['2j 10m', '3j 45m', '5j 20m', '1j 30m', '2j 50m', '4j 15m', '4j 00m'];
      todayIndex.value = 2;
    }
  }

  void onBarTap(int index) {
    selectedBarIndex.value = (selectedBarIndex.value == index) ? -1 : index;
  }
}