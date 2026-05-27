import 'package:equatable/equatable.dart';

import '../../../domain/entities/game_state_view.dart';
import '../../../domain/entities/room.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  const GameStarted();
}

class GameStateReceived extends GameEvent {
  const GameStateReceived(this.view);

  final GameStateView view;

  @override
  List<Object?> get props => [view];
}

class GameSocketError extends GameEvent {
  const GameSocketError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class GameCardToggled extends GameEvent {
  const GameCardToggled(this.cardId);

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}

class GameSelectionCleared extends GameEvent {
  const GameSelectionCleared();
}

class GamePlayRequested extends GameEvent {
  const GamePlayRequested();
}

class GameYieldRequested extends GameEvent {
  const GameYieldRequested();
}

class GameDiscardRequested extends GameEvent {
  const GameDiscardRequested();
}

class GameChooseNextRequested extends GameEvent {
  const GameChooseNextRequested(this.nextPlayerId);

  final String nextPlayerId;

  @override
  List<Object?> get props => [nextPlayerId];
}

class GameSoloJesterRequested extends GameEvent {
  const GameSoloJesterRequested();
}

class GameDisconnected extends GameEvent {
  const GameDisconnected();
}

class GameReconnectRequested extends GameEvent {
  const GameReconnectRequested();
}

class GameRoomUpdated extends GameEvent {
  const GameRoomUpdated(this.room);

  final Room room;

  @override
  List<Object?> get props => [room];
}

class GameReturnToLobbyRequested extends GameEvent {
  const GameReturnToLobbyRequested();
}

class GameRestartRequested extends GameEvent {
  const GameRestartRequested();
}
