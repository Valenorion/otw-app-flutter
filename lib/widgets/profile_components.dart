import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'OTW.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: const Icon(Icons.edit, color: Colors.white54, size: 16),
        ),
      ],
    );
  }
}

class ProfileStatusPill extends StatelessWidget {
  const ProfileStatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.05),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(width: 6),
          const Text(
            'Online',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.white38,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Ready to queue',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSocialCounts extends StatelessWidget {
  const ProfileSocialCounts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _ProfileCountItem('2.4K', 'Followers'),
          _ProfileCountDivider(),
          _ProfileCountItem('186', 'Following'),
          _ProfileCountDivider(),
          _ProfileCountItem('08', 'Squads'),
        ],
      ),
    );
  }
}

class _ProfileCountItem extends StatelessWidget {
  final String count;
  final String label;

  const _ProfileCountItem(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}

class _ProfileCountDivider extends StatelessWidget {
  const _ProfileCountDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProfileSectionTitle(this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const ProfileMenuItem(
            Icons.settings,
            'Settings',
            'Privacy, notifications, display',
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const ProfileMenuItem(
            Icons.link,
            'Linked Accounts',
            'Discord, Twitch, Riot Games',
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileMenuItem(this.icon, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
        ],
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.errorRed,
          backgroundColor: AppColors.errorRed.withValues(alpha: 0.05),
          side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.15)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
