import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';                  
import '../../home/controllers/home_controller.dart';

class InsightController extends GetxController {
  late HomeController _homeController;

  // ── 🟡 STATE MANAGEMENT LIVE ARTIKEL SCRAPPING (NGROK) ──
  // PENTING: Tambahkan path endpoint-mu di belakangnya (misal: /api/articles atau /api/insight/articles)
  final String apiUrl = "https://minddrijiapp.my.id/api/articles"; 
  
  // Diubah jadi RxList<dynamic> agar tipenya fleksibel membaca Map dari MongoDB
  var articles = <dynamic>[].obs; 
  var isLoading = true.obs;       
  var errorMessage = "".obs;     

  @override
  void onInit() {
    super.onInit();
    _homeController = Get.find<HomeController>();
    fetchArticles(); 
  }

  // ── 🟡 FUNGSI TARIK DATA DARI API FLASK VIA NGROK (HANYA INI YANG DIADAPTASI) ──
  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      errorMessage.value = ""; 

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Menangani jika Flask membungkus data dengan {"success": true, "data": [...]}
        if (data is Map && data['success'] == true) {
          articles.assignAll(data['data']);
        } 
        // Menangani jika Flask langsung mengembalikan nilai Array/List langsung []
        else if (data is List) {
          articles.assignAll(data);
        } else {
          errorMessage.value = "Format data artikel tidak sesuai.";
        }
      } else {
        errorMessage.value = "Server Flask merespon error (Status: ${response.statusCode})";
      }
    } catch (e) {
      errorMessage.value = "Koneksi terputus. Pastikan Ngrok Anda aktif! \nDetail: $e";
    } finally {
      isLoading.value = false; 
    }
  }

  // ── 🔒 GETTER REAKTIF DARI HOME CONTROLLER (TIDAK BERUBAH) ──
  String get doomscrollStatus => _homeController.doomscrollStatus.value;
  int get healthScore => _homeController.healthScore.value;
  String get eyeCondition => _homeController.eyeCondition.value;
  String get screenTime => _homeController.screenTime.value;
  int get eyeFatigueCount => _homeController.eyeFatigueCount.value;
  int get screenTimeScore => _homeController.screenTimeScore.value;
  int get doomscrollScore => _homeController.doomscrollScore.value;

  // ── 🔒 HELPER WARNA BERDASARKAN RISK LEVEL (TIDAK BERUBAH) ──
  Color riskColor(String level) {
    switch (level) {
      case 'Tinggi':
        return const Color(0xFFFF5252); 
      case 'Sedang':
        return const Color(0xFFFFB300); 
      default:
        return const Color(0xFF00BFA5); 
    }
  }

  Color get focusColor {
    if (focusAbility >= 0.7) return riskColor('Rendah');
    if (focusAbility >= 0.4) return riskColor('Sedang');
    return riskColor('Tinggi');
  }

  // ── 🔒 ESTIMASI DAMPAK FISIK (TIDAK BERUBAH) ──
  double get eyeFatigueLevel {
    double base = eyeCondition == "Lelah" ? 0.60 : 0.20;
    double tambahanFatigueCount = eyeFatigueCount * 0.02;
    double screenTimeRisk = ((100 - screenTimeScore) / 100.0) * 0.3;
    return (base + tambahanFatigueCount + screenTimeRisk).clamp(0.0, 1.0);
  }

  double get sleepDeficitLevel {
    double screenRisk = (100 - screenTimeScore) / 100.0;
    double doomRisk = doomscrollScore / 100.0;
    double result = (screenRisk * 0.4) + (doomRisk * 0.6);
    return result.clamp(0.0, 1.0);
  }

  double get focusAbility {
    double risikoGabungan = (eyeFatigueLevel * 0.5) + (sleepDeficitLevel * 0.5);
    return (1.0 - risikoGabungan).clamp(0.0, 1.0);
  }

  String _riskLevel(double value) {
    if (value >= 0.6) return 'Tinggi';
    if (value >= 0.3) return 'Sedang';
    return 'Rendah';
  }

  String get eyeRiskLevel => _riskLevel(eyeFatigueLevel);
  String get sleepRiskLevel => _riskLevel(sleepDeficitLevel);

  // ── 🔒 KESIMPULAN TEKS AI DINAMIS (TIDAK BERUBAH) ──
  String get doomscrollInsightDesc {
    switch (doomscrollStatus) {
      case 'Tinggi':
        return 'Terdeteksi scrolling aplikasi media sosial intensitas tinggi secara berulang tanpa jeda kompensasi fisik.';
      case 'Sedang':
        return 'Pola scroll mulai meningkat di atas batas wajar harian. Waspadai durasi penggunaan di jam produktif.';
      default:
        return 'Pola penggunaan gadget stabil dan berada dalam batas aman digital wellness Anda.';
    }
  }

  String get eyeStrainDesc {
    switch (eyeRiskLevel) {
      case 'Tinggi':
        return 'Beban mata menumpuk akibat durasi screen time sebesar $screenTime tanpa kalibrasi/istirahat berkala. Segera kurangi durasi pemakaian.';
      case 'Sedang':
        return 'Screen time $screenTime mulai melebihi batas nyaman. Mata menunjukkan tanda kelelahan ringan, perlu jeda lebih sering.';
      default:
        return 'Screen time $screenTime masih berada dalam batas aman, dengan waktu istirahat retina yang cukup.';
    }
  }

  String get recommendationText {
    if (sleepRiskLevel == 'Tinggi') {
      return 'Aktifkan filter cahaya biru (Eye Comfort) sekarang, kunci aplikasi media sosial sementara waktu, dan terapkan aturan 20-20-20 (istirahat 20 detik melihat objek sejauh 20 kaki).';
    } else if (sleepRiskLevel == 'Sedang') {
      return 'Mulai kurangi screen time bertahap. Coba jeda 5 menit setiap 30 menit scrolling untuk mencegah risiko naik ke level tinggi.';
    }
    return 'Pertahankan ritme ini! Rekomendasi AI: Berikan jeda fisik minimal 5 menit setiap 1 jam penggunaan gadget di sisa hari ini.';
  }
}