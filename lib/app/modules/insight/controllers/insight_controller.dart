import 'package:get/get.dart';

class InsightController extends GetxController {
  // Simulasi skor kesehatan dari Machine Learning
  var healthScore = 72.obs;
  var fatigueLevel = 0.85.obs; // 85% lelah
  var sleepDeficit = 0.60.obs; // 60% kurang tidur

  // Simulasi data hasil Web Scraping (Berita/Artikel)
  var scrapedArticles = [
    {
      'title': 'Bahaya Paparan Blue Light Layar HP Sebelum Tidur bagi Otak',
      'source': 'Kemenkes RI',
      'time': '2 jam lalu',
      'icon': 'health_and_safety'
    },
    {
      'title': 'Aturan 20-20-20 Efektif Mencegah Computer Vision Syndrome',
      'source': 'Jurnal Kedokteran',
      'time': '5 jam lalu',
      'icon': 'remove_red_eye'
    },
    {
      'title': 'Studi Baru: Doomscrolling Berhubungan Erat dengan Kecemasan Gen Z',
      'source': 'Portal Berita Tech',
      'time': '1 hari lalu',
      'icon': 'psychology'
    },
  ].obs;
}