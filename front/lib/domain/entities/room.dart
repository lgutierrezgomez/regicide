import 'package:equatable/equatable.dart';
import 'player.dart';

class Room extends Equatable {
  const Room({
    required this.code,
    required this.status,
    required this.hostPlayerId,
    required this.players,
    required this.maxPlayers,
  });

  final String code;
  final String status;
  final String hostPlayerId;
  final List<Player> players;
  final int maxPlayers;

  int get playerCount => players.length;

  @override
  List<Object?> get props => [code, status, hostPlayerId, players, maxPlayers];
}
