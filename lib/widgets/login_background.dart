import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Efek Glow Kuning Neon di tengah
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: -50,
          right: -50,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonYellow.withValues(
                alpha: 0.05,
              ), // Sangat redup
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonYellow.withValues(alpha: 0.1),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),

        // Custom Grid Perspektif di bagian bawah
        Positioned(
          bottom: 0,
          left: -100,
          right: -100,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Opacity(
            opacity: 0.15,
            child: CustomPaint(painter: GridFloorPainter()),
          ),
        ),

        // Teks dekoratif di pinggir (Kiri & Kanan)
        const Positioned(
          left: 16,
          top: 250,
          child: RotatedBox(
            quarterTurns: 1, // Tulisan vertikal
            child: Text(
              'OTW / ONLINE',
              style: TextStyle(
                color: Colors.white24,
                fontFamily: 'monospace',
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const Positioned(
          right: 16,
          bottom: 150,
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              '35.6762° N',
              style: TextStyle(
                color: Colors.white24,
                fontFamily: 'monospace',
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Logic untuk menggambar jaring-jaring 3D perspektif
class GridFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonYellow
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    double centerX = size.width / 2;
    double topY = size.height * 0.3; // Titik hilang perspektif

    // Gambar garis vertikal menyebar (Perspektif)
    for (double i = -size.width; i <= size.width * 2; i += 60) {
      canvas.drawLine(Offset(centerX, topY), Offset(i, size.height), paint);
    }

    // Gambar garis horizontal (semakin rapat ke atas)
    double currentY = size.height;
    double gap = 60;
    while (currentY > topY) {
      canvas.drawLine(Offset(0, currentY), Offset(size.width, currentY), paint);
      currentY -= gap;
      gap *= 0.8; // Efek jarak semakin menyempit di kejauhan
    }

    // Gradien hitam dari atas ke bawah untuk menyamarkan batas atas grid
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.background,
        AppColors.background.withValues(alpha: 0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    );
    final bgPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
