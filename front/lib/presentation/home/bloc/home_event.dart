import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeDisplayNameChanged extends HomeEvent {
  const HomeDisplayNameChanged(this.displayName);

  final String displayName;

  @override
  List<Object?> get props => [displayName];
}

final class HomeRoomCodeChanged extends HomeEvent {
  const HomeRoomCodeChanged(this.roomCode);

  final String roomCode;

  @override
  List<Object?> get props => [roomCode];
}

final class HomeCreateRoomRequested extends HomeEvent {
  const HomeCreateRoomRequested();
}

final class HomeJoinRoomRequested extends HomeEvent {
  const HomeJoinRoomRequested();
}
