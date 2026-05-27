import '../entities/room_session.dart';
import '../repositories/room_repository.dart';
import '../repositories/session_repository.dart';

class JoinRoom {
  JoinRoom(this._rooms, this._session);

  final RoomRepository _rooms;
  final SessionRepository _session;

  Future<RoomSession> call({
    required String roomCode,
    required String displayName,
  }) async {
    final session = await _rooms.joinRoom(
      roomCode: roomCode,
      displayName: displayName,
    );
    await _session.saveSession(session);
    return session;
  }
}
