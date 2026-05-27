import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/config/app_config.dart';
import '../../core/errors/socket_exception.dart';
import '../../data/models/game_state_dto.dart';
import '../../data/models/room_response.dart';
import '../../domain/entities/game_state_view.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_session.dart';

/// Socket.IO for lobby + in-game actions (one connection per room session).
///
/// Reference-counted so lobby → game navigation does not disconnect while the
/// game screen is still starting.
class RoomSocket {
  RoomSocket({AppConfig? config}) : _config = config ?? AppConfig.instance;

  final AppConfig _config;
  io.Socket? _socket;
  RoomSession? _activeSession;
  int _refCount = 0;
  GameStateView? _lastGameState;

  final _roomUpdates = StreamController<Room>.broadcast();
  final _gameStarted = StreamController<Room>.broadcast();
  final _gameState = StreamController<GameStateView>.broadcast();
  final _errors = StreamController<SocketFailure>.broadcast();
  final _connectionLost = StreamController<void>.broadcast();

  Stream<Room> get roomUpdates => _roomUpdates.stream;
  Stream<Room> get gameStarted => _gameStarted.stream;
  Stream<GameStateView> get gameStateUpdates => _gameState.stream;
  Stream<SocketFailure> get errors => _errors.stream;
  Stream<void> get connectionLost => _connectionLost.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect(RoomSession session) async {
    if (_socket != null &&
        _socket!.connected &&
        _activeSession != null &&
        _sameSession(_activeSession!, session)) {
      _refCount++;
      _replayLastGameState();
      return;
    }

    await _disconnectInternal();
    await _connectInternal(session);
    _activeSession = session;
    _refCount = 1;
  }

  Future<void> disconnect() async {
    if (_refCount <= 0) {
      return;
    }
    _refCount--;
    if (_refCount <= 0) {
      _refCount = 0;
      await _disconnectInternal();
      _activeSession = null;
    }
  }

  void startGame() => _emit('game:start');

  void returnToLobby() => _emit('game:returnToLobby');

  void restartGame() => _emit('game:restart');

  void playCards(List<String> cardIds) =>
      _emit('game:play', {'cardIds': cardIds});

  void yieldTurn() => _emit('game:yield');

  void discardCards(List<String> cardIds) =>
      _emit('game:discard', {'cardIds': cardIds});

  void chooseNextPlayer(String nextPlayerId) =>
      _emit('game:chooseNext', {'nextPlayerId': nextPlayerId});

  void soloJester() => _emit('game:soloJester');

  /// Hot reload / dev reassemble: drop socket without closing stream controllers.
  void resetForHotReload() {
    _refCount = 0;
    _activeSession = null;
    _disconnectInternal();
  }

  void dispose() {
    _refCount = 0;
    _disconnectInternal();
    _roomUpdates.close();
    _gameStarted.close();
    _gameState.close();
    _errors.close();
  }

  bool _sameSession(RoomSession a, RoomSession b) =>
      a.roomCode.toUpperCase() == b.roomCode.toUpperCase() &&
      a.playerId == b.playerId;

  void _emit(String event, [dynamic data]) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      _errors.add(const SocketFailure('Not connected to server'));
      return;
    }
    if (data == null) {
      socket.emit(event);
    } else {
      socket.emit(event, data);
    }
  }

  Future<void> _connectInternal(RoomSession session) async {
    final completer = Completer<void>();
    var completed = false;

    _socket = io.io(
      _config.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({
            'roomCode': session.roomCode,
            'playerId': session.playerId,
          })
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    void completeOk() {
      if (!completed) {
        completed = true;
        completer.complete();
      }
    }

    void completeError(Object error) {
      if (!completed) {
        completed = true;
        completer.completeError(error);
      }
    }

    _socket!
      ..onConnect((_) => completeOk())
      ..onDisconnect((_) {
        if (_refCount > 0) {
          _connectionLost.add(null);
        }
      })
      ..onConnectError((err) => completeError(SocketFailure('$err')))
      ..on('lobby:updated', _onLobbyUpdated)
      ..on('game:started', _onGameStarted)
      ..on('game:state', _onGameState)
      ..on('error', _onServerError)
      ..connect();

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => throw const SocketFailure('Connection timeout'),
    );
  }

  Future<void> _disconnectInternal() async {
    _socket?.dispose();
    _socket = null;
    _lastGameState = null;
  }

  void _replayLastGameState() {
    final cached = _lastGameState;
    if (cached != null) {
      scheduleMicrotask(() => _gameState.add(cached));
    }
  }

  void _onLobbyUpdated(dynamic data) {
    final room = _parseRoomPayload(data);
    if (room != null) {
      _roomUpdates.add(room);
    }
  }

  void _onGameStarted(dynamic data) {
    final room = _parseRoomPayload(data);
    if (room != null) {
      _gameStarted.add(room);
    }
  }

  void _onGameState(dynamic data) {
    if (data is! Map) {
      return;
    }
    try {
      final view =
          GameStateDto.fromJson(Map<String, dynamic>.from(data)).toEntity();
      _lastGameState = view;
      _gameState.add(view);
    } catch (_) {
      // Ignore malformed payloads.
    }
  }

  void _onServerError(dynamic data) {
    if (data is Map) {
      final message = data['message']?.toString() ?? 'Server error';
      _errors.add(SocketFailure(message, code: data['code']?.toString()));
    }
  }

  Room? _parseRoomPayload(dynamic data) {
    if (data is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(data);
    final roomJson = map['room'];
    if (roomJson is Map) {
      return RoomDto.fromJson(Map<String, dynamic>.from(roomJson)).toEntity();
    }
    return null;
  }
}
