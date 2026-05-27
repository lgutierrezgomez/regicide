import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/socket_exception.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_state_view.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/session_repository.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required SessionRepository sessionRepository,
    required GameRepository gameRepository,
    required RoomRepository roomRepository,
  })  : _sessionRepository = sessionRepository,
        _gameRepository = gameRepository,
        _roomRepository = roomRepository,
        super(const GameState()) {
    on<GameStarted>(_onStarted);
    on<GameStateReceived>(_onStateReceived);
    on<GameSocketError>(_onSocketError);
    on<GameCardToggled>(_onCardToggled);
    on<GameSelectionCleared>(_onSelectionCleared);
    on<GamePlayRequested>(_onPlay);
    on<GameYieldRequested>(_onYield);
    on<GameDiscardRequested>(_onDiscard);
    on<GameChooseNextRequested>(_onChooseNext);
    on<GameSoloJesterRequested>(_onSoloJester);
    on<GameDisconnected>(_onDisconnected);
    on<GameReconnectRequested>(_onReconnect);
    on<GameRoomUpdated>(_onRoomUpdated);
    on<GameReturnToLobbyRequested>(_onReturnToLobby);
    on<GameRestartRequested>(_onRestart);
  }

  final SessionRepository _sessionRepository;
  final GameRepository _gameRepository;
  final RoomRepository _roomRepository;

  StreamSubscription<GameStateView>? _stateSub;
  StreamSubscription<Room>? _roomSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<void>? _lostSub;

  Future<void> _onStarted(GameStarted event, Emitter<GameState> emit) async {
    final session = await _sessionRepository.loadSession();
    if (session == null) {
      emit(const GameState(status: GameStatus.noSession));
      return;
    }

    var playerNames = <String, String>{};
    try {
      final room = await _roomRepository.fetchRoom(session.roomCode);
      playerNames = {for (final p in room.players) p.id: p.displayName};
    } catch (_) {
      playerNames = {session.playerId: session.displayName};
    }

    emit(GameState(
      status: GameStatus.loading,
      session: session,
      playerDisplayNames: playerNames,
      connectionStatus: GameConnectionStatus.connecting,
    ));

    await _stateSub?.cancel();
    await _roomSub?.cancel();
    await _errorSub?.cancel();
    await _lostSub?.cancel();

    _stateSub = _gameRepository.stateUpdates.listen(
      (view) => add(GameStateReceived(view)),
    );
    _roomSub = _gameRepository.roomUpdates.listen(
      (room) => add(GameRoomUpdated(room)),
    );
    _errorSub = _gameRepository.errors.listen(
      (message) => add(GameSocketError(message)),
    );
    _lostSub = _gameRepository.connectionLost.listen(
      (_) => add(const GameDisconnected()),
    );

    try {
      await _gameRepository.connect(session);
      emit(state.copyWith(
        status: GameStatus.ready,
        connectionStatus: GameConnectionStatus.connected,
        clearError: true,
      ));
    } on SocketFailure {
      emit(state.copyWith(
        status: GameStatus.failure,
        connectionStatus: GameConnectionStatus.failed,
        errorMessage: AppStrings.errorGameConnect,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: GameStatus.failure,
        connectionStatus: GameConnectionStatus.failed,
        errorMessage: AppStrings.errorGameConnect,
      ));
    }
  }

  void _onStateReceived(GameStateReceived event, Emitter<GameState> emit) {
    emit(state.copyWith(
      view: event.view,
      status: GameStatus.ready,
      connectionStatus: GameConnectionStatus.connected,
      clearSelection: true,
      actionPending: false,
    ));
  }

  void _onSocketError(GameSocketError event, Emitter<GameState> emit) {
    emit(state.copyWith(
      errorMessage: event.message,
      actionPending: false,
    ));
  }

  void _onCardToggled(GameCardToggled event, Emitter<GameState> emit) {
    if (!state.canInteract) {
      return;
    }
    final selected = Set<String>.from(state.selectedCardIds);
    if (selected.contains(event.cardId)) {
      selected.remove(event.cardId);
    } else {
      selected.add(event.cardId);
    }
    emit(state.copyWith(selectedCardIds: selected));
  }

  void _onSelectionCleared(
    GameSelectionCleared event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }

  void _sendAction(Emitter<GameState> emit, void Function() send) {
    if (state.connectionStatus != GameConnectionStatus.connected) {
      emit(state.copyWith(
        errorMessage: AppStrings.errorGameConnect,
        actionPending: false,
      ));
      return;
    }
    emit(state.copyWith(actionPending: true, clearError: true));
    send();
  }

  void _onPlay(GamePlayRequested event, Emitter<GameState> emit) {
    if (!state.canPlay) {
      return;
    }
    final ids = state.selectedCardIds.toList();
    _sendAction(emit, () => _gameRepository.playCards(ids));
  }

  void _onYield(GameYieldRequested event, Emitter<GameState> emit) {
    if (!state.canYield) {
      return;
    }
    _sendAction(emit, _gameRepository.yieldTurn);
  }

  void _onDiscard(GameDiscardRequested event, Emitter<GameState> emit) {
    if (!state.canDiscard) {
      return;
    }
    final ids = state.selectedCardIds.toList();
    _sendAction(emit, () => _gameRepository.discardCards(ids));
  }

  void _onChooseNext(GameChooseNextRequested event, Emitter<GameState> emit) {
    if (!state.canChooseNext || state.session == null) {
      return;
    }
    final public = state.public!;
    if (!public.playerOrder.contains(event.nextPlayerId)) {
      return;
    }
    _sendAction(
      emit,
      () => _gameRepository.chooseNextPlayer(event.nextPlayerId),
    );
  }

  void _onSoloJester(GameSoloJesterRequested event, Emitter<GameState> emit) {
    if (!state.canSoloJester) {
      return;
    }
    _sendAction(emit, _gameRepository.soloJester);
  }

  void _onDisconnected(GameDisconnected event, Emitter<GameState> emit) {
    emit(state.copyWith(
      connectionStatus: GameConnectionStatus.failed,
      errorMessage: AppStrings.errorDisconnected,
    ));
  }

  void _onRoomUpdated(GameRoomUpdated event, Emitter<GameState> emit) {
    if (event.room.status == AppStrings.statusLobby) {
      emit(state.copyWith(status: GameStatus.navigateToLobby));
    }
  }

  void _onReturnToLobby(
    GameReturnToLobbyRequested event,
    Emitter<GameState> emit,
  ) {
    if (state.session?.isHost != true) {
      return;
    }
    _sendAction(emit, _gameRepository.returnToLobby);
  }

  void _onRestart(GameRestartRequested event, Emitter<GameState> emit) {
    if (state.session?.isHost != true) {
      return;
    }
    _sendAction(emit, _gameRepository.restartGame);
  }

  Future<void> _onReconnect(
    GameReconnectRequested event,
    Emitter<GameState> emit,
  ) async {
    final session = state.session;
    if (session == null) {
      return;
    }
    emit(state.copyWith(
      connectionStatus: GameConnectionStatus.connecting,
      clearError: true,
    ));
    try {
      await _gameRepository.connect(session);
      emit(state.copyWith(
        connectionStatus: GameConnectionStatus.connected,
        clearError: true,
      ));
    } on SocketFailure {
      emit(state.copyWith(
        connectionStatus: GameConnectionStatus.failed,
        errorMessage: AppStrings.errorGameConnect,
      ));
    } catch (_) {
      emit(state.copyWith(
        connectionStatus: GameConnectionStatus.failed,
        errorMessage: AppStrings.errorGameConnect,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _stateSub?.cancel();
    await _roomSub?.cancel();
    await _errorSub?.cancel();
    await _lostSub?.cancel();
    await _gameRepository.disconnect();
    return super.close();
  }
}
