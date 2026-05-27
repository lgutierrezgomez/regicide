import 'package:flutter_test/flutter_test.dart';
import 'package:front/core/web/join_invite_url.dart';

void main() {
  test('buildRoomInviteUrl uppercases room code in query', () {
    final url = buildRoomInviteUrl('abc123');
    expect(url.toLowerCase(), contains('room=abc123'));
  });
}
