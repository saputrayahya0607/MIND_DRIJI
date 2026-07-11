import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/article_detail_controller.dart';

class ArticleDetailView extends GetView<ArticleDetailController> {
  const ArticleDetailView({super.key});

  // Palet disamakan dengan InsightView supaya alur Insight -> Detail
  // Artikel terasa satu tema, bukan berpindah aplikasi.
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3142);
  static const Color textGrey = Color(0xFF9094A6);
  static const Color accentCyan = Color(0xFF00BFA5);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> article = Get.arguments ?? {};

    final String title = article['title'] ?? 'Tanpa Judul';
    final String category = article['category'] ?? 'Umum';
    final String date = article['date'] ?? '-';
    final String content = article['content'] ?? 'Tidak ada konten.';
    final String originalLink = article['link'] ?? '';

    // Estimasi waktu baca: rata-rata orang membaca ~200 kata/menit.
    final int wordCount = content.trim().isEmpty
        ? 0
        : content.trim().split(RegExp(r'\s+')).length;
    final int readMinutes = (wordCount / 200).ceil().clamp(1, 99);

    // Pecah konten jadi paragraf berdasarkan baris kosong / newline ganda,
    // fallback ke satu paragraf kalau kontennya nggak punya jeda.
    final List<String> paragraphs = content
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final List<String> displayParagraphs =
        paragraphs.isEmpty ? [content] : paragraphs;

    return Scaffold(
      backgroundColor: bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── APPBAR KOLAPS DENGAN JUDUL ──
          SliverAppBar(
            backgroundColor: bgLight,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: textDark, size: 20),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Detail Artikel',
              style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined,
                    color: accentCyan, size: 20),
                onPressed: () {
                  Get.snackbar(
                    'Bagikan Artikel',
                    'Fitur berbagi akan segera hadir.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: cardLight,
                    colorText: textDark,
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. BADGE KATEGORI ──
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentCyan.withOpacity(0.3)),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: accentCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 2. JUDUL ARTIKEL ──
                  Text(
                    title,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── 3. META INFO: TANGGAL & WAKTU BACA ──
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: textGrey, size: 13),
                      const SizedBox(width: 6),
                      Text(date,
                          style:
                              const TextStyle(color: textGrey, fontSize: 12.5)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time_rounded,
                          color: textGrey, size: 13),
                      const SizedBox(width: 6),
                      Text('$readMinutes menit baca',
                          style:
                              const TextStyle(color: textGrey, fontSize: 12.5)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    height: 0.5,
                    color: textGrey.withOpacity(0.25),
                  ),
                  const SizedBox(height: 20),

                  // ── 4. ISI KONTEN ARTIKEL (per paragraf) ──
                  for (int i = 0; i < displayParagraphs.length; i++) ...[
                    Text(
                      displayParagraphs[i],
                      style: TextStyle(
                        color: textDark.withOpacity(0.85),
                        fontSize: 15.5,
                        height: 1.75,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    if (i != displayParagraphs.length - 1)
                      const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 28),

                  // ── 5. KARTU SUMBER ASLI ──
                  if (originalLink.isNotEmpty && originalLink != '#')
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Get.snackbar(
                          'Membuka Link',
                          'Mengarahkan ke: $originalLink',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: cardLight,
                          colorText: textDark,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardLight,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: accentCyan.withOpacity(0.25), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: accentCyan.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.open_in_browser_rounded,
                                  color: accentCyan, size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Baca artikel asli',
                                    style: TextStyle(
                                      color: textDark,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    originalLink,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: textGrey, fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: textGrey, size: 20),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}