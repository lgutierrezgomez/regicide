import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/game_card.dart';
import 'package:front/domain/entities/game_public_state.dart';
import 'package:front/domain/entities/game_state_view.dart';
import 'package:front/domain/entities/room_session.dart';
import 'package:front/domain/entities/player.dart';
import 'package:front/domain/entities/room.dart';
import 'package:front/domain/repositories/game_repository.dart';
import 'package:front/domain/repositories/room_repository.dart';
import 'package:front/domain/repositories/session_repository.dart';
import 'package:front/presentation/game/bloc/game_bloc.dart';
import 'package:front/presentation/game/bloc/game_event.dart';
import 'package:front/presentation/game/bloc/game_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class MockGameRepository extends Mock implements GameRepository {}

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  late MockSessionRepository sessionRepository;
  late MockGameRepository gameRepository;
  late MockRoomRepository roomRepository;

  const session = RoomSession(
    roomCode: 'ABC123',
    playerId: 'p1',
    displayName: 'Alice',
    isHost: true,
  );

  const sampleView = GameStateView(
    public: GamePublicState(
      roomCode: 'ABC123',
      outcome: GameOutcome.playing,
      phase: GamePhase.step1PlayOrYield,
      currentPlayerId: 'p1',
      playerOrder: ['p1'],
      maxHandSize: 8,
      handCounts: {'p1': 2},
      tavernCount: 10,
      discardCount: 0,
      castleCount: 11,
      currentEnemy: GameCard(
        id: 'e1',
        kind: GameCardKind.enemy,
        suit: GameSuit.spades,
        rankLabel: 'JACK',
      ),
      fightDamage: 0,
      fightSpadeShield: 0,
      immunityCancelled: false,
      playedAgainstEnemy: [],
      pendingDamage: null,
      pendingChooseNext: false,
      soloJestersRemaining: 2,
      canYield: true,
    ),
    hand: [
      GameCard(
        id: 'c1',
        kind: GameCardKind.number,
        suit: GameSuit.hearts,
        rankLabel: '7',
      ),
    ],
  );

  setUp(() {
    sessionRepository = MockSessionRepository();
    gameRepository = MockGameRepository();
    roomRepository = MockRoomRepository();

    when(() => sessionRepository.loadSession()).thenAnswer((_) async => session);
    when(() => roomRepository.fetchRoom('ABC123')).thenAnswer(
      (_) async => const Room(
        code: 'ABC123',
        status: 'lobby',
        hostPlayerId: 'p1',
        maxPlayers: 4,
        players: [
          Player(id: 'p1', displayName: 'Alice', connected: true),
        ],
      ),
    );
    when(() => gameRepository.connect(session)).thenAnswer((_) async {});
    when(() => gameRepository.disconnect()).thenAnswer((_) async {});
    when(() => gameRepository.stateUpdates).thenAnswer((_) => const Stream.empty());
    when(() => gameRepository.roomUpdates).thenAnswer((_) => const Stream.empty());
    when(() => gameRepository.errors).thenAnswer((_) => const Stream.empty());
    when(() => gameRepository.connectionLost)
        .thenAnswer((_) => const Stream.empty());
    when(() => gameRepository.playCards(any())).thenReturn(null);
  });

  GameBloc buildBloc() => GameBloc(
        sessionRepository: sessionRepository,
        gameRepository: gameRepository,
        roomRepository: roomRepository,
      );

  blocTest<GameBloc, GameState>(
    'connects and becomes ready',
    build: buildBloc,
    act: (bloc) => bloc.add(const GameStarted()),
    expect: () => [
      GameState(
        status: GameStatus.loading,
        session: session,
        playerDisplayNames: const {'p1': 'Alice'},
        connectionStatus: GameConnectionStatus.connecting,
      ),
      GameState(
        status: GameStatus.ready,
        session: session,
        playerDisplayNames: const {'p1': 'Alice'},
        connectionStatus: GameConnectionStatus.connected,
      ),
    ],
  );

  blocTest<GameBloc, GameState>(
    'toggles card selection on my turn',
    build: buildBloc,
    seed: () => const GameState(
      status: GameStatus.ready,
      session: session,
      view: sampleView,
      connectionStatus: GameConnectionStatus.connected,
    ),
    act: (bloc) => bloc.add(const GameCardToggled('c1')),
    expect: () => [
      const GameState(
        status: GameStatus.ready,
        session: session,
        view: sampleView,
        connectionStatus: GameConnectionStatus.connected,
        selectedCardIds: {'c1'},
      ),
    ],
  );

  blocTest<GameBloc, GameState>(
    'emits play with selected cards',
    build: buildBloc,
    seed: () => const GameState(
      status: GameStatus.ready,
      session: session,
      view: sampleView,
      connectionStatus: GameConnectionStatus.connected,
      selectedCardIds: {'c1'},
    ),
    act: (bloc) => bloc.add(const GamePlayRequested()),
    verify: (_) {
      verify(() => gameRepository.playCards(['c1'])).called(1);
    },
  );
}
