import 'package:equatable/equatable.dart';

sealed class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object?> get props => [];
}

final class LobbyStarted extends LobbyEvent {
  const LobbyStarted();
}

final class LobbyStartGameRequested extends LobbyEvent {
  const LobbyStartGameRequested();
}

final class LobbyRoomUpdated extends LobbyEvent {
  const LobbyRoomUpdated(this.room);

  final dynamic room;

  @override
  List<Object?> get props => [room];
}

final class LobbyGameStarted extends LobbyEvent {
  const LobbyGameStarted(this.room);

  final dynamic room;

  @override
  List<Object?> get props => [room];
}

final class LobbySocketError extends LobbyEvent {
  const LobbySocketError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class LobbyDisconnected extends LobbyEvent {
  const LobbyDisconnected();
}

final class LobbyReconnectRequested extends LobbyEvent {
  const LobbyReconnectRequested();
}
