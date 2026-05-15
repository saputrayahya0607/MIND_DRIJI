import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/insight_controller.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA); 
const Color cardLight = Color(0xFFFFFFFF); 
const Color textDark = Color(0xFF2D3142); 
const Color textGrey = Color(0xFF9094A6); 
const Color accentCyan = Color(0xFF00BFA5); 
const Color warningYellow = Color(0xFFFFB300);
const Color dangerRed = Color(0xFFFF5252);
const Color barBg = Color(0xFFE2E8F0); // Background abu-abu untuk progress bar

class InsightView extends GetView<InsightController> {
  const InsightView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight, // Background utama terang
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text('AI Health Insight', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 4),
            const Text('Analisis perilaku & rekomendasi sistem MIND DRIJI.', style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 32),

            // 1. BAGIAN ANALISIS PERILAKU
            _buildInsightTile(Icons.psychology, 'Pola Doomscrolling', 'AI mendeteksi kecenderungan scrolling tanpa henti pada malam hari (22:00 - 00:00).', warningYellow),
            const SizedBox(height: 16),
            _buildInsightTile(Icons.lightbulb_outline, 'Rekomendasi Cerdas', 'Aktifkan filter cahaya biru dan mulai kurangi kecerahan layar setelah jam 8 malam.', accentCyan),
            const SizedBox(height: 32),
            
            // 2. BAGIAN DAMPAK FISIK
            const Text('Estimasi Dampak Fisik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardLight, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))]
              ),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRiskLevel('Tingkat Kelelahan Mata', controller.fatigueLevel.value, dangerRed),
                  const SizedBox(height: 20),
                  _buildRiskLevel('Kualitas Tidur (Defisit)', controller.sleepDeficit.value, warningYellow),
                  const SizedBox(height: 20),
                  _buildRiskLevel('Kemampuan Fokus', 0.45, accentCyan),
                ],
              )),
            ),
            const SizedBox(height: 32),

            // 3. BAGIAN ARTIKEL HASIL WEB SCRAPING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Artikel Edukasi Kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                Icon(Icons.sync, color: textGrey.withOpacity(0.5), size: 18), 
              ],
            ),
            const SizedBox(height: 16),
            
            // Me-render daftar artikel
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
            const Center(child: Text('Data artikel diambil secara otomatis dari portal web.', style: TextStyle(color: textGrey, fontSize: 10, fontStyle: FontStyle.italic))),
            const SizedBox(height: 40),
          ],
        ),
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
        color: cardLight, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.2), width: 1)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24)
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(color: textGrey, fontSize: 12, height: 1.5)),
          ]))
        ]
      ),
    );
  }

  Widget _buildRiskLevel(String label, double value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value, 
          color: color, 
          backgroundColor: barBg, 
          minHeight: 8
        ),
      ),
    ]);
  }

  Widget _buildArticleCard({required String title, required String source, required String time, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3))]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: accentCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accentCyan, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
                      child: Text(source, style: const TextStyle(color: textGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: textGrey, size: 12),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: textGrey, fontSize: 10)),
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