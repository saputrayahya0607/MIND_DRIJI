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
const Color barBg = Color(0xFFE2E8F0); 

class InsightView extends GetView<InsightController> {
  const InsightView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Memastikan controller terinisialisasi
    Get.put(InsightController());

    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER & STATUS KESIMPULAN (TOP LEVEL)
            // ==========================================
            const Text('AI Health Insight', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 4),
            const Text('Analisis perilaku & rekomendasi sistem MIND DRIJI.', style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 24),

            // Kartu Status Utama (Highlight)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dangerRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dangerRed.withOpacity(0.5), width: 1.5)
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: dangerRed, shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Risiko Doomscrolling:', style: TextStyle(color: dangerRed, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('TINGGI', style: TextStyle(color: dangerRed, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 2. KARTU ANALISIS PERILAKU
            // ==========================================
            const Text('Analisis Perilaku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            _buildInsightTile(
              Icons.psychology, 
              'Pola Doomscrolling', 
              'Terdeteksi scrolling aplikasi media sosial tanpa henti pukul 22:00 - 00:00.', 
              warningYellow
            ),
            const SizedBox(height: 12),
            _buildInsightTile(
              Icons.nights_stay_outlined, 
              'Aktivitas Malam', 
              'Screen time meningkat tajam di atas jam 23:00 selama 3 hari berturut-turut.', 
              warningYellow
            ),
            const SizedBox(height: 32),
            
            // ==========================================
            // 3. BAR ESTIMASI DAMPAK FISIK
            // ==========================================
            const Text('Estimasi Dampak Fisik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardLight, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRiskLevel('Tingkat Kelelahan Mata', 0.85, dangerRed), // 85% Merah
                  const SizedBox(height: 20),
                  _buildRiskLevel('Defisit Kualitas Tidur', 0.60, warningYellow), // 60% Kuning
                  const SizedBox(height: 20),
                  _buildRiskLevel('Kemampuan Fokus', 0.45, accentCyan), // 45% Cyan
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 4. REKOMENDASI & EDUKASI
            // ==========================================
            const Text('Saran & Edukasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            
            // Kartu Rekomendasi Solusi
            _buildInsightTile(
              Icons.lightbulb_outline, 
              'Rekomendasi Tindakan Instan', 
              'Aktifkan filter cahaya biru (Eye Comfort) sekarang dan gunakan aturan 20-20-20 saat menatap layar.', 
              accentCyan,
              isHighlighted: true
            ),
            const SizedBox(height: 24),

            // Daftar Artikel Web Scraping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bacaan Kesehatan Digital', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
                Icon(Icons.sync, color: textGrey.withOpacity(0.5), size: 18), 
              ],
            ),
            const SizedBox(height: 12),
            
            // Render Statis untuk Demo (Bisa diubah ke Obx/Controller nanti)
            _buildArticleCard(
              title: 'Dampak Doomscrolling pada Kesehatan Otak dan Mental Remaja',
              source: 'Kemenkes RI',
              time: '2 Jam yang lalu',
              icon: Icons.psychology,
            ),
            _buildArticleCard(
              title: 'Cara Menerapkan Aturan 20-20-20 untuk Mencegah Mata Lelah',
              source: 'Halodoc',
              time: '5 Jam yang lalu',
              icon: Icons.remove_red_eye,
            ),
            
            const SizedBox(height: 24),
            const Center(child: Text('Data artikel ditarik otomatis oleh AI Web Scraper.', style: TextStyle(color: textGrey, fontSize: 10, fontStyle: FontStyle.italic))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HELPERS
  // ==========================================

  Widget _buildInsightTile(IconData icon, String title, String desc, Color color, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.05) : cardLight, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: isHighlighted ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.3), width: 1.5)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24)
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(desc, style: TextStyle(color: isHighlighted ? textDark : textGrey, fontSize: 12, height: 1.5)),
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
          minHeight: 10 // Bar sedikit dipertebal agar lebih jelas
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