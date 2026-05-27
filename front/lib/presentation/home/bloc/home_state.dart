import 'package:equatable/equatable.dart';

import '../../../domain/entities/room_session.dart';

enum HomeStatus { initial, ready, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.displayName = '',
    this.roomCode = '',
    this.errorMessage,
    this.session,
  });

  final HomeStatus status;
  final String displayName;
  final String roomCode;
  final String? errorMessage;
  final RoomSession? session;

  bool get canSubmit =>
      displayName.trim().isNotEmpty && status != HomeStatus.loading;

  bool get canJoin => canSubmit && roomCode.trim().length >= 4;

  HomeState copyWith({
    HomeStatus? status,
    String? displayName,
    String? roomCode,
    String? errorMessage,
    RoomSession? session,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      roomCode: roomCode ?? this.roomCode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
    );
  }

  @override
  List<Object?> get props => [
        status,
        displayName,
        roomCode,
        errorMessage,
        session,
      ];
}
