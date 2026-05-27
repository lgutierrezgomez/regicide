import 'package:equatable/equatable.dart';

import '../../../domain/entities/room.dart';
import '../../../domain/entities/room_session.dart';

enum LobbyConnectionStatus { connecting, connected, failed }

enum LobbyStatus {
  loading,
  ready,
  startingGame,
  navigateToGame,
  failure,
  noSession
}

class LobbyState extends Equatable {
  const LobbyState({
    this.status = LobbyStatus.loading,
    this.session,
    this.room,
    this.connectionStatus = LobbyConnectionStatus.connecting,
    this.errorMessage,
  });

  final LobbyStatus status;
  final RoomSession? session;
  final Room? room;
  final LobbyConnectionStatus connectionStatus;
  final String? errorMessage;

  bool get isHost => session?.isHost ?? false;

  bool get canStartGame =>
      isHost &&
      room?.status == 'lobby' &&
      connectionStatus == LobbyConnectionStatus.connected &&
      status != LobbyStatus.startingGame;

  LobbyState copyWith({
    LobbyStatus? status,
    RoomSession? session,
    Room? room,
    LobbyConnectionStatus? connectionStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LobbyState(
      status: status ?? this.status,
      session: session ?? this.session,
      room: room ?? this.room,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        room,
        connectionStatus,
        errorMessage,
      ];
}
