import 'package:flutter/material.dart';

import '../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.75, // Maksimal lebar chat 75%
        ),
        decoration: BoxDecoration(
          color: message.isMe
              ? const Color(0xFFDFFF00)
              : const Color(0xFF16181D),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: message.isMe ? null : Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe) ...[
              Text(
                message.senderName,
                style: const TextStyle(
                  color: Color(0xFFDFFF00),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                message.time,
                style: TextStyle(
                  color: message.isMe ? Colors.black54 : Colors.grey,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
