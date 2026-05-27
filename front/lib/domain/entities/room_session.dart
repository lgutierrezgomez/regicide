import 'package:equatable/equatable.dart';

/// Local session after create/join — used for lobby socket auth.
class RoomSession extends Equatable {
  const RoomSession({
    required this.roomCode,
    required this.playerId,
    required this.displayName,
    required this.isHost,
  });

  final String roomCode;
  final String playerId;
  final String displayName;
  final bool isHost;

  @override
  List<Object?> get props => [roomCode, playerId, displayName, isHost];
}
