import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/insight_controller.dart';

const Color cardDark = Color(0xFF1D1E33);
const Color accentCyan = Color(0xFF1DE9B6);
const Color warningYellow = Color(0xFFFFD600);
const Color dangerRed = Color(0xFFFF5252);
const Color bgDark = Color(0xFF0A0E21);

class InsightView extends GetView<InsightController> {
  const InsightView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          const Text('AI Health Insight', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Analisis perilaku & rekomendasi sistem MIND DRIJI.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 32),

          // 1. BAGIAN ANALISIS PERILAKU (HASIL MACHINE LEARNING)
          _buildInsightTile(Icons.psychology, 'Pola Doomscrolling', 'AI mendeteksi kecenderungan scrolling tanpa henti pada malam hari (22:00 - 00:00).', warningYellow),
          const SizedBox(height: 16),
          _buildInsightTile(Icons.lightbulb_outline, 'Rekomendasi Cerdas', 'Aktifkan filter cahaya biru dan mulai kurangi kecerahan layar setelah jam 8 malam.', accentCyan),
          const SizedBox(height: 32),
          
          // 2. BAGIAN DAMPAK FISIK
          const Text('Estimasi Dampak Fisik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20)),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRiskLevel('Tingkat Kelelahan Mata', controller.fatigueLevel.value, dangerRed),
                _buildRiskLevel('Kualitas Tidur (Defisit)', controller.sleepDeficit.value, warningYellow),
                _buildRiskLevel('Kemampuan Fokus', 0.45, accentCyan),
              ],
            )),
          ),
          const SizedBox(height: 32),

          // 3. BAGIAN ARTIKEL HASIL WEB SCRAPING
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Artikel Terkait (Web Scraping)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Icon(Icons.sync, color: accentCyan.withOpacity(0.5), size: 18), // Ikon refresh/scraping
            ],
          ),
          const SizedBox(height: 16),
          
          // Me-render daftar artikel dari controller
          Obx(() => Column(
            children: controller.scrapedArticles.map((article) {
              IconData iconData = Icons.article;
              if (article['icon'] == 'health_and_safety') iconData = Icons.health_and_safety;
              if (article['icon'] == 'remove_red_eye') iconData = Icons.remove_red_eye;
              if (article['icon'] == 'psychology') iconData = Icons.psychology;

              return _buildArticleCard(
                title: article['title'].toString(),
                source: article['source'].toString(),
                time: article['time'].toString(),
                icon: iconData,
              );
            }).toList(),
          )),
          
          const SizedBox(height: 24),
          const Center(child: Text('Data artikel diambil secara otomatis dari portal kesehatan.', style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET HELPERS
  // ==========================================

  Widget _buildInsightTile(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
          ]))
        ]
      ),
    );
  }

  Widget _buildRiskLevel(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value, color: color, backgroundColor: bgDark, minHeight: 6, borderRadius: BorderRadius.circular(10)),
      ]),
    );
  }

  // WIDGET KHUSUS ARTIKEL SCRAPING
  Widget _buildArticleCard({required String title, required String source, required String time, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Thumbnail Placeholder (Diganti icon agar ringan)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accentCyan, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: accentCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(source, style: const TextStyle(color: accentCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, color: Colors.grey, size: 10),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}