import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/l10n/app_error_messages.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../domain/usecases/create_room.dart';
import '../../../domain/usecases/join_room.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required CreateRoom createRoom,
    required JoinRoom joinRoom,
    String? initialRoomCode,
  })  : _createRoom = createRoom,
        _joinRoom = joinRoom,
        super(
          HomeState(
            status: HomeStatus.ready,
            roomCode: (initialRoomCode ?? '').toUpperCase(),
          ),
        ) {
    on<HomeStarted>(_onStarted);
    on<HomeDisplayNameChanged>(_onDisplayNameChanged);
    on<HomeRoomCodeChanged>(_onRoomCodeChanged);
    on<HomeCreateRoomRequested>(_onCreateRoom);
    on<HomeJoinRoomRequested>(_onJoinRoom);
  }

  final CreateRoom _createRoom;
  final JoinRoom _joinRoom;

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.ready, clearError: true));
  }

  void _onDisplayNameChanged(
    HomeDisplayNameChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(displayName: event.displayName, clearError: true));
  }

  void _onRoomCodeChanged(HomeRoomCodeChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(
        roomCode: event.roomCode.toUpperCase(), clearError: true));
  }

  Future<void> _onCreateRoom(
    HomeCreateRoomRequested event,
    Emitter<HomeState> emit,
  ) async {
    final name = state.displayName.trim();
    if (name.isEmpty) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppStrings.errorDisplayNameRequired,
      ));
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    try {
      final session = await _createRoom(displayName: name);
      emit(state.copyWith(
        status: HomeStatus.success,
        session: session,
        roomCode: session.roomCode,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppErrorMessages.fromApi(
          code: e.code,
          fallback: e.message,
        ),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppStrings.errorCreateRoomFailed,
      ));
    }
  }

  Future<void> _onJoinRoom(
    HomeJoinRoomRequested event,
    Emitter<HomeState> emit,
  ) async {
    final name = state.displayName.trim();
    final code = state.roomCode.trim();
    if (name.isEmpty) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppStrings.errorDisplayNameRequired,
      ));
      return;
    }
    if (code.length < 4) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppStrings.errorRoomCodeInvalid,
      ));
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    try {
      final session = await _joinRoom(roomCode: code, displayName: name);
      emit(state.copyWith(status: HomeStatus.success, session: session));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppErrorMessages.fromApi(
          code: e.code,
          fallback: e.message,
        ),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: AppStrings.errorJoinRoomFailed,
      ));
    }
  }
}
