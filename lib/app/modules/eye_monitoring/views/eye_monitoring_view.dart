import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/eye_monitoring_controller.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA); 
const Color cardLight = Color(0xFFFFFFFF); 
const Color textDark = Color(0xFF2D3142); 
const Color textGrey = Color(0xFF9094A6); 
const Color accentCyan = Color(0xFF00BFA5); 
const Color dangerRed = Color(0xFFFF5252);
const Color cameraBg = Color(0xFF1E212A); // Warna gelap khusus untuk area feed kamera

class EyeMonitoringView extends GetView<EyeMonitoringController> {
  const EyeMonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text('AI Eye Monitoring', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: accentCyan),
            onPressed: () {}, 
          )
        ],
      ),
      body: Column(
        children: [
          // 1. AREA KAMERA (HUD FUTURISTIK)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cameraBg, // Placeholder kamera tetap gelap agar HUD terlihat jelas
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: accentCyan.withOpacity(0.15), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10))
                ],
                border: Border.all(color: accentCyan.withOpacity(0.5), width: 4), // Frame lebih tebal
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Placeholder Siluet Wajah
                    const Center(
                      child: Icon(Icons.face, color: Color(0xFF2A2E3B), size: 180), 
                    ),

                    // Efek Scanner Bergerak (Animasi HUD)
                    const _FaceScannerHUD(),
                    
                    // Label Status Live
                    Positioned(
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: dangerRed.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(10), 
                          border: Border.all(color: dangerRed)
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: dangerRed, size: 10),
                            SizedBox(width: 8),
                            Text('LIVE TRACKING', style: TextStyle(color: dangerRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Koordinat Mockup
                    Positioned(
                      bottom: 16, left: 16,
                      child: Text('X: 142 Y: 89 Z: 0.5\nEAR: 0.28 (NORMAL)', style: TextStyle(color: accentCyan.withOpacity(0.9), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. HASIL ANALISIS REAL-TIME (TEMA TERANG)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: accentCyan),
                    SizedBox(width: 8),
                    Text('Parameter Biometrik', style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricData('EAR (Mata)', '0.28', 'Normal', accentCyan),
                    _buildMetricData('Blink Rate', '15 BPM', 'Stabil', accentCyan),
                    _buildMetricData('Fatigue', '12%', 'Aman', accentCyan),
                  ],
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgLight, 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentCyan.withOpacity(0.2))
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: accentCyan.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_outline, color: accentCyan, size: 28)
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kondisi Optimal', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
                            Text('Tidak terdeteksi kelelahan mata.', style: TextStyle(color: textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle, color: dangerRed, size: 40),
                        onPressed: () => Get.back(),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricData(String title, String value, String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// WIDGET ANIMASI SCANNER HUD (TETAP SAMA KARENA DI DALAM KAMERA GELAP)
// ==========================================
class _FaceScannerHUD extends StatefulWidget {
  const _FaceScannerHUD({Key? key}) : super(key: key);

  @override
  State<_FaceScannerHUD> createState() => _FaceScannerHUDState();
}

class _FaceScannerHUDState extends State<_FaceScannerHUD> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Center(
              child: Container(
                width: 200, height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: accentCyan.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
            
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  top: (constraints.maxHeight / 2 - 125) + (_animationController.value * 250),
                  left: constraints.maxWidth / 2 - 100,
                  right: constraints.maxWidth / 2 - 100,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: accentCyan,
                      boxShadow: [BoxShadow(color: accentCyan, blurRadius: 12, spreadRadius: 3)],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildCorner(Alignment alignment) {
    double top = (alignment == Alignment.topLeft || alignment == Alignment.topRight) ? 0 : -1;
    double bottom = (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) ? 0 : -1;
    double left = (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) ? 0 : -1;
    double right = (alignment == Alignment.topRight || alignment == Alignment.bottomRight) ? 0 : -1;

    return Positioned(
      top: top >= 0 ? top : null, bottom: bottom >= 0 ? bottom : null,
      left: left >= 0 ? left : null, right: right >= 0 ? right : null,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top >= 0 ? const BorderSide(color: accentCyan, width: 4) : BorderSide.none,
            bottom: bottom >= 0 ? const BorderSide(color: accentCyan, width: 4) : BorderSide.none,
            left: left >= 0 ? const BorderSide(color: accentCyan, width: 4) : BorderSide.none,
            right: right >= 0 ? const BorderSide(color: accentCyan, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}