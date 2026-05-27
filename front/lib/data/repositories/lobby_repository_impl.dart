import '../../core/l10n/app_error_messages.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/lobby_repository.dart';
import '../datasources/room_socket.dart';

class LobbyRepositoryImpl implements LobbyRepository {
  LobbyRepositoryImpl(this._socket);

  final RoomSocket _socket;

  @override
  Stream<Room> get roomUpdates => _socket.roomUpdates;

  @override
  Stream<Room> get gameStarted => _socket.gameStarted;

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
  void startGame() => _socket.startGame();
}
