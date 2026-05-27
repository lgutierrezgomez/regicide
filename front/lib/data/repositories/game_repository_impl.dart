import '../../core/l10n/app_error_messages.dart';
import '../../domain/entities/game_state_view.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/room_socket.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._socket);

  final RoomSocket _socket;

  @override
  Stream<GameStateView> get stateUpdates => _socket.gameStateUpdates;

  @override
  Stream<Room> get roomUpdates => _socket.roomUpdates;

  @override
  Stream<String> get errors => _socket.errors.map(
        (e) => AppErrorMessages.fromSocket(
          code: e.code,
          fallback: e.message,
        ),
      );

  @override
  Stream<void> get connectionLost => _socket.connectionLost;

  @override
  Future<void> connect(RoomSession session) => _socket.connect(session);

  @override
  Future<void> disconnect() => _socket.disconnect();

  @override
  void playCards(List<String> cardIds) => _socket.playCards(cardIds);

  @override
  void yieldTurn() => _socket.yieldTurn();

  @override
  void discardCards(List<String> cardIds) => _socket.discardCards(cardIds);

  @override
  void chooseNextPlayer(String nextPlayerId) =>
      _socket.chooseNextPlayer(nextPlayerId);

  @override
  void soloJester() => _socket.soloJester();

  @override
  void returnToLobby() => _socket.returnToLobby();

  @override
  void restartGame() => _socket.restartGame();
}
