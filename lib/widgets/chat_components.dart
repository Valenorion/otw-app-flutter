import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatSquadStatus extends StatelessWidget {
  final String squadId;

  const ChatSquadStatus({super.key, required this.squadId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SQUAD STATUS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '3/5 READY',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('squads')
                .doc(squadId)
                .collection('members')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final bool isMember = snapshot.data!.docs.any(
                  (doc) => doc.id == FirebaseAuth.instance.currentUser?.uid,
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...snapshot.data!.docs.map(
                      (doc) => ChatPlayerAvatar(
                        uid: doc.id,
                        name: doc['name'] as String,
                        role: doc['role'] as String,
                        imageUrl: doc['image'] as String,
                        isReady: doc['isReady'] as bool,
                        squadId: squadId,
                      ),
                    ),
                    if (!isMember) ChatInviteAvatar(squadId: squadId),
                    if (isMember) ChatLeaveAvatar(squadId: squadId),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [ChatInviteAvatar(squadId: squadId)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatPlayerAvatar extends StatelessWidget {
  final String uid, name, role, imageUrl, squadId;
  final bool isReady;

  const ChatPlayerAvatar({
    super.key,
    required this.uid,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.squadId,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (uid == FirebaseAuth.instance.currentUser?.uid) {
          FirebaseFirestore.instance
              .collection('squads')
              .doc(squadId)
              .collection('members')
              .doc(uid)
              .update({
                'isReady': !isReady,
                'role': !isReady ? 'READY' : 'CASUAL',
              });
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                  color: Colors.white12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.white54),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isReady
                        ? const Color(0xFFDFFF00)
                        : const Color(0xFF5CFF8D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF050609),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            role,
            style: TextStyle(
              color: isReady ? const Color(0xFF92A522) : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInviteAvatar extends StatelessWidget {
  final String squadId;

  const ChatInviteAvatar({super.key, required this.squadId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection('squads')
            .doc(squadId)
            .collection('members')
            .doc(user.uid)
            .set({
              'name': user.displayName ?? 'Player',
              'role': 'READY',
              'image': (user.photoURL != null && user.photoURL!.isNotEmpty)
                  ? user.photoURL!
                  : 'https://ui-avatars.com/api/?name=${user.displayName ?? "User"}&background=random',
              'isReady': true,
            });

        await FirebaseFirestore.instance
            .collection('squads')
            .doc(squadId)
            .update({
              'memberIds': FieldValue.arrayUnion([user.uid]),
            });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey, style: BorderStyle.solid),
            ),
            child: const Icon(Icons.add, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '+1 SLOT',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class ChatLeaveAvatar extends StatelessWidget {
  final String squadId;

  const ChatLeaveAvatar({super.key, required this.squadId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection('squads')
            .doc(squadId)
            .collection('members')
            .doc(user.uid)
            .delete();

        await FirebaseFirestore.instance
            .collection('squads')
            .doc(squadId)
            .update({
              'memberIds': FieldValue.arrayRemove([user.uid]),
            });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red),
            ),
            child: const Icon(Icons.exit_to_app, color: Colors.red),
          ),
          const SizedBox(height: 8),
          const Text(
            'Leave',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'EXIT SQUAD',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class ChatDateDivider extends StatelessWidget {
  const ChatDateDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'TODAY',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.white12)),
        ],
      ),
    );
  }
}

class ChatBubbleItem extends StatefulWidget {
  final Map<String, dynamic> msg;

  const ChatBubbleItem({super.key, required this.msg});

  @override
  State<ChatBubbleItem> createState() => _ChatBubbleItemState();
}

class _ChatBubbleItemState extends State<ChatBubbleItem> {
  @override
  void initState() {
    super.initState();
    if (widget.msg['text'] == '___PING_SQUAD___') {
      final player = AudioPlayer();
      player.play(AssetSource('audio/ping_sound.mp3'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final isPing = widget.msg['text'] == '___PING_SQUAD___';
    if (isPing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFFF00),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDFFF00).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'O',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'OTW.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${msg['author']} nge-PING skuad! Gas login sekarang!',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final avatarUrl =
        msg['authorImage'] ??
        'https://ui-avatars.com/api/?name=User&background=random';
    final isMine = msg['authorId'] == FirebaseAuth.instance.currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine) ...[
            ClipOval(
              child: Image.network(
                avatarUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 28,
                  height: 28,
                  color: Colors.white12,
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    msg['author'],
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMine ? null : const Color(0xFF181A21),
                  gradient: isMine
                      ? const LinearGradient(
                          colors: [Color(0xFF2859C9), Color(0xFF23469F)],
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMine
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomRight: isMine
                        ? Radius.zero
                        : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg['text'],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg['time'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              if (msg.containsKey('reaction')) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12140E),
                    border: Border.all(
                      color: const Color(0xFFDFFF00).withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg['reaction'],
                    style: const TextStyle(
                      color: Color(0xFFDFFF00),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1580935727530-99e8732bc21e?w=100',
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Jett is typing...',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
