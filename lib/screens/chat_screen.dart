import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_data.dart';
import '../models/squad_model.dart';
import '../widgets/chat_match_card.dart';
import '../widgets/chat_components.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  final SquadModel squad;

  const ChatScreen({super.key, required this.squad});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static final Map<String, DateTime> _lastPingTimes = {};

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _sendMessage(String text, {bool isPing = false}) async {
    if (!isPing && text.trim().isEmpty) return;

    if (isPing) {
      final lastPingTime = _lastPingTimes[widget.squad.id];
      if (lastPingTime != null &&
          DateTime.now().difference(lastPingTime) <
              const Duration(minutes: 5)) {
        final int remainingSeconds =
            300 - DateTime.now().difference(lastPingTime).inSeconds;
        final int minutes = remainingSeconds ~/ 60;
        final int seconds = remainingSeconds % 60;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tunggu $minutes menit $seconds detik lagi untuk nge-PING skuad!',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _lastPingTimes[widget.squad.id] = DateTime.now();
    }

    final String finalMessage = isPing ? '___PING_SQUAD___' : text.trim();

    await FirebaseFirestore.instance
        .collection('squads')
        .doc(widget.squad.id)
        .collection('messages')
        .add({
          'text': finalMessage,
          'author': FirebaseAuth.instance.currentUser?.displayName ?? 'Player',
          'authorId': FirebaseAuth.instance.currentUser?.uid,
          'authorImage':
              (FirebaseAuth.instance.currentUser?.photoURL != null &&
                  FirebaseAuth.instance.currentUser!.photoURL!.isNotEmpty)
              ? FirebaseAuth.instance.currentUser!.photoURL!
              : 'https://ui-avatars.com/api/?name=${FirebaseAuth.instance.currentUser?.displayName ?? "User"}&background=random',
          'time': TimeOfDay.now().format(context),
          'timestamp': FieldValue.serverTimestamp(),
        });

    if (isPing) {
      try {
        // 1. Ambil daftar member skuad
        final squadDoc = await FirebaseFirestore.instance
            .collection('squads')
            .doc(widget.squad.id)
            .get();
        final List<dynamic> memberIds = squadDoc.data()?['memberIds'] ?? [];

        // 2. Kumpulkan token teman-teman (kecuali diri sendiri)
        final List<String> targetTokens = [];
        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

        for (final uid in memberIds) {
          if (uid == currentUserUid) continue;
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid as String)
              .get();
          final token = userDoc.data()?['fcmToken'];
          if (token != null) targetTokens.add(token as String);
        }

        // 3. Tembak ke Backend Vercel jika ada teman yang punya token
        if (targetTokens.isNotEmpty) {
          final url = Uri.parse('https://otw-backend.vercel.app/api/ping');
          await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'targetTokens': targetTokens,
              'senderName':
                  FirebaseAuth.instance.currentUser?.displayName ?? 'Player',
            }),
          );
        }
      } catch (e) {
        debugPrint('Error mengirim notifikasi Ping: $e');
      }
    }

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050609),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(color: const Color(0xFF07080C)),
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFDFFF00),
                  onRefresh: _handleRefresh,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ChatSquadStatus(squadId: widget.squad.id),
                      const ChatDateDivider(),

                      // Widget Stateful yang sudah dipisah
                      const ChatMatchCard(),

                      const SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('squads')
                            .doc(widget.squad.id)
                            .collection('messages')
                            .orderBy('time')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final messages = snapshot.hasData
                              ? snapshot.data!.docs.map(
                                  (doc) => doc.data() as Map<String, dynamic>,
                                )
                              : dummyMessages;

                          return Column(
                            children: messages
                                .map((msg) => ChatBubbleItem(msg: msg))
                                .toList(),
                          );
                        },
                      ),
                      const ChatTypingIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildChatComposer()),
          Positioned(
            bottom: 140,
            right: 20,
            child: GestureDetector(
              onTap: () => _sendMessage('', isPing: true),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFDFFF00),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFDFFF00).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'O',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final squadInitials = widget.squad.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();
    final photoUrl =
        (FirebaseAuth.instance.currentUser?.photoURL != null &&
            FirebaseAuth.instance.currentUser!.photoURL!.isNotEmpty)
        ? FirebaseAuth.instance.currentUser!.photoURL!
        : 'https://ui-avatars.com/api/?name=${FirebaseAuth.instance.currentUser?.displayName ?? "User"}&background=DFFF00&color=000';

    return AppBar(
      backgroundColor: const Color(0xFF090A0F).withValues(alpha: 0.9),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFFF54), Color(0xFFB8DB00)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                squadInitials,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.squad.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7DFF).withValues(alpha: 0.1),
                      border: Border.all(
                        color: const Color(0xFF4A7DFF).withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.squad.game,
                      style: TextStyle(
                        color: Color(0xFF82A4FF),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.circle, color: Color(0xFF5CFF8D), size: 6),
                  SizedBox(width: 4),
                  Text(
                    '4 players online',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.headphones, color: Color(0xFFDFFF00)),
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
    );
  }

  Widget _buildChatComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF090A0F),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: ['On my way', 'One more?', 'GG']
                  .map(
                    (reply) => Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 12),
                      child: GestureDetector(
                        onTap: () => _sendMessage(reply),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            reply,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _sendMessage('', isPing: true),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFFF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message the squad...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_messageController.text),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFFF00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
