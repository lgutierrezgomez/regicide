import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/game_card.dart';
import 'package:front/domain/entities/game_public_state.dart';
import 'package:front/domain/entities/game_state_view.dart';
import 'package:front/domain/entities/room_session.dart';
import 'package:front/presentation/game/bloc/game_state.dart';

void main() {
  const session = RoomSession(
    roomCode: 'ABC',
    playerId: 'p1',
    displayName: 'Test',
    isHost: true,
  );

  const enemy = GameCard(
    id: 'e1',
    kind: GameCardKind.enemy,
    suit: GameSuit.spades,
    rankLabel: 'JACK',
  );

  GameState stateWith({
    GamePhase phase = GamePhase.step4Discard,
    int? pendingDamage = 0,
    int fightSpadeShield = 10,
    Set<String> selected = const {},
  }) {
    return GameState(
      status: GameStatus.ready,
      connectionStatus: GameConnectionStatus.connected,
      session: session,
      view: GameStateView(
        public: GamePublicState(
          roomCode: 'ABC',
          outcome: GameOutcome.playing,
          phase: phase,
          currentPlayerId: 'p1',
          playerOrder: ['p1'],
          maxHandSize: 8,
          handCounts: {'p1': 5},
          tavernCount: 10,
          discardCount: 0,
          castleCount: 11,
          currentEnemy: enemy,
          fightDamage: 5,
          fightSpadeShield: fightSpadeShield,
          immunityCancelled: false,
          playedAgainstEnemy: [],
          pendingDamage: pendingDamage,
          pendingChooseNext: false,
          soloJestersRemaining: 2,
          canYield: true,
        ),
        hand: const [
          GameCard(
            id: 'c1',
            kind: GameCardKind.number,
            suit: GameSuit.hearts,
            rankLabel: '7',
          ),
        ],
      ),
      selectedCardIds: selected,
    );
  }

  test('canDiscard with zero pending damage and no cards selected', () {
    expect(stateWith().canDiscard, isTrue);
  });

  test('canDiscard with exactly one card selected (Phase 5C: one-at-a-time)', () {
    final state = stateWith(pendingDamage: 7, selected: {'c1'});
    expect(state.canDiscard, isTrue);
  });

  test('canDiscard when single card value is below pendingDamage (partial)', () {
    // Phase 5C: card value alone doesn't have to cover the whole pendingDamage —
    // the engine subtracts the value and keeps step 4 open for the next discard.
    final state = stateWith(pendingDamage: 10, selected: {'c1'});
    expect(state.canDiscard, isTrue);
  });

  test('cannot discard with no card selected when pendingDamage > 0', () {
    final state = stateWith(pendingDamage: 5, selected: const {});
    expect(state.canDiscard, isFalse);
  });

  test('requiredDiscardTotal falls back to enemy attack minus shield', () {
    final state = stateWith(pendingDamage: null);
    expect(state.requiredDiscardTotal, 0);
    final blocked = stateWith(
      pendingDamage: null,
      fightSpadeShield: 10,
    );
    expect(blocked.requiredDiscardTotal, 0);
  });
}
