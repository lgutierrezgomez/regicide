import 'app_strings.dart';

/// Maps API / socket error codes to user-facing copy.
abstract final class AppErrorMessages {
  static String fromApi({String? code, required String fallback}) {
    switch (code) {
      case 'ROOM_FULL':
        return AppStrings.errorRoomFull;
      case 'GAME_STARTED':
        return AppStrings.errorGameAlreadyStarted;
      case 'ROOM_NOT_FOUND':
        return AppStrings.errorRoomNotFound;
      case 'NOT_HOST':
        return AppStrings.errorNotHost;
      case 'NOT_IN_ROOM':
        return AppStrings.errorNotInRoom;
      case 'INVALID_NAME':
        return AppStrings.errorInvalidName;
      default:
        return fallback.isNotEmpty ? fallback : AppStrings.errorGeneric;
    }
  }

  static String fromSocket({String? code, required String fallback}) {
    switch (code) {
      case 'NOT_HOST':
        return AppStrings.errorNotHost;
      case 'GAME_STARTED':
        return AppStrings.errorGameAlreadyStarted;
      case 'NOT_YOUR_TURN':
        return AppStrings.errorNotYourTurn;
      case 'INVALID_PHASE':
      case 'INVALID_PLAY':
      case 'CANNOT_YIELD':
      case 'INSUFFICIENT_DISCARD':
      case 'INVALID_DISCARD':
        return fallback.isNotEmpty ? fallback : AppStrings.errorGameAction;
      default:
        return fallback.isNotEmpty ? fallback : AppStrings.errorGeneric;
    }
  }
}
