import '../entities/room_session.dart';

abstract class SessionRepository {
  Future<void> saveSession(RoomSession session);
  Future<RoomSession?> loadSession();
  Future<void> clearSession();
}
