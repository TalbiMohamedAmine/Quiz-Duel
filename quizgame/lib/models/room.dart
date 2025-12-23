import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String hostId;
  final String hostName;
  final String code; // short code to join
  final int maxPlayers;
  final int playerCount;
  final String state; // waiting / playing / finished
  final DateTime createdAt;

  Room({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.code,
    required this.maxPlayers,
    required this.playerCount,
    required this.state,
    required this.createdAt,
  });

  factory Room.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Room(
      id: doc.id,
      hostId: data['hostId'] as String,
      hostName: data['hostName'] as String,
      code: data['code'] as String,
      maxPlayers: data['maxPlayers'] as int,
      playerCount: data['playerCount'] as int,
      state: data['state'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'hostId': hostId,
    'hostName': hostName,
    'code': code,
    'maxPlayers': maxPlayers,
    'playerCount': playerCount,
    'state': state,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
