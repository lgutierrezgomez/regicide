import '../../domain/entities/player.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_session.dart';

class RoomResponse {
  RoomResponse({required this.room, required this.playerId});

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    final roomJson = json['room'] as Map<String, dynamic>;
    return RoomResponse(
      room: RoomDto.fromJson(roomJson).toEntity(),
      playerId: json['playerId'] as String,
    );
  }

  final Room room;
  final String playerId;

  RoomSession toSession(String displayName) {
    return RoomSession(
      roomCode: room.code,
      playerId: playerId,
      displayName: displayName,
      isHost: room.hostPlayerId == playerId,
    );
  }
}

class RoomDto {
  RoomDto({
    required this.code,
    required this.status,
    required this.hostPlayerId,
    required this.players,
    required this.maxPlayers,
  });

  factory RoomDto.fromJson(Map<String, dynamic> json) {
    final playersJson = json['players'] as List<dynamic>? ?? [];
    return RoomDto(
      code: json['code'] as String,
      status: json['status'] as String,
      hostPlayerId: json['hostPlayerId'] as String,
      maxPlayers: json['maxPlayers'] as int? ?? 4,
      players: playersJson
          .map((p) => PlayerDto.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  final String code;
  final String status;
  final String hostPlayerId;
  final List<PlayerDto> players;
  final int maxPlayers;

  Room toEntity() {
    return Room(
      code: code,
      status: status,
      hostPlayerId: hostPlayerId,
      players: players.map((p) => p.toEntity()).toList(),
      maxPlayers: maxPlayers,
    );
  }
}

class PlayerDto {
  PlayerDto({
    required this.id,
    required this.displayName,
    this.connected = false,
  });

  factory PlayerDto.fromJson(Map<String, dynamic> json) {
    return PlayerDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      connected: json['connected'] as bool? ?? false,
    );
  }

  final String id;
  final String displayName;
  final bool connected;

  Player toEntity() => Player(
        id: id,
        displayName: displayName,
        connected: connected,
      );
}
