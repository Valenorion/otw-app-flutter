import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderName;
  final bool isMe; // true = pesan dari kita, false = pesan dari teman
  final String time;

  Message({
    required this.id,
    required this.text,
    required this.senderName,
    required this.isMe,
    required this.time,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Message(
      id: doc.id,
      text: data['text'] as String,
      senderName: data['senderName'] as String,
      isMe: data['isMe'] as bool,
      time: data['time'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'text': text, 'senderName': senderName, 'isMe': isMe, 'time': time};
  }
}

// Data Dummy / Placeholder
List<Message> dummyMessages = [
  Message(
    id: '1',
    text: 'Udah pada login belum?',
    senderName: 'Kamu',
    isMe: true,
    time: '21:40',
  ),
  Message(
    id: '2',
    text: 'Gue udah di lobby nih',
    senderName: 'K',
    isMe: false,
    time: '21:41',
  ),
  Message(
    id: '3',
    text: 'Bentar, lagi update 50MB 😭',
    senderName: 'J',
    isMe: false,
    time: '21:42',
  ),
  Message(
    id: '4',
    text: 'Buruan, keburu ngantuk wkwk',
    senderName: 'Kamu',
    isMe: true,
    time: '21:42',
  ),
  Message(
    id: '5',
    text: 'Aman, OTW ready!',
    senderName: 'A',
    isMe: false,
    time: '21:43',
  ),
];
