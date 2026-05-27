import 'package:flutter_test/flutter_test.dart';
import 'package:front/core/l10n/app_error_messages.dart';
import 'package:front/core/l10n/app_strings.dart';

void main() {
  test('maps ROOM_FULL from API', () {
    expect(
      AppErrorMessages.fromApi(code: 'ROOM_FULL', fallback: 'x'),
      AppStrings.errorRoomFull,
    );
  });

  test('maps GAME_STARTED from API', () {
    expect(
      AppErrorMessages.fromApi(code: 'GAME_STARTED', fallback: 'x'),
      AppStrings.errorGameAlreadyStarted,
    );
  });
}
