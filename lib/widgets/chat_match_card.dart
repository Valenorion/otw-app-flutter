import 'package:flutter/material.dart';

class ChatMatchCard extends StatefulWidget {
  const ChatMatchCard({super.key});

  @override
  State<ChatMatchCard> createState() => _ChatMatchCardState();
}

class _ChatMatchCardState extends State<ChatMatchCard> {
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A7DFF).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4A7DFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_esports, color: Color(0xFFA5BCFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPCOMING SESSION',
                  style: TextStyle(
                    color: Color(0xFF657AB6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Ranked grind',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Tonight at 10:00 PM · SEA Server',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 20,
                        ),
                        Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isReady = !isReady;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isReady
                              ? const Color(0xFFDFFF00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDFFF00)),
                        ),
                        child: Text(
                          isReady ? "I'M READY" : "JOIN SESSION",
                          style: TextStyle(
                            color: isReady
                                ? Colors.black
                                : const Color(0xFFAABD23),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
