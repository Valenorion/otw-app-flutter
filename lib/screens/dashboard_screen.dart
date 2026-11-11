import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/squad_model.dart';
import '../theme/app_colors.dart';
import '../widgets/featured_card.dart';
import '../widgets/squad_card.dart';
import '../widgets/ping_button.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.neonYellow,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                const FeaturedCard(),
                const SizedBox(height: 32),
                _buildSquadsSectionHeader(),
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('squads')
                      .where(
                        'memberIds',
                        arrayContains: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .limit(3)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final squad = SquadModel.fromFirestore(doc);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(squad: squad),
                              ),
                            );
                          },
                          child: SquadCard(squad: squad),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar dihapus dari sini!
    );
  }

  Future<void> _handleRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THURSDAY · 9:41 PM',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          const TextSpan(
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: 'Game night?\n'),
              TextSpan(
                text: 'Say less.',
                style: TextStyle(color: Color(0xFFDFFF00)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your people are already online.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSquadsSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR CREWS',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Squads',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all →',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildChip('All', true),
        const SizedBox(width: 8),
        _buildChip('Mobile', false),
        const SizedBox(width: 8),
        _buildChip('Valorant', false),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              FirebaseAuth.instance.currentUser?.photoURL ??
                  'https://ui-avatars.com/api/?name=User',
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('Profile'),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              if (!kIsWeb) await GoogleSignIn.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(color: isSelected ? Colors.white : Colors.white24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
