import '../entities/room_session.dart';
import '../repositories/room_repository.dart';
import '../repositories/session_repository.dart';

class CreateRoom {
  CreateRoom(this._rooms, this._session);

  final RoomRepository _rooms;
  final SessionRepository _session;

  Future<RoomSession> call({required String displayName}) async {
    final session = await _rooms.createRoom(displayName: displayName);
    await _session.saveSession(session);
    return session;
  }
}
