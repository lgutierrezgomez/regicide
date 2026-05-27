import '../entities/game_state_view.dart';
import '../entities/room.dart';
import '../entities/room_session.dart';

abstract class GameRepository {
  Stream<GameStateView> get stateUpdates;
  Stream<Room> get roomUpdates;
  Stream<String> get errors;
  Stream<void> get connectionLost;

  Future<void> connect(RoomSession session);
  Future<void> disconnect();

  void playCards(List<String> cardIds);
  void yieldTurn();
  void discardCards(List<String> cardIds);
  void chooseNextPlayer(String nextPlayerId);
  void soloJester();
  void returnToLobby();
  void restartGame();
}
