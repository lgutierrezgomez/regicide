import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/socket_exception.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/repositories/lobby_repository.dart';
import '../../../domain/repositories/session_repository.dart';
import 'lobby_event.dart';
import 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  LobbyBloc({
    required SessionRepository sessionRepository,
    required LobbyRepository lobbyRepository,
  })  : _sessionRepository = sessionRepository,
        _lobbyRepository = lobbyRepository,
        super(const LobbyState()) {
    on<LobbyStarted>(_onStarted);
    on<LobbyStartGameRequested>(_onStartGame);
    on<LobbyRoomUpdated>(_onRoomUpdated);
    on<LobbyGameStarted>(_onGameStarted);
    on<LobbySocketError>(_onSocketError);
    on<LobbyDisconnected>(_onDisconnected);
    on<LobbyReconnectRequested>(_onReconnect);
  }

  final SessionRepository _sessionRepository;
  final LobbyRepository _lobbyRepository;

  StreamSubscription<Room>? _roomSub;
  StreamSubscription<Room>? _gameSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<void>? _lostSub;

  Future<void> _onStarted(LobbyStarted event, Emitter<LobbyState> emit) async {
    final session = await _sessionRepository.loadSession();
    if (session == null) {
      emit(const LobbyState(status: LobbyStatus.noSession));
      return;
    }

    emit(LobbyState(
      status: LobbyStatus.loading,
      session: session,
      connectionStatus: LobbyConnectionStatus.connecting,
    ));

    await _roomSub?.cancel();
    await _gameSub?.cancel();
    await _errorSub?.cancel();
    await _lostSub?.cancel();

    _roomSub = _lobbyRepository.roomUpdates.listen(
      (room) => add(LobbyRoomUpdated(room)),
    );
    _gameSub = _lobbyRepository.gameStarted.listen(
      (room) => add(LobbyGameStarted(room)),
    );
    _errorSub = _lobbyRepository.errors.listen(
      (message) => add(LobbySocketError(message)),
    );
    _lostSub = _lobbyRepository.connectionLost.listen(
      (_) => add(const LobbyDisconnected()),
    );

    try {
      await _lobbyRepository.connect(session);
      emit(state.copyWith(
        status: LobbyStatus.ready,
        connectionStatus: LobbyConnectionStatus.connected,
      ));
    } on SocketFailure {
      emit(state.copyWith(
        status: LobbyStatus.failure,
        connectionStatus: LobbyConnectionStatus.failed,
        errorMessage: AppStrings.errorSocketConnect,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LobbyStatus.failure,
        connectionStatus: LobbyConnectionStatus.failed,
        errorMessage: AppStrings.errorSocketConnect,
      ));
    }
  }

  void _onRoomUpdated(LobbyRoomUpdated event, Emitter<LobbyState> emit) {
    emit(state.copyWith(
      room: event.room,
      status: LobbyStatus.ready,
      connectionStatus: LobbyConnectionStatus.connected,
      clearError: true,
    ));
  }

  void _onGameStarted(LobbyGameStarted event, Emitter<LobbyState> emit) {
    emit(state.copyWith(
      room: event.room,
      status: LobbyStatus.navigateToGame,
    ));
  }

  void _onStartGame(LobbyStartGameRequested event, Emitter<LobbyState> emit) {
    if (!state.canStartGame) {
      return;
    }
    emit(state.copyWith(status: LobbyStatus.startingGame, clearError: true));
    _lobbyRepository.startGame();
  }

  void _onSocketError(LobbySocketError event, Emitter<LobbyState> emit) {
    if (state.status == LobbyStatus.startingGame) {
      emit(state.copyWith(
        status: LobbyStatus.ready,
        errorMessage: event.message,
      ));
      return;
    }
    emit(state.copyWith(errorMessage: event.message));
  }

  void _onDisconnected(LobbyDisconnected event, Emitter<LobbyState> emit) {
    emit(state.copyWith(
      connectionStatus: LobbyConnectionStatus.failed,
      errorMessage: AppStrings.errorDisconnected,
    ));
  }

  Future<void> _onReconnect(
    LobbyReconnectRequested event,
    Emitter<LobbyState> emit,
  ) async {
    final session = state.session;
    if (session == null) {
      return;
    }
    emit(state.copyWith(
      connectionStatus: LobbyConnectionStatus.connecting,
      clearError: true,
    ));
    try {
      await _lobbyRepository.connect(session);
      emit(state.copyWith(
        connectionStatus: LobbyConnectionStatus.connected,
        clearError: true,
      ));
    } on SocketFailure {
      emit(state.copyWith(
        connectionStatus: LobbyConnectionStatus.failed,
        errorMessage: AppStrings.errorSocketConnect,
      ));
    } catch (_) {
      emit(state.copyWith(
        connectionStatus: LobbyConnectionStatus.failed,
        errorMessage: AppStrings.errorSocketConnect,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _roomSub?.cancel();
    await _gameSub?.cancel();
    await _errorSub?.cancel();
    await _lostSub?.cancel();
    await _lobbyRepository.disconnect();
    return super.close();
  }
}
