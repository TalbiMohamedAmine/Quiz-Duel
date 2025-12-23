import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final _firestore = FirebaseFirestore.instance;

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<Room> createRoom({
    required String hostId,
    required String hostName,
    int maxPlayers = 10,
  }) async {
    final code = _generateCode();

    final docRef = _firestore.collection('rooms').doc();

    final room = Room(
      id: docRef.id,
      hostId: hostId,
      hostName: hostName,
      code: code,
      maxPlayers: maxPlayers,
      playerCount: 1,
      state: 'waiting',
      createdAt: DateTime.now(),
    );

    await docRef.set(room.toFirestore());

    return room;
  }
}
