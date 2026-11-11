import 'package:flutter/material.dart';

class ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accentColor;
  final bool isWide; // Untuk mengatur apakah kotak ini memanjang ke samping

  const ProfileStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accentColor,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: isWide ? _buildWideLayout() : _buildSquareLayout(),
    );
  }

  Widget _buildSquareLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconBox(),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
        const Spacer(),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          detail,
          style: const TextStyle(color: Colors.white38, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        _buildIconBox(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      ],
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: accentColor, size: 20),
    );
  }
}
