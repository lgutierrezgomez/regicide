import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/room_session.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  static const _keyRoomCode = 'room_code';
  static const _keyPlayerId = 'player_id';
  static const _keyDisplayName = 'display_name';
  static const _keyIsHost = 'is_host';

  @override
  Future<void> saveSession(RoomSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoomCode, session.roomCode);
    await prefs.setString(_keyPlayerId, session.playerId);
    await prefs.setString(_keyDisplayName, session.displayName);
    await prefs.setBool(_keyIsHost, session.isHost);
  }

  @override
  Future<RoomSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final roomCode = prefs.getString(_keyRoomCode);
    final playerId = prefs.getString(_keyPlayerId);
    final displayName = prefs.getString(_keyDisplayName);
    if (roomCode == null || playerId == null || displayName == null) {
      return null;
    }
    return RoomSession(
      roomCode: roomCode,
      playerId: playerId,
      displayName: displayName,
      isHost: prefs.getBool(_keyIsHost) ?? false,
    );
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRoomCode);
    await prefs.remove(_keyPlayerId);
    await prefs.remove(_keyDisplayName);
    await prefs.remove(_keyIsHost);
  }
}
