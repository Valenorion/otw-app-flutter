import 'package:flutter/material.dart';

import '../models/squad_model.dart';

class SquadCard extends StatelessWidget {
  final SquadModel squad;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SquadCard({super.key, required this.squad, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color accentColor = Color(int.parse(squad.accentColorHex));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1015),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Icon(
              _getIconForString(squad.iconAsset),
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Content Center
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  squad.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${squad.game}  •  ${squad.mode}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),

                // Stacked Avatars & Member count
                Row(
                  children: [
                    _buildAvatarStack(),
                    const SizedBox(width: 8),
                    Text(
                      '${squad.totalMembers} members',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Column (Online Status & Arrow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${squad.onlineCount} ONLINE',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white54,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'Edit') {
                    onEdit?.call();
                  } else if (value == 'Delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'Edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 70,
      height: 24,
      child: Stack(
        children: [
          _buildStackedAvatar(
            'https://images.unsplash.com/photo-1644353224392-7e532d7b8f4b?w=100',
            0,
          ),
          _buildStackedAvatar(
            'https://images.unsplash.com/photo-1615511676788-240d40160fbc?w=100',
            16,
          ),
          _buildStackedAvatar(
            'https://images.unsplash.com/photo-1580983696793-3500a8a0b7f4?w=100',
            32,
          ),
          Positioned(
            left: 48,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF24262E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0F1015), width: 2),
              ),
              child: const Center(
                child: Text(
                  '+5',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedAvatar(String url, double leftMargin) {
    return Positioned(
      left: leftMargin,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0F1015), width: 2),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  // Helper untuk mengubah string nama aset jadi Icon Data
  IconData _getIconForString(String iconName) {
    switch (iconName) {
      case 'crosshair':
        return Icons.my_location;
      case 'bolt':
        return Icons.bolt;
      case 'sword':
        return Icons.sports_kabaddi;
      default:
        return Icons.shield;
    }
  }
}
