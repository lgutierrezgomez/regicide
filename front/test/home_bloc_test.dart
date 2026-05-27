import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/core/errors/api_exception.dart';
import 'package:front/domain/entities/room_session.dart';
import 'package:front/domain/repositories/room_repository.dart';
import 'package:front/domain/repositories/session_repository.dart';
import 'package:front/domain/usecases/create_room.dart';
import 'package:front/domain/usecases/join_room.dart';
import 'package:front/core/l10n/app_strings.dart';
import 'package:front/presentation/home/bloc/home_bloc.dart';
import 'package:front/presentation/home/bloc/home_event.dart';
import 'package:front/presentation/home/bloc/home_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RoomSession(
      roomCode: 'XXXXXX',
      playerId: 'p',
      displayName: 'X',
      isHost: false,
    ));
  });

  late MockRoomRepository roomRepository;
  late MockSessionRepository sessionRepository;
  late CreateRoom createRoom;
  late JoinRoom joinRoom;

  const session = RoomSession(
    roomCode: 'ABC123',
    playerId: 'player-1',
    displayName: 'Alice',
    isHost: true,
  );

  setUp(() {
    roomRepository = MockRoomRepository();
    sessionRepository = MockSessionRepository();
    createRoom = CreateRoom(roomRepository, sessionRepository);
    joinRoom = JoinRoom(roomRepository, sessionRepository);

    when(() => sessionRepository.saveSession(any())).thenAnswer((_) async {});
  });

  HomeBloc buildBloc({String? initialRoomCode}) {
    return HomeBloc(
      createRoom: createRoom,
      joinRoom: joinRoom,
      initialRoomCode: initialRoomCode,
    );
  }

  blocTest<HomeBloc, HomeState>(
    'enables submit when display name is set',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const HomeDisplayNameChanged('Alice')),
    verify: (bloc) {
      expect(bloc.state.displayName, 'Alice');
      expect(bloc.state.canSubmit, isTrue);
    },
  );

  blocTest<HomeBloc, HomeState>(
    'prefills room code from URL',
    build: () => buildBloc(initialRoomCode: 'xyz789'),
    verify: (bloc) {
      expect(bloc.state.roomCode, 'XYZ789');
    },
  );

  blocTest<HomeBloc, HomeState>(
    'emits success when create room succeeds',
    build: () => buildBloc(),
    seed: () => const HomeState(
      status: HomeStatus.ready,
      displayName: 'Alice',
    ),
    act: (bloc) async {
      bloc.add(const HomeCreateRoomRequested());
    },
    setUp: () {
      when(
        () => roomRepository.createRoom(displayName: 'Alice'),
      ).thenAnswer((_) async => session);
    },
    expect: () => [
      const HomeState(
        status: HomeStatus.loading,
        displayName: 'Alice',
      ),
      const HomeState(
        status: HomeStatus.success,
        displayName: 'Alice',
        roomCode: 'ABC123',
        session: session,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'emits failure on API error',
    build: () => buildBloc(),
    seed: () => const HomeState(
      status: HomeStatus.ready,
      displayName: 'Bob',
    ),
    act: (bloc) => bloc.add(const HomeCreateRoomRequested()),
    setUp: () {
      when(() => roomRepository.createRoom(displayName: 'Bob')).thenThrow(
        ApiException('Room is full', code: 'ROOM_FULL'),
      );
    },
    expect: () => [
      const HomeState(status: HomeStatus.loading, displayName: 'Bob'),
      const HomeState(
        status: HomeStatus.failure,
        displayName: 'Bob',
        errorMessage: AppStrings.errorRoomFull,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'requires display name',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const HomeCreateRoomRequested()),
    expect: () => [
      const HomeState(
        status: HomeStatus.failure,
        errorMessage: AppStrings.errorDisplayNameRequired,
      ),
    ],
  );
}
