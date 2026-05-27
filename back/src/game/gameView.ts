import { toCardPublic } from "./cards.js";
import { canYield, currentPlayerId } from "./gameEngine.js";
import type { GameState, GameStateView, GamePublicState } from "./types.js";

export function buildPublicState(state: GameState): GamePublicState {
  const handCounts: Record<string, number> = {};
  for (const pid of state.playerOrder) {
    handCounts[pid] = state.hands[pid]?.length ?? 0;
  }

  return {
    roomCode: state.roomCode,
    outcome: state.outcome,
    victoryTier: state.victoryTier,
    phase: state.phase,
    currentPlayerId: currentPlayerId(state),
    playerOrder: state.playerOrder,
    maxHandSize: state.maxHandSize,
    handCounts,
    tavernCount: state.tavern.length,
    discardCount: state.discard.length,
    castleCount: state.castle.length,
    currentEnemy: state.currentEnemy ? toCardPublic(state.currentEnemy) : null,
    fightDamage: state.fightDamage,
    fightSpadeShield: state.fightSpadeShield,
    immunityCancelled: state.immunityCancelled,
    playedAgainstEnemy: state.fightPlayed.map((e) => ({
      playerId: e.playerId,
      cards: e.cards.map(toCardPublic),
    })),
    pendingDamage: state.pendingDamage,
    pendingChooseNext: state.phase === "CHOOSE_NEXT_PLAYER",
    soloJestersRemaining:
      state.playerOrder.length === 1 ? state.soloJestersAside.length : null,
    canYield: canYield(state, currentPlayerId(state)),
  };
}

export function buildViewForPlayer(state: GameState, playerId: string): GameStateView {
  const hand = state.hands[playerId] ?? [];
  return {
    public: buildPublicState(state),
    hand: hand.map(toCardPublic),
  };
}
