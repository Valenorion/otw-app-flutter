import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dashboard_screen.dart';
import 'squads_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import '../models/squad_model.dart';
import '../widgets/squad_card.dart';
import '../theme/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SquadsScreen(),
    const InboxScreen(), // Halaman Chat/Inbox yang baru
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar global dihapus agar tidak ada teks ganda di bagian atas.
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF08090D),
        selectedItemColor: const Color(0xFFDFFF00),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Squads'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Widget Halaman Inbox Baru
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  // Fungsi Logika Logout yang Aman dari Error GoogleSignIn
  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(
          'User not logged in',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      // Menambahkan Header Kustom agar Seragam dengan Home/Dashboard
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFDFFF00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'O',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'OTW.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          const Row(
            children: [
              Icon(Icons.circle, color: Color(0xFFDFFF00), size: 10),
              SizedBox(width: 4),
              Text(
                '8 ONLINE',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL ??
                      'https://ui-avatars.com/api/?name=User',
                ),
              ),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
              PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil squad dimana UID current user ada di dalam array memberIds
        stream: FirebaseFirestore.instance
            .collection('squads')
            .where('memberIds', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonYellow),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error memuat data',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum bergabung ke skuad manapun',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: snapshot.data!.docs.map((doc) {
              final squad = SquadModel.fromFirestore(doc);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(squad: squad),
                    ),
                  );
                },
                // Render UI menggunakan Card yang sama dengan beranda
                child: SquadCard(squad: squad),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
