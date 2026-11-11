import 'package:cloud_firestore/cloud_firestore.dart';

class SquadModel {
  final String id;
  final String name;
  final String game;
  final String mode;
  final int onlineCount;
  final int totalMembers;
  final String iconAsset;
  final String accentColorHex;
  final bool isPrivate;
  final String squadCode;
  final List<String> memberIds;

  SquadModel({
    required this.id,
    required this.name,
    required this.game,
    required this.mode,
    required this.onlineCount,
    required this.totalMembers,
    required this.iconAsset,
    required this.accentColorHex,
    this.isPrivate = false,
    this.squadCode = '',
    this.memberIds = const [],
  });

  factory SquadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SquadModel(
      id: doc.id,
      name: data['name'] as String,
      game: data['game'] as String,
      mode: data['mode'] as String,
      onlineCount: data['onlineCount'] as int,
      totalMembers: data['totalMembers'] as int,
      iconAsset: data['iconAsset'] as String,
      accentColorHex: data['accentColorHex'] as String,
      isPrivate: (data['isPrivate'] as bool?) ?? false,
      squadCode: (data['squadCode'] as String?) ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'game': game,
      'mode': mode,
      'onlineCount': onlineCount,
      'totalMembers': totalMembers,
      'iconAsset': iconAsset,
      'accentColorHex': accentColorHex,
      'isPrivate': isPrivate,
      'squadCode': squadCode,
      'memberIds': memberIds,
    };
  }
}

// Dummy Data
final List<SquadModel> dummySquads = [
  SquadModel(
    id: '1',
    name: 'Mythic Rush',
    game: 'Valorant',
    mode: 'Ranked',
    onlineCount: 4,
    totalMembers: 8,
    iconAsset: 'crosshair',
    accentColorHex: '0xFFDFFF00', // Neon Yellow
  ),
  SquadModel(
    id: '2',
    name: 'Night Shift',
    game: 'Apex Legends',
    mode: 'Casual',
    onlineCount: 3,
    totalMembers: 6,
    iconAsset: 'bolt',
    accentColorHex: '0xFF8D7CFF', // Purple
  ),
  SquadModel(
    id: '3',
    name: 'Zero Mercy',
    game: 'Call of Duty',
    mode: 'Ranked',
    onlineCount: 5,
    totalMembers: 12,
    iconAsset: 'sword',
    accentColorHex: '0xFFFF7657', // Coral/Red
  ),
];
