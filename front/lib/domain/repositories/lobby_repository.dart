import '../entities/room.dart';
import '../entities/room_session.dart';

abstract class LobbyRepository {
  Stream<Room> get roomUpdates;
  Stream<Room> get gameStarted;
  Stream<String> get errors;
  Stream<void> get connectionLost;

  Future<void> connect(RoomSession session);
  Future<void> disconnect();
  void startGame();
}
