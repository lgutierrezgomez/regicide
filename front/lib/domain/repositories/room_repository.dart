import '../entities/room.dart';
import '../entities/room_session.dart';

abstract class RoomRepository {
  Future<RoomSession> createRoom({required String displayName});
  Future<RoomSession> joinRoom({
    required String roomCode,
    required String displayName,
  });
  Future<Room> fetchRoom(String roomCode);
}
