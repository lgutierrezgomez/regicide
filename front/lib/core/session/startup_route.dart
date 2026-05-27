import '../errors/api_exception.dart';
import '../router/app_routes.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/repositories/session_repository.dart';

/// Where to open the app after launch or hot reload (uses saved session + REST).
class StartupRouteResolver {
  StartupRouteResolver({
    required SessionRepository sessionRepository,
    required RoomRepository roomRepository,
  })  : _sessionRepository = sessionRepository,
        _roomRepository = roomRepository;

  final SessionRepository _sessionRepository;
  final RoomRepository _roomRepository;

  static const roomStatusInGame = 'in_game';

  Future<String> resolve() async {
    final session = await _sessionRepository.loadSession();
    if (session == null) {
      return AppRoutes.home;
    }

    try {
      final room = await _roomRepository.fetchRoom(session.roomCode);
      final stillMember = room.players.any((p) => p.id == session.playerId);
      if (!stillMember) {
        await _sessionRepository.clearSession();
        return AppRoutes.home;
      }
      if (room.status == roomStatusInGame) {
        return AppRoutes.game;
      }
      return AppRoutes.lobby;
    } on ApiException catch (e) {
      if (e.code == 'ROOM_NOT_FOUND') {
        await _sessionRepository.clearSession();
      }
      return AppRoutes.home;
    } catch (_) {
      // Server down — stay on home; user can retry join.
      return AppRoutes.home;
    }
  }
}
