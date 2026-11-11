import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_screen.dart';
import 'login_screen.dart';
import '../models/squad_model.dart';
import '../widgets/squad_card.dart';
import '../theme/app_colors.dart';

class SquadsScreen extends StatefulWidget {
  const SquadsScreen({super.key});

  @override
  State<SquadsScreen> createState() => _SquadsScreenState();
}

class _SquadsScreenState extends State<SquadsScreen> {
  String activeFilter = 'All';
  final List<String> filters = ['All', 'Playing now', 'Ranked', 'Casual'];

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!kIsWeb) await GoogleSignIn.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.neonYellow,
                onRefresh: _handleRefresh,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 20),
                    _buildTitleAndCreateBtn(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildFilters(),
                    const SizedBox(height: 32),
                    _buildSectionHeading(),
                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('squads')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neonYellow,
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final currentUserId =
                              FirebaseAuth.instance.currentUser?.uid;
                          final visibleDocs = snapshot.data!.docs.where((doc) {
                            final squad = SquadModel.fromFirestore(doc);
                            return !squad.isPrivate ||
                                squad.memberIds.contains(currentUserId);
                          }).toList();

                          return Column(
                            children: visibleDocs.map((doc) {
                              final squad = SquadModel.fromFirestore(doc);
                              return Dismissible(
                                key: Key(squad.id),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  FirebaseFirestore.instance
                                      .collection('squads')
                                      .doc(squad.id)
                                      .delete();
                                },
                                child: GestureDetector(
                                  onLongPress: () =>
                                      _showEditSquadSheet(context, squad),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatScreen(squad: squad),
                                    ),
                                  ),
                                  child: SquadCard(
                                    squad: squad,
                                    onEdit: () =>
                                        _showEditSquadSheet(context, squad),
                                    onDelete: () => FirebaseFirestore.instance
                                        .collection('squads')
                                        .doc(squad.id)
                                        .delete(),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(
                      height: 100,
                    ), // Spasi untuk Bottom Navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndCreateBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COMMUNITY HUB',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              const TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: 'Find your\n'),
                  TextSpan(
                    text: 'squad.',
                    style: TextStyle(color: AppColors.neonYellow),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _showJoinCodeDialog(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.key, color: Colors.white54, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showCreateSquadSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonYellow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonYellow.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.black, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showJoinCodeDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Join Private Squad',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: codeController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter squad code',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final snapshot = await FirebaseFirestore.instance
                    .collection('squads')
                    .where('squadCode', isEqualTo: codeController.text.trim())
                    .limit(1)
                    .get();

                if (snapshot.docs.isNotEmpty) {
                  final docRef = snapshot.docs.first.reference;
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await docRef.update({
                      'memberIds': FieldValue.arrayUnion([user.uid]),
                    });
                    await docRef.collection('members').doc(user.uid).set({
                      'name': user.displayName ?? 'Player',
                      'role': 'READY',
                      'image': user.photoURL ?? 'https://images.unsplash.com/photo-1580983696793-3500a8a0b7f4?w=100',
                      'isReady': true,
                    });
                  }
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        squad: SquadModel.fromFirestore(snapshot.docs.first),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kode tidak valid atau Skuad tidak ditemukan',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateSquadSheet(BuildContext context) {
    final nameController = TextEditingController();
    final gameController = TextEditingController();
    final modeController = TextEditingController();
    bool isPrivate = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a squad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSquadTextField(nameController, 'Squad name'),
                  const SizedBox(height: 12),
                  _buildSquadTextField(gameController, 'Game'),
                  const SizedBox(height: 12),
                  _buildSquadTextField(modeController, 'Mode'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Private Squad',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Only people with the invite code can join',
                      style: TextStyle(color: Colors.white54),
                    ),
                    value: isPrivate,
                    activeColor: AppColors.neonYellow,
                    onChanged: (value) => setState(() => isPrivate = value),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonYellow,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final generatedCode = isPrivate
                          ? (100000 + Random().nextInt(900000)).toString()
                          : '';
                      final squad = SquadModel(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        game: gameController.text.trim(),
                        mode: modeController.text.trim(),
                        onlineCount: 1,
                        totalMembers: 5,
                        memberIds: [
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                        ],
                        iconAsset: 'crosshair',
                        accentColorHex: '0xFFDFFF00',
                        isPrivate: isPrivate,
                        squadCode: generatedCode,
                      );
                      final docRef = await FirebaseFirestore.instance
                          .collection('squads')
                          .add(squad.toFirestore());
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        await docRef
                            .collection('members')
                            .doc(currentUser.uid)
                            .set({
                              'name': currentUser.displayName ?? 'Player',
                              'role': 'LEADER',
                              'image': currentUser.photoURL ?? 'https://images.unsplash.com/photo-1580983696793-3500a8a0b7f4?w=100',
                              'isReady': true,
                            });
                      }
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(squad: squad),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSquadSheet(BuildContext context, SquadModel squad) {
    final nameController = TextEditingController(text: squad.name);
    final gameController = TextEditingController(text: squad.game);
    final modeController = TextEditingController(text: squad.mode);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit squad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSquadTextField(nameController, 'Squad name'),
              const SizedBox(height: 12),
              _buildSquadTextField(gameController, 'Game'),
              const SizedBox(height: 12),
              _buildSquadTextField(modeController, 'Mode'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonYellow,
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  final updatedSquad = SquadModel(
                    id: squad.id,
                    name: nameController.text.trim(),
                    game: gameController.text.trim(),
                    mode: modeController.text.trim(),
                    onlineCount: squad.onlineCount,
                    totalMembers: squad.totalMembers,
                    iconAsset: squad.iconAsset,
                    accentColorHex: squad.accentColorHex,
                  );
                  await FirebaseFirestore.instance
                      .collection('squads')
                      .doc(squad.id)
                      .update(updatedSquad.toFirestore());
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSquadTextField(
    TextEditingController controller,
    String hintText,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.neonYellow),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white38, size: 20),
          hintText: 'Search squads or games',
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
          // Placeholder untuk icon 'Cmd K'
          suffixIcon: Icon(
            Icons.keyboard_command_key,
            color: Colors.white24,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isSelected = filter == activeFilter;
          return GestureDetector(
            onTap: () => setState(() => activeFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.neonYellow.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.neonYellow.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  if (filter == 'Playing now') ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? AppColors.neonYellow : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Squads for you',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '04 active',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
        Text(
          'View all',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
