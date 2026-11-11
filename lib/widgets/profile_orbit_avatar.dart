import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProfileOrbitAvatar extends StatelessWidget {
  final String imageUrl;
  final String level;

  const ProfileOrbitAvatar({
    super.key,
    required this.imageUrl,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Efek Glow / Aura di belakang
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonYellow.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Lingkaran Orbit (Garis Tipis)
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonYellow.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),

          // Foto Profil Utama
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0E11),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonYellow, width: 1.5),
            ),
            child: ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover)),
          ),

          // Titik Status Online (Kanan Bawah dari Foto)
          Positioned(
            right: 20,
            bottom: 24,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF08090C), width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.greenAccent, blurRadius: 8),
                ],
              ),
            ),
          ),

          // Label Level (Menempel di garis orbit)
          Positioned(
            right: 0,
            bottom: 15,
            child: Transform.rotate(
              angle: 0.1, // Sedikit miring (4 derajat)
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111216),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neonYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'LVL',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      level,
                      style: const TextStyle(
                        color: AppColors.neonYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
