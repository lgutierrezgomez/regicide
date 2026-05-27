import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/models/game_state_dto.dart';
import 'package:front/domain/entities/game_public_state.dart';

void main() {
  test('parses game state view from server JSON', () {
    final view = GameStateDto.fromJson({
      'public': {
        'roomCode': 'ABC123',
        'outcome': 'playing',
        'phase': 'STEP1_PLAY_OR_YIELD',
        'currentPlayerId': 'p1',
        'playerOrder': ['p1'],
        'maxHandSize': 8,
        'handCounts': {'p1': 8},
        'tavernCount': 40,
        'discardCount': 0,
        'currentEnemy': {
          'id': 'e1',
          'kind': 'enemy',
          'suit': 'spades',
          'rank': 'JACK',
        },
        'fightDamage': 0,
        'fightSpadeShield': 0,
        'immunityCancelled': false,
        'playedAgainstEnemy': [],
        'pendingDamage': null,
        'pendingChooseNext': false,
        'soloJestersRemaining': 2,
        'canYield': true,
      },
      'hand': [
        {
          'id': 'c1',
          'kind': 'number',
          'suit': 'hearts',
          'rank': 7,
        },
      ],
    }).toEntity();

    expect(view.public.roomCode, 'ABC123');
    expect(view.public.phase, GamePhase.step1PlayOrYield);
    expect(view.public.soloJestersRemaining, 2);
    expect(view.hand, hasLength(1));
    expect(view.hand.first.rankLabel, '7');
  });
}
