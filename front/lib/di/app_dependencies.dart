import '../core/session/startup_route.dart';
import '../data/datasources/room_api.dart';
import '../data/datasources/room_socket.dart';
import '../data/repositories/game_repository_impl.dart';
import '../data/repositories/lobby_repository_impl.dart';
import '../data/repositories/room_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../domain/repositories/game_repository.dart';
import '../domain/repositories/lobby_repository.dart';
import '../domain/repositories/room_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/usecases/create_room.dart';
import '../domain/usecases/join_room.dart';
import '../presentation/game/bloc/game_bloc.dart';
import '../presentation/game/bloc/game_event.dart';
import '../presentation/home/bloc/home_bloc.dart';
import '../presentation/lobby/bloc/lobby_bloc.dart';
import '../presentation/lobby/bloc/lobby_event.dart';

class AppDependencies {
  AppDependencies._({
    required this.sessionRepository,
    required this.roomRepository,
    required this.roomSocket,
    required this.lobbyRepository,
    required this.gameRepository,
    required this.startupRouteResolver,
    required this.createRoom,
    required this.joinRoom,
  });

  final SessionRepository sessionRepository;
  final RoomRepository roomRepository;
  final RoomSocket roomSocket;
  final LobbyRepository lobbyRepository;
  final GameRepository gameRepository;
  final StartupRouteResolver startupRouteResolver;
  final CreateRoom createRoom;
  final JoinRoom joinRoom;

  static Future<AppDependencies> init() async {
    final roomApi = RoomApi();
    final roomRepository = RoomRepositoryImpl(roomApi);
    final sessionRepository = SessionRepositoryImpl();
    final roomSocket = RoomSocket();

    return AppDependencies._(
      sessionRepository: sessionRepository,
      roomRepository: roomRepository,
      roomSocket: roomSocket,
      lobbyRepository: LobbyRepositoryImpl(roomSocket),
      gameRepository: GameRepositoryImpl(roomSocket),
      startupRouteResolver: StartupRouteResolver(
        sessionRepository: sessionRepository,
        roomRepository: roomRepository,
      ),
      createRoom: CreateRoom(roomRepository, sessionRepository),
      joinRoom: JoinRoom(roomRepository, sessionRepository),
    );
  }

  void prepareForHotReload() {
    roomSocket.resetForHotReload();
  }

  HomeBloc createHomeBloc({String? initialRoomCode}) {
    return HomeBloc(
      createRoom: createRoom,
      joinRoom: joinRoom,
      initialRoomCode: initialRoomCode,
    );
  }

  LobbyBloc createLobbyBloc() {
    return LobbyBloc(
      sessionRepository: sessionRepository,
      lobbyRepository: lobbyRepository,
    )..add(const LobbyStarted());
  }

  GameBloc createGameBloc() {
    return GameBloc(
      sessionRepository: sessionRepository,
      gameRepository: gameRepository,
      roomRepository: roomRepository,
    )..add(const GameStarted());
  }
}
