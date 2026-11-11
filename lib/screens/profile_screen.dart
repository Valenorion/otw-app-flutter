import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Wajib untuk Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Wajib untuk Google Sign-In
import 'package:flutter/foundation.dart'; // Wajib untuk pengecekan kIsWeb

import '../theme/app_colors.dart';
import '../widgets/profile_orbit_avatar.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_components.dart';
import 'login_screen.dart'; // Rute kembali ke halaman login

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  // --- Fungsi Logout ---
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // 1. Keluar dari Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Keluar dari Google SignIn (Untuk Android, penting agar tidak autologin)
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }

      // 3. Pindah kembali ke Login Screen dan hapus riwayat stack
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error saat Logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user aktif (bisa nullable)
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonYellow,
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const ProfileTopBar(),
                  const SizedBox(height: 32),

                  // --- IDENTITY SECTION ---
                  ProfileOrbitAvatar(
                    // Menampilkan foto profil asli dari akun Google jika ada
                    imageUrl: currentUser?.photoURL ?? 'https://images.unsplash.com/photo-1610041321420-a596dd14ebc9?w=480',
                    level: '47',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'OTW MEMBER / 2024',
                    style: TextStyle(
                      color: AppColors.neonYellow,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Menampilkan nama asli pengguna dari akun Google
                    currentUser?.displayName ?? 'Player',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32, // Sedikit diperkecil agar nama panjang muat
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    currentUser?.email ?? 'No email',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const ProfileStatusPill(),
                  const SizedBox(height: 16),
                  const Text(
                    'Chasing clean clips, ranked wins, and the perfect five-stack.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ProfileSocialCounts(),

                  const SizedBox(height: 40),

                  // --- STATS SECTION ---
                  const ProfileSectionTitle('Player stats', 'THIS SEASON'),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          child: ProfileStatCard(
                            label: 'MAIN ROLE',
                            value: 'Duelist',
                            detail: 'Entry fragger',
                            icon: Icons.sports_kabaddi,
                            accentColor: AppColors.neonYellow,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ProfileStatCard(
                            label: 'CURRENT RANK',
                            value: 'Immortal II',
                            detail: 'Top 2.1%',
                            icon: Icons.shield,
                            accentColor: AppColors.accentViolet,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(
                    height: 100,
                    child: ProfileStatCard(
                      label: 'MOST PLAYED',
                      value: 'Valorant',
                      detail: '812 hours',
                      icon: Icons.gamepad,
                      accentColor: AppColors.accentCyan,
                      isWide: true,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- ACCOUNT SECTION ---
                  const ProfileSectionTitle('Account', 'MANAGE'),
                  const SizedBox(height: 16),
                  const ProfileMenuCard(),
                  const SizedBox(height: 16),
                  // Sambungkan tombol ke fungsi logout
                  LogoutButton(onLogout: () => _handleLogout(context)),
                  const SizedBox(height: 24),

                  const Text(
                    'OTW MOBILE / VERSION 2.4.1',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 120), // Ruang ekstra untuk Bottom Nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
