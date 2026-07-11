import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/insight_controller.dart';
// 🟡 TAMBAHAN IMPORT: Sesuaikan path ini dengan folder routes project-mu jika "Routes" terdeteksi merah
// import '../../../routes/app_pages.dart'; 

// PALET WARNA LIGHT MODE
const Color bgLight       = Color(0xFFF5F7FA); 
const Color cardLight     = Color(0xFFFFFFFF); 
const Color textDark      = Color(0xFF2D3142); 
const Color textGrey      = Color(0xFF9094A6); 
const Color accentCyan    = Color(0xFF00BFA5); 
const Color warningYellow = Color(0xFFFFB300);
const Color dangerRed     = Color(0xFFFF5252);
const Color barBg         = Color(0xFFE2E8F0); 

class InsightView extends GetView<InsightController> {
  const InsightView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Memastikan controller terinisialisasi
    Get.put(InsightController());

    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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

            // Kartu Status Utama Komparatif AI
            Obx(() {
              final status = controller.doomscrollStatus;
              Color statusColor = accentCyan;
              String riskText = 'BAIK / RENDAH';
              IconData riskIcon = Icons.check_circle_outline;

              if (status == 'Tinggi') {
                statusColor = dangerRed;
                riskText = 'TINGGI';
                riskIcon = Icons.warning_amber_rounded;
              } else if (status == 'Sedang') {
                statusColor = warningYellow;
                riskText = 'SEDANG / WASPADA';
                riskIcon = Icons.error_outline;
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5)
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      child: Icon(riskIcon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Risiko Doomscrolling:', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(riskText, style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            // ==========================================
            // 2. KARTU ANALISIS PERILAKU
            // ==========================================
            const Text('Analisis Perilaku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            Obx(() => _buildInsightTile(
              Icons.psychology, 
              'Pola Doomscrolling', 
              controller.doomscrollInsightDesc, 
              controller.doomscrollStatus == 'Tinggi' ? dangerRed : (controller.doomscrollStatus == 'Sedang' ? warningYellow : accentCyan)
            )),
            const SizedBox(height: 12),
            Obx(() => _buildInsightTile(
              Icons.nights_stay_outlined, 
              'Kondisi Penggunaan Gadget', 
              controller.eyeStrainDesc, 
              controller.riskColor(controller.eyeRiskLevel),
            )),
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
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRiskLevel('Tingkat Kelelahan Mata', controller.eyeFatigueLevel, controller.riskColor(controller.eyeRiskLevel),),
                  const SizedBox(height: 20),
                  _buildRiskLevel('Defisit Kualitas Tidur', controller.sleepDeficitLevel, controller.riskColor(controller.sleepRiskLevel)), 
                  const SizedBox(height: 20),
                  _buildRiskLevel('Kemampuan Fokus Kontrol', controller.focusAbility, controller.focusColor), 
                ],
              )),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 4. REKOMENDASI & EDUKASI
            // ==========================================
            const Text('Saran & Edukasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            
            // Kartu Rekomendasi Solusi
            Obx(() => _buildInsightTile(
              Icons.lightbulb_outline, 
              'Rekomendasi Tindakan Instan', 
              controller.recommendationText, 
              controller.riskColor(controller.sleepRiskLevel),
              isHighlighted: true
            )),
            const SizedBox(height: 24),

            // Daftar Artikel Web Scraping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bacaan Kesehatan Digital', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
                GestureDetector(
                  onTap: () => controller.fetchArticles(),
                  child: const Icon(Icons.sync, color: accentCyan, size: 20),
                ), 
              ],
            ),
            const SizedBox(height: 12),
            
            // ── 🟡 KONEKSI LIVE REAKTIF MONGO DB (OBX) ──
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(color: accentCyan),
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      controller.errorMessage.value, 
                      style: const TextStyle(color: dangerRed, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (controller.articles.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('Tidak ada artikel hasil scraping.', style: TextStyle(color: textGrey, fontSize: 12)),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.articles.length,
                itemBuilder: (context, index) {
                  final item = controller.articles[index];
                  
                  IconData dynamicIcon = Icons.article_outlined;
                  String categoryText = (item['category'] ?? 'Umum').toString().toLowerCase();
                  if (categoryText.contains('mata') || categoryText.contains('eye')) {
                    dynamicIcon = Icons.remove_red_eye;
                  } else if (categoryText.contains('mental') || categoryText.contains('stres') || categoryText.contains('otak')) {
                    dynamicIcon = Icons.psychology;
                  }

                  // ── 🟡 SEKARANG KARTU BISA DIKLIK & PINDAH HALAMAN ──
                  return GestureDetector(
                    onTap: () {
                      // Mengarahkan ke rute detail dengan melempar data item artikel mentah-mentah
                      Get.toNamed('/article-detail', arguments: item);
                    },
                    child: _buildArticleCard(
                      title: item['title'] ?? 'Tanpa Judul',
                      source: item['category'] ?? 'Scraper', 
                      time: item['date'] ?? '-',             
                      content: item['content'] ?? '',        
                      icon: dynamicIcon,
                    ),
                  );
                },
              );
            }),
            
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
            Text(title, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(desc, style: TextStyle(color: isHighlighted ? textDark : textGrey, fontSize: 12, height: 1.5)),
          ]))
        ],
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
          minHeight: 10 
        ),
      ),
    ]);
  }

  Widget _buildArticleCard({
    required String title, 
    required String source, 
    required String time, 
    required String content, 
    required IconData icon
  }) {
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
                const SizedBox(height: 6),
                if (content.isNotEmpty)
                  Text(
                    content,
                    style: const TextStyle(color: textGrey, fontSize: 11, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
                      child: Text(source.toUpperCase(), style: const TextStyle(color: textGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: textGrey, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        time, 
                        style: const TextStyle(color: textGrey, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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