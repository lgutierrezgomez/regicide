import '../../domain/entities/room.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_api.dart';

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._api);

  final RoomApi _api;

  @override
  Future<RoomSession> createRoom({required String displayName}) async {
    final response = await _api.createRoom(displayName.trim());
    return response.toSession(displayName.trim());
  }

  @override
  Future<Room> fetchRoom(String roomCode) => _api.fetchRoom(roomCode);

  @override
  Future<RoomSession> joinRoom({
    required String roomCode,
    required String displayName,
  }) async {
    final response = await _api.joinRoom(roomCode, displayName.trim());
    return response.toSession(displayName.trim());
  }
}
